import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Debug "mo:base/Debug";

Debug.print("Iter");

{
  Debug.print("  range");

  let tests = [((0,-1), "", "0-1"), ((0,0), "0", "0"), ((0, 5), "012345", ""), ((5, 0), "", "543210")];
  for ((range, expected, revExpected) in tests.vals()) {
      var x = "";
      for (i in Iter.range(range)) {
          x := x # Nat.toText(i);
      };
      assert(x == expected);
      x := "";
      for (i in Iter.revRange(range)) {
          x := x # Int.toText(i);
      };
      assert(x == revExpected);      
  };
};

{
  Debug.print("  apply");

  let xs = [ "a", "b", "c", "d", "e", "f" ];

  var y = "";
  var z = 0;

  Iter.apply<Text>(xs.vals(), func (x : Text, i : Nat) {
    y := y # x;
    z += i;
  });

  assert(y == "abcdef");
  assert(z == 15);
};

{
  Debug.print("  map");

  let isEven = func (x : Int) : Bool {
    x % 2 == 0;
  };

  let _actual = Iter.map<Nat, Bool>([ 1, 2, 3 ].vals(), isEven);
  let actual = [var true, false, true];
  Iter.apply<Bool>(_actual, func (x, i) { actual[i] := x; });

  let expected = [false, true, false];

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Debug.print("  make");

  let x = 1;
  let y = Iter.make<Nat>(x);

  switch (y.next()) {
    case null { assert false; };
    case (?z) { assert (x == z); };
  };
};

{
  Debug.print("  fromArray");

  let expected = [1, 2, 3];
  let _actual = Iter.fromArray<Nat>(expected);
  let actual = [var 0, 0, 0];

  Iter.apply<Nat>(_actual, func (x, i) { actual[i] := x; });

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Debug.print("  fromArrayMut");

  let expected = [var 1, 2, 3];
  let _actual = Iter.fromArrayMut<Nat>(expected);
  let actual = [var 0, 0, 0];

  Iter.apply<Nat>(_actual, func (x, i) { actual[i] := x; });

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Debug.print("  fromList");

  let list : List.List<Nat> = ?(1, ?(2, ?(3, List.nil<Nat>())));
  let _actual = Iter.fromList<Nat>(list);
  let actual = [var 0, 0, 0];
  let expected = [1, 2, 3];

  Iter.apply<Nat>(_actual, func (x, i) { actual[i] := x; });

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Debug.print("  toArray");

  let expected = [1, 2, 3];
  let actual = Iter.toArray<Nat>(expected.vals());

  assert (actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Debug.print("  toArrayMut");

  let expected = [var 1, 2, 3];
  let actual = Iter.toArrayMut<Nat>(expected.vals());

  assert (actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Debug.print("  toList");

  let expected : List.List<Nat> = ?(1, ?(2, ?(3, List.nil<Nat>())));
  let actual = Iter.toList<Nat>([1, 2, 3].vals());
  assert List.equal<Nat>(expected, actual, func (x1, x2) { x1 == x2 });
};

{
  Debug.print("  toListWithSize");

  let expected : {
    size : Nat;
    list : List.List<Nat>;
  } = {
    size = 3;
    list = ?(1, ?(2, ?(3, List.nil<Nat>())));
  };

  let actual = Iter.toListWithSize<Nat>([1, 2, 3].vals());

  assert (expected.size == actual.size);
  assert List.equal<Nat>(expected.list, actual.list, func (x1, x2) { x1 == x2 });
};
