import 'package:cairn/spikes/location_capture/capture_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses records newest first and skips half-written lines', () {
    const log =
        '{"id":"a","platform":"android","source":"tile","method":"direct",'
        '"permission":"whileInUse","appState":"background","result":"securityException",'
        '"requestedAt":1000,"latencyMs":3,"error":"not allowed"}\n'
        '{"id":"b","platform":"android","source":"app","method":"direct",'
        '"permission":"always","appState":"foreground","result":"fix",'
        '"requestedAt":2000,"latencyMs":850,"lat":37.77,"lon":-122.41,'
        '"accuracyM":5.0,"precise":true}\n'
        '{"id":"c","sou';

    final records = parseCaptureLog(log);

    expect(records.map((r) => r.id), ['b', 'a']);
    expect(records.first.gotLocation, isTrue);
    expect(records.first.lat, 37.77);
    expect(records.last.gotLocation, isFalse);
    expect(records.last.error, 'not allowed');
  });

  test('an empty log has no records', () {
    expect(parseCaptureLog(''), isEmpty);
  });
}
