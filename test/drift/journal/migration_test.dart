// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:cairn/data/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // Every schema upgrade produces exactly the schema the code expects.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = CairnDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v1 notebooks become yearly notebooks, pages untouched', () async {
    const oldNotebook = v1.NotebooksData(
      id: 'n1',
      hlc: '000001780000000-0000-device',
      deleted: 0,
      title: 'Day hikes',
      year: 2026,
      cover: 'forest',
      createdAtMs: 1780000000000,
    );
    const newNotebook = v2.NotebooksData(
      id: 'n1',
      hlc: '000001780000000-0000-device',
      deleted: 0,
      kind: 'year',
      title: 'Day hikes',
      year: 2026,
      cover: 'forest',
      createdAtMs: 1780000000000,
    );
    const oldPage = v1.PagesData(
      id: 'p1',
      hlc: '000001780000000-0001-device',
      deleted: 0,
      notebookId: 'n1',
      day: '2026-06-01',
      place: 'Tuolumne Meadows',
      createdAtMs: 1780000000000,
    );
    const newPage = v2.PagesData(
      id: 'p1',
      hlc: '000001780000000-0001-device',
      deleted: 0,
      notebookId: 'n1',
      day: '2026-06-01',
      place: 'Tuolumne Meadows',
      createdAtMs: 1780000000000,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: CairnDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.notebooks, [oldNotebook]);
        batch.insertAll(oldDb.pages, [oldPage]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.notebooks).get(), [newNotebook]);
        expect(await newDb.select(newDb.pages).get(), [newPage]);
      },
    );
  });
}
