import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';
import 'capture_record.dart';

const _channel = MethodChannel('cairn/location_spike');

/// Test screen for stage 5b: what permission Cairn has, buttons to change
/// it, an in-app capture, and the log of every capture from every surface
/// (app, Android tile, iOS widget / Control Center / Action button).
class LocationSpikeScreen extends StatefulWidget {
  const LocationSpikeScreen({super.key});

  @override
  State<LocationSpikeScreen> createState() => _LocationSpikeScreenState();
}

class _LocationSpikeScreenState extends State<LocationSpikeScreen>
    with WidgetsBindingObserver {
  String _permission = '…';
  bool? _precise;
  List<CaptureRecord> _records = const [];
  bool _capturing = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    // Captures from the tile or widget land in the log while the app is open.
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await _channel.invokeMapMethod<String, Object?>('status');
    final log = await _channel.invokeMethod<String>('readLog') ?? '';
    if (!mounted) return;
    setState(() {
      _permission = status?['permission'] as String? ?? '?';
      _precise = status?['precise'] as bool?;
      _records = parseCaptureLog(log);
    });
  }

  Future<void> _call(String method) async {
    await _channel.invokeMethod<Object?>(method);
    await _refresh();
  }

  /// Android only shows its "Add tile" dialog when the tile is missing, so
  /// say what happened instead of leaving the button looking dead.
  Future<void> _addTile() async {
    final code = await _channel.invokeMethod<int>('addTile');
    if (!mounted) return;
    final message = switch (code) {
      0 => 'Tile not added.',
      1 => '"Save point" is already in quick settings.',
      2 => 'Tile added to quick settings.',
      -1 =>
        'Needs Android 13 or later; add the tile by editing quick settings.',
      _ => 'Android could not add the tile (code $code).',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _captureNow() async {
    setState(() => _capturing = true);
    try {
      await _channel.invokeMethod<Object?>('captureNow');
    } finally {
      if (mounted) setState(() => _capturing = false);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = CairnColors.light;
    return Scaffold(
      backgroundColor: palette.paper,
      appBar: AppBar(
        backgroundColor: palette.paper,
        title: const Text('Location capture spike'),
        actions: [
          IconButton(
            tooltip: 'Clear log',
            onPressed: () => _call('clearLog'),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Text(
            'Permission: $_permission'
            '${_precise == false ? ' (approximate)' : ''}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _call('requestWhileUsing'),
                child: const Text('Allow while using'),
              ),
              OutlinedButton(
                onPressed: () => _call('requestAlways'),
                child: const Text('Allow always'),
              ),
              OutlinedButton(
                onPressed: () => _call('openSettings'),
                child: const Text('Settings'),
              ),
              if (Platform.isAndroid)
                OutlinedButton(
                  onPressed: _addTile,
                  child: const Text('Add tile'),
                ),
              FilledButton(
                onPressed: _capturing ? null : _captureNow,
                child: Text(_capturing ? 'Capturing…' : 'Capture now'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${_records.length} captures',
            style: TextStyle(color: palette.pencil),
          ),
          const SizedBox(height: 8),
          for (final r in _records) _RecordTile(record: r),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final CaptureRecord record;

  @override
  Widget build(BuildContext context) {
    const palette = CairnColors.light;
    final r = record;
    final time = TimeOfDay.fromDateTime(r.requestedAt).format(context);
    final where = r.lat == null
        ? null
        : '${r.lat!.toStringAsFixed(5)}, ${r.lon!.toStringAsFixed(5)}'
              ' ±${r.accuracyM?.toStringAsFixed(0) ?? '?'} m'
              '${r.locationAgeMs != null && r.locationAgeMs! > 60000 ? ' · ${(r.locationAgeMs! / 60000).toStringAsFixed(0)} min old' : ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: palette.rule),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${r.source} · ${r.method}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                r.result,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: r.gotLocation ? palette.vegetation : palette.blazeText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$time · ${r.permission} · app ${r.appState} · ${r.latencyMs} ms',
            style: TextStyle(fontSize: 13, color: palette.pencil),
          ),
          if (where != null) Text(where, style: const TextStyle(fontSize: 13)),
          if (r.error != null)
            Text(
              r.error!,
              style: TextStyle(fontSize: 12, color: palette.blazeText),
            ),
        ],
      ),
    );
  }
}
