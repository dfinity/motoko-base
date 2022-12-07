import H "mo:base/Heap";
import I "mo:base/Iter";
import O "mo:base/Option";
import Int "mo:base/Int";

let order = Int.compare;

do {
  var pq = H.Heap<Int>(order);
  for (i in I.revRange(100, 0)) {
    pq.put(i);
    let x = pq.peekMin();
    assert (O.unwrap(x) == i);
  };
  for (i in I.range(0, 100)) {
    pq.put(i);
    let x = pq.peekMin();
    assert (O.unwrap(x) == 0);
  };
  for (i in I.range(0, 100)) {
    pq.deleteMin();
    let x = pq.peekMin();
    pq.deleteMin();
    assert (O.unwrap(x) == i);
  };
  O.assertNull(pq.peekMin());
};

// fromIter
do {
  do {
    let iter = [5, 10, 9, 7, 3, 8, 1, 0, 2, 4, 6].vals();
    let pq = H.fromIter<Int>(iter, order);
    for (i in I.range(0, 10)) {
      let x = pq.peekMin();
      assert (O.unwrap(x) == i);
      pq.deleteMin();
    };
    O.assertNull(pq.peekMin());
  };

  do {
    let pq = H.fromIter<Int>([].vals(), order);
    O.assertNull(pq.peekMin());
  };

  do {
    let pq = H.fromIter<Int>([100].vals(), order);
    assert (O.unwrap(pq.peekMin()) == 100);
  };
};
