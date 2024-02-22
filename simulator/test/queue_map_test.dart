import 'package:simulator/simulator.dart';
import 'package:test/test.dart';

class Dummy implements Indexable<SimDuration> {
  int x;
  SimDuration t;

  Dummy(this.x, this.t);

  @override
  String toString() => '$x';

  @override
  SimDuration get index => t;

  @override
  bool operator ==(covariant Dummy other) {
    return x == other.x && t == other.t;
  }

  @override
  int get hashCode => x + t.inPicoseconds;
}

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('queue map test', () {
      QueueMap<SimDuration, Dummy> queueMap1 = QueueMap();
      QueueMap<SimDuration, Dummy> queueMap2 = QueueMap();

      queueMap1
        ..add(Dummy(3, SimDuration.zero))
        ..add(Dummy(6, SimDuration(picoseconds: 10)))
        ..add(Dummy(4, SimDuration.zero));

      queueMap2
        ..add(Dummy(7, SimDuration(picoseconds: 10)))
        ..add(Dummy(5, SimDuration.zero))
        ..add(Dummy(8, SimDuration(picoseconds: 10)));

      print('queueMap1\n$queueMap1');
      print('queueMap2\n$queueMap2');

      queueMap1.addQueueMap(queueMap2);

      print('sum\n$queueMap1');

      print('Non destructive read loop');
      int expected = 3;
      for (Dummy d in queueMap1) {
        print('just read $d');
        expect(d.x, expected++);
      }

      expect(queueMap1.isNotEmpty, true);

      print('Destructive ( popFirst ) read loop');
      expected = 3;
      while (queueMap1.isNotEmpty) {
        Dummy d = queueMap1.first;
        print('seen first $d');
        queueMap1.removeFirst();
        print('popped $d');
        expect(d.x, expected++);
      }

      expect(queueMap1.isEmpty, true);

      queueMap2.removeWhere((d) => (d.x % 2) == 1);

      print('Even only\n$queueMap2');
      expect(queueMap2.every((d) => (d.x % 2) == 0), true);
    });
  });
  test('first queue test', () {
    QueueMap<SimDuration, Dummy> queueMap = QueueMap();

    queueMap
      ..add(Dummy(3, SimDuration.zero))
      ..add(Dummy(6, SimDuration(picoseconds: 10)))
      ..add(Dummy(4, SimDuration.zero))
      ..add(Dummy(7, SimDuration(picoseconds: 10)))
      ..add(Dummy(5, SimDuration.zero))
      ..add(Dummy(8, SimDuration(picoseconds: 10)));

    expect(queueMap.firstKey, SimDuration.zero);
    var removedQueue = queueMap.removeFirstQueue();

    print('queueMap\n${queueMap}');

    expect(queueMap.firstKey, SimDuration(picoseconds: 10));

    expect(removedQueue.toList(),
        [3, 4, 5].map((i) => Dummy(i, SimDuration.zero)));

    expect(queueMap.firstQueue.toList(),
        [6, 7, 8].map((i) => Dummy(i, SimDuration(picoseconds: 10))));
  });
}
