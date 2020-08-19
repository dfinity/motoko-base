import Prim "mo:prim";
import B "mo:base/Buffer";
import I "mo:base/Iter";
import O "mo:base/Option";
import Debug "mo:base/Debug";

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
{
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
{
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

// regression test: self-append does not diverge
{
  let c = B.Buffer<Nat>(0);
  let d = B.Buffer<Nat>(0);

  c.add(1); d.add(1);
  c.add(2); d.add(2);
  c.add(3); d.add(3);

  Debug.print "append test 1: cloning avoids the issue"
  d.append(d.clone());
  Debug.print "append test 2: cloning not necessary"
  c.append(c);
  Debug.print "success"

  // to do -- two buffers are equal
};
