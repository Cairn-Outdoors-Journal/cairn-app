import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:sodium/sodium.dart';

import '../database/database.dart';
import '../ids.dart';
import '../sync/record_writer.dart';

/// Photos, sketches, voice notes and GPX files, kept encrypted in one folder
/// (ADR 0010). Callers hand over and get back plain bytes.
///
/// File layout: the magic `CRL1`, the secretstream header, then the content
/// in 64 KiB chunks, each encrypted with XChaCha20-Poly1305. Every chunk is
/// bound to the media id, so a file renamed to another id fails to decrypt.
class MediaStore {
  MediaStore({
    required this.directory,
    required this._sodium,
    required this._key,
    required this._writer,
  });

  static const _magic = [0x43, 0x52, 0x4c, 0x31]; // "CRL1"
  static const _chunkSize = 64 * 1024;

  final Directory directory;
  final Sodium _sodium;
  final SecureKey _key;
  final RecordWriter _writer;

  CairnDatabase get _db => _writer.db;

  File fileFor(String id) => File(p.join(directory.path, '$id.media'));

  /// Encrypts and stores [bytes], then saves the media record.
  Future<MediaRecord> put(
    Uint8List bytes, {
    required MediaKind kind,
    required String mimeType,
    int? width,
    int? height,
  }) async {
    final id = newRecordId();
    final file = fileFor(id);
    await file.writeAsBytes(await _encrypt(bytes, id), flush: true);
    try {
      return await _writer.save(
        RecordType.media,
        _db.media,
        (hlc) => MediaRecord(
          id: id,
          hlc: hlc,
          deleted: false,
          kind: kind,
          mimeType: mimeType,
          byteSize: bytes.length,
          width: width,
          height: height,
          createdAtMs: _writer.clock.nowMs(),
        ),
      );
    } catch (_) {
      await file.delete();
      rethrow;
    }
  }

  /// Whether the file is on this phone. After an Android cloud restore the
  /// records come back but photos don't (ADR 0010): show a placeholder.
  bool isOnPhone(String id) => fileFor(id).existsSync();

  /// The original bytes. Throws when the file is missing or was tampered
  /// with.
  Future<Uint8List> read(String id) async =>
      _decrypt(await fileFor(id).readAsBytes(), id);

  /// Deletes the record (a tombstone, so it syncs) and the file.
  Future<void> delete(String id) async {
    await _writer.delete(RecordType.media, _db.media, id);
    final file = fileFor(id);
    if (file.existsSync()) await file.delete();
  }

  /// Removes the files of deleted media, for example photos released when
  /// their page was deleted.
  Future<void> removeDeletedFiles() async {
    final deleted =
        await (_db.selectOnly(_db.media)
              ..addColumns([_db.media.id])
              ..where(_db.media.deleted))
            .map((row) => row.read(_db.media.id)!)
            .get();
    for (final id in deleted) {
      final file = fileFor(id);
      if (file.existsSync()) await file.delete();
    }
  }

  Future<Uint8List> _encrypt(Uint8List plain, String id) async {
    final ad = _additionalData(id);
    final messages = <SecretStreamPlainMessage>[];
    var offset = 0;
    do {
      final end = min(offset + _chunkSize, plain.length);
      messages.add(
        SecretStreamPlainMessage(
          Uint8List.sublistView(plain, offset, end),
          additionalData: ad,
          tag: end == plain.length
              ? SecretStreamMessageTag.finalPush
              : SecretStreamMessageTag.message,
        ),
      );
      offset = end;
    } while (offset < plain.length);

    final out = BytesBuilder(copy: false)..add(_magic);
    await for (final message in _sodium.crypto.secretStream.pushEx(
      messageStream: Stream.fromIterable(messages),
      key: _key,
    )) {
      out.add(message.message);
    }
    return out.takeBytes();
  }

  Future<Uint8List> _decrypt(Uint8List file, String id) async {
    final stream = _sodium.crypto.secretStream;
    final headerEnd = _magic.length + stream.headerBytes;
    if (file.length < headerEnd ||
        !_sameBytes(file.sublist(0, _magic.length), _magic)) {
      throw const FormatException('Not a Cairn media file');
    }
    final ad = _additionalData(id);
    final messages = <SecretStreamCipherMessage>[
      SecretStreamCipherMessage(file.sublist(_magic.length, headerEnd)),
    ];
    final cipherChunk = _chunkSize + stream.aBytes;
    for (var offset = headerEnd; offset < file.length; offset += cipherChunk) {
      final end = min(offset + cipherChunk, file.length);
      messages.add(
        SecretStreamCipherMessage(
          Uint8List.sublistView(file, offset, end),
          additionalData: ad,
        ),
      );
    }

    final out = BytesBuilder(copy: false);
    await for (final message in stream.pullEx(
      cipherStream: Stream.fromIterable(messages),
      key: _key,
    )) {
      out.add(message.message);
    }
    return out.takeBytes();
  }

  static Uint8List _additionalData(String id) => utf8.encode('cairn-media:$id');

  static bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
