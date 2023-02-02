import Heap "mo:base/Heap";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Stack "mo:base/Stack";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

// FIXME put this in the Heap module in a separate PR
func toIter<X>(heap : Heap.Heap<X>) : Iter.Iter<X> {
  let stack = Stack.Stack<Heap.Tree<X>>();
  stack.push(heap.share());
  func next() : ?X {
    switch (stack.pop()) {
      case (null) {
        null
      };
      // FIXME this iterator is not in order
      case (?(_, element, left, right)) {
        stack.push(tree.left);
        stack.push(tree.right);
        ?element
      }
    }
  }
};

// Test data
func newEmptyHeap() : Heap.Heap<Nat> {
  Heap.Heap<Nat>(Nat.compare)
};

func newSingletonHeap() : Heap.Heap<Nat> {
  let heap = newEmptyHeap();
  heap.put(1);
  heap
};

func newHeap() : Heap.Heap<Nat> {
  let heap = newEmptyHeap();
  heap.put(1);
  heap.put(2);
  heap.put(3);
  heap
};

// Test suite
let suite = Suite.suite(
  "Heap",
  [
    Suite.test(
      "init",
      Array.freeze(Array.init<Int>(3, 4)),
      M.equals(T.array<Int>(T.intTestable, [4, 4, 4]))
    )
  ]
);

Suite.run(suite);

// do {
//   var pq = H.Heap<Int>(order);
//   for (i in I.revRange(100, 0)) {
//     pq.put(i);
//     let x = pq.peekMin();
//     assert (O.unwrap(x) == i)
//   };
//   for (i in I.range(0, 100)) {
//     pq.put(i);
//     let x = pq.peekMin();
//     assert (O.unwrap(x) == 0)
//   };
//   for (i in I.range(0, 100)) {
//     pq.deleteMin();
//     let x = pq.peekMin();
//     pq.deleteMin();
//     assert (O.unwrap(x) == i)
//   };
//   O.assertNull(pq.peekMin())
// };

// // fromIter
// do {
//   do {
//     let iter = [5, 10, 9, 7, 3, 8, 1, 0, 2, 4, 6].vals();
//     let pq = H.fromIter<Int>(iter, order);
//     for (i in I.range(0, 10)) {
//       let x = pq.peekMin();
//       assert (O.unwrap(x) == i);
//       pq.deleteMin()
//     };
//     O.assertNull(pq.peekMin())
//   };

//   do {
//     let pq = H.fromIter<Int>([].vals(), order);
//     O.assertNull(pq.peekMin())
//   };

//   do {
//     let pq = H.fromIter<Int>([100].vals(), order);
//     assert (O.unwrap(pq.peekMin()) == 100)
//   }
// }
