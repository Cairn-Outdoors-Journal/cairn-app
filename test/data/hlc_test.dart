import 'package:cairn/data/sync/hlc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const a = 'aaaaaaaa-0000-4000-8000-000000000000';
  const b = 'bbbbbbbb-0000-4000-8000-000000000000';

  test('a later wall time resets the counter', () {
    expect(const Hlc(100, 5, a).tick(200), const Hlc(200, 0, a));
  });

  test('changes in the same millisecond count up', () {
    expect(const Hlc(100, 0, a).tick(100), const Hlc(100, 1, a));
  });

  test('a clock that jumps backwards never makes stamps go backwards', () {
    final next = const Hlc(5000, 2, a).tick(1000);
    expect(next, const Hlc(5000, 3, a));
    expect(next.compareTo(const Hlc(5000, 2, a)), greaterThan(0));
  });

  test('receiving a stamp from the future moves this clock past it', () {
    final merged = const Hlc(100, 0, a).receive(const Hlc(900, 4, b), 150);
    expect(merged, const Hlc(900, 5, a));
    expect(merged.tick(160).compareTo(const Hlc(900, 4, b)), greaterThan(0));
  });

  test('receiving with equal wall times takes the higher counter', () {
    expect(
      const Hlc(500, 7, a).receive(const Hlc(500, 3, b), 400),
      const Hlc(500, 8, a),
    );
  });

  test('receiving an old stamp when the local clock is ahead', () {
    expect(
      const Hlc(100, 0, a).receive(const Hlc(50, 9, b), 300),
      const Hlc(300, 0, a),
    );
  });

  test('equal wall time and counter break ties by device id', () {
    expect(const Hlc(1, 1, a).compareTo(const Hlc(1, 1, b)), lessThan(0));
  });

  test('packed stamps sort like the stamps and parse back', () {
    final stamps = [
      const Hlc(1780000000000, 0, b),
      const Hlc(999, 0xffff, a),
      const Hlc(1780000000000, 10, a),
      const Hlc(1780000000000, 2, a),
      const Hlc(0, 0, b),
    ];
    final byStamp = [...stamps]..sort();
    final byString = [...stamps]..sort((x, y) => x.pack().compareTo(y.pack()));
    expect(byString, byStamp);
    for (final stamp in stamps) {
      expect(Hlc.parse(stamp.pack()), stamp);
    }
  });

  test('the counter refuses to overflow', () {
    expect(() => const Hlc(1, Hlc.maxCounter, a).tick(1), throwsStateError);
  });
}
