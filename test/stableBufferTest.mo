import Prim "mo:⛔";
import B "mo:base/StableBuffer";
import I "mo:base/Iter";
import O "mo:base/Option";

// test repeated growing
let a = B.empty<Nat>();
for (i in I.range(0, 123)) {
  B.add(a, i);
};
for (i in I.range(0, 123)) {
  assert (B.get(a, i) == i);
};


// test repeated appending
let b = B.empty<Nat>();
for (i in I.range(0, 123)) {
  B.append(b, a);
};

Prim.debugPrint(debug_show(B.toArray(a)));
Prim.debugPrint(debug_show(B.toArray(b)));

// test repeated removing
for (i in I.revRange(123, 0)) {
    assert(O.unwrap(B.removeLast(a)) == i);
};
O.assertNull(B.removeLast(a));

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
  let elems = [var 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let bigLen = elems.size();
  let len = 3;
  let c : B.Buffer<Nat> = { var count = 0; var elems };
  assert (len < bigLen);
  for (i in I.range(0, len - 1)) {
    Prim.debugPrint(debug_show(i));
    B.add(c, i);
  };
  assert (B.size(c) == len);
  assert (B.toArray(c).size() == len);
  assert (natIterEq(B.vals(c), natArrayIter(B.toArray(B.clone(c)))));
  assert (B.toVarArray(c).size() == len);
  assert (natIterEq(B.vals(c), natVarArrayIter(B.toVarArray(B.clone(c)))));
};

// regression test: initially-empty buffers grow, element-by-element
do {
  let c = B.empty<Nat>();
  assert (B.toArray(c).size() == 0);
  assert (B.toVarArray(c).size() == 0);
  B.add(c, 0);
  assert (B.toArray(c).size() == 1);
  assert (B.toVarArray(c).size() == 1);
  B.add(c, 0);
  assert (B.toArray(c).size() == 2);
  assert (B.toVarArray(c).size() == 2);
};
