import Prim "mo:⛔";
import B "mo:base/Buffer";
import I "mo:base/Iter";
import O "mo:base/Option";
import Blob "mo:base/Blob";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

// test repeated growing
let a = B.Buffer<Nat>(3);
for (i in I.range(0, 123)) {
  a.add(i);
};
for (i in I.range(0, 123)) {
  assert (a.get(i) == i);
};


// test repeated appending
let b = B.Buffer<Nat>(3);
for (i in I.range(0, 123)) {
  b.append(a);
};

Prim.debugPrint(debug_show(a.toArray()));
Prim.debugPrint(debug_show(b.toArray()));

// test repeated removing
for (i in I.revRange(123, 0)) {
    assert(O.unwrap(a.removeLast()) == i);
};
O.assertNull(a.removeLast());

func natArrayIter(elems:[Nat]) : I.Iter<Nat> = object {
  var pos = 0;
  let count = elems.size();
  public func next() : ?Nat {
    if (pos == count) { null } else {
      let elem = ?elems[pos];
      pos += 1;
      elem
    }
  }
};

func natVarArrayIter(elems:[var Nat]) : I.Iter<Nat> = object {
  var pos = 0;
  let count = elems.size();
  public func next() : ?Nat {
    if (pos == count) { null } else {
      let elem = ?elems[pos];
      pos += 1;
      elem
    }
  }
};

func natIterEq(a:I.Iter<Nat>, b:I.Iter<Nat>) : Bool {
   switch (a.next(), b.next()) {
     case (null, null) { true };
     case (?x, ?y) {
       if (x == y) { natIterEq(a, b) }
       else { false }
     };
     case (_, _) { false };
   }
};

// regression test: buffers with extra space are converted to arrays of the correct length
do {
  let bigLen = 100;
  let len = 3;
  let c = B.Buffer<Nat>(bigLen);
  assert (len < bigLen);
  for (i in I.range(0, len - 1)) {
    Prim.debugPrint(debug_show(i));
    c.add(i);
  };
  assert (c.size() == len);
  assert (c.toArray().size() == len);
  assert (natIterEq(c.vals(), natArrayIter(c.clone().toArray())));
  assert (c.toVarArray().size() == len);
  assert (natIterEq(c.vals(), natVarArrayIter(c.clone().toVarArray())));
};

// regression test: initially-empty buffers grow, element-by-element
do {
  let c = B.Buffer<Nat>(0);
  assert (c.toArray().size() == 0);
  assert (c.toVarArray().size() == 0);
  c.add(0);
  assert (c.toArray().size() == 1);
  assert (c.toVarArray().size() == 1);
  c.add(0);
  assert (c.toArray().size() == 2);
  assert (c.toVarArray().size() == 2);
};

// blob conversion test
do {
  let b = B.fromBlob(Blob.fromArray([0, 1, 2, 3]));
  B.appendBlob(b, Blob.fromArray([4, 5, 6]));
  assert (B.toBlob(b) == Blob.fromArray([0, 1, 2, 3, 4, 5, 6]));
};

let {run;test;suite} = Suite;
run(suite("array",
[
  test(
    "fromArray",
    B.fromArray<Nat>([0, 1, 2, 3]).toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3]))
  ),
  test(
    "fromVarArray",
    B.fromVarArray<Nat>([var 0, 1, 2, 3]).toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3]))
  )
]));
