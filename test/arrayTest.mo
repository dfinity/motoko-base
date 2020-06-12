import Array "mo:base/Array";
import Prelude "mo:base/Prelude";
import Text "mo:base/Text";

Prelude.debugPrintLine("Array");

{
  Prelude.debugPrintLine("  append");

  let actual = Array.append<Int>([ 1, 2, 3 ], [ 4, 5, 6 ]);
  let expected = [ 1, 2, 3, 4, 5, 6 ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  apply");

  let ask = func (x : Text) : Text {
    x # "?";
  };

  let exclaim = func (x : Text) : Text {
    x # "!";
  };

  let actual = Array.apply<Text, Text>([ "good", "bad" ], [ ask, exclaim ]);
  let expected = [ "good?", "bad?", "good!", "bad!" ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  chain");

  let purePlusOne = func (x : Int) : [Int] {
    [ x + 1 ];
  };

  let actual = Array.chain<Int, Int>([ 0, 1, 2 ], purePlusOne);
  let expected = [ 1, 2, 3 ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  filter");

  let isEven = func (x : Int) : Bool {
    x % 2 == 0;
  };

  let actual = Array.filter<Nat>(isEven, [ 1, 2, 3, 4, 5, 6 ]);
  let expected = [ 2, 4, 6 ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  find");

  type Element = {
    key : Text;
    value : Int;
  };

  let xs = [
    { key = "a"; value = 0; },
    { key = "b"; value = 1; },
    { key = "c"; value = 2; },
  ];

  let b : ?Element = Array.find<Element>(xs, func (x : Element) : Bool {
    x.key == "b";
  });

  switch (b) {
    case (?element) {
      assert(element.key == "b" and element.value == 1);
    };
    case (_) {
      assert(false);
    };
  };
};

{
  Prelude.debugPrintLine("  foldLeft");

  let xs = [ "a", "b", "c" ];

  let actual = Array.foldLeft<Text, Text>(xs, "", Text.append);
  let expected = "abc";

  assert(actual == expected);
};

{
  Prelude.debugPrintLine("  foldRight");

  let xs = [ "a", "b", "c" ];

  let actual = Array.foldRight<Text, Text>(xs, "", Text.append);
  let expected = "abc";

  assert(actual == expected);
};

{
  Prelude.debugPrintLine("  freeze");

  var xs : [var Int] = [ var 1, 2, 3 ];

  let actual = Array.freeze<Int>(xs);
  let expected : [Int] = [ 1, 2, 3 ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  flatten");

  let xs = [ [ 1, 2, 3 ] ];

  let actual = Array.flatten<Int>(xs);
  let expected : [Int] = [ 1, 2, 3 ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  transform");

  let isEven = func (x : Int) : Bool {
    x % 2 == 0;
  };

  let actual = Array.transform<Int, Bool>([ 1, 2, 3, 4, 5, 6 ], isEven);
  let expected = [ false, true, false, true, false, true ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  mapEntries");

  let isEven = func (x : Int) : Bool {
    x % 2 == 0;
  };

  let xs = [ 1, 2, 3, 4, 5, 6 ];

  let actual = Array.mapEntries<Int, (Bool, Bool)>(
    xs, func (value : Int, index : Nat) : (Bool, Bool) {
      (isEven value, isEven index)
    });

  let expected = [
    (false, true),
    (true, false),
    (false, true),
    (true, false),
    (false, true),
    (true, false),
  ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i].0 == expected[i].0);
    assert(actual[i].1 == expected[i].1);
  };
};

{
  Prelude.debugPrintLine("  make");

  let actual = Array.make<Int>(0);
  let expected = [0];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  thaw");

  let xs : [Int] = [ 1, 2, 3 ];

  let actual = Array.thaw<Int>(xs);
  var expected : [Int] = [ 1, 2, 3 ];

  assert(actual.len() == expected.len());

  for (i in actual.keys()) {
    assert(actual[i] == expected[i]);
  };
};

{
  Prelude.debugPrintLine("  tabulateVar");

  // regression test for (fixed) issues in base cases, where func was called too often:

  let test0 = Array.tabulateVar<Nat>(0, func (i:Nat) { assert(false); 0 });
  let test1 = Array.tabulateVar<Nat>(1, func (i:Nat) { assert(i < 1); 0 });
  let test2 = Array.tabulateVar<Nat>(2, func (i:Nat) { assert(i < 2); 0 });
  let test3 = Array.tabulateVar<Nat>(3, func (i:Nat) { assert(i < 3); 0 });

};
