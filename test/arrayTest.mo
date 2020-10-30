import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

let findTest = {
  type Element = {
    key : Text;
    value : Int;
  };

  let xs = [
    { key = "a"; value = 0; },
    { key = "b"; value = 1; },
    { key = "c"; value = 2; },
  ];

  let actual : ?Element = Array.find<Element>(xs, func (x : Element) : Bool {
    x.key == "b";
  });

  let elementTestable : T.Testable<Element> = {
    display = func (e : Element) : Text {
      "{ key = " # T.textTestable.display(e.key) # ";" #
      " value = " # T.intTestable.display(e.value) #
      " }"
    };
    equals = func (e1 : Element, e2 : Element) : Bool =
      e1.key == e2.key and e1.value == e2.value;
  };

  Suite.test(
    "find",
    actual,
    M.equals<?Element>(T.optional(elementTestable, ?({ key = "b"; value = 1 })))
  )
};

let mapEntriesTest = {

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

  Suite.test(
    "mapEntries",
    actual,
    M.equals<[(Bool, Bool)]>(T.array(T.tuple2Testable(T.boolTestable, T.boolTestable), expected))
  )
};

let suite = Suite.suite("Array", [
  Suite.test(
    "append",
    Array.append<Int>([ 1, 2, 3 ], [ 4, 5, 6 ]),
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3, 4, 5, 6 ]))),
  Suite.test(
    "chain",
    {
      let purePlusOne = func (x : Int) : [Int] { [ x + 1 ] };
      Array.chain<Int, Int>([ 0, 1, 2 ], purePlusOne);
    },
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3 ]))
  ),
  Suite.test(
    "filter",
    {
      let isEven = func (x : Nat) : Bool { x % 2 == 0 };
      Array.filter([ 1, 2, 3, 4, 5, 6 ], isEven);
    },
    M.equals(T.array<Nat>(T.natTestable, [ 2, 4, 6 ]))
  ),
  Suite.test(
    "mapFilter",
    {
      let isEven = func (x : Nat) : ?Nat { if (x % 2 == 0) ?x else null };
      Array.mapFilter([ 1, 2, 3, 4, 5, 6 ], isEven);
    },
    M.equals(T.array<Nat>(T.natTestable, [ 2, 4, 6 ]))
  ),
  findTest,
  Suite.test(
    "foldLeft",
    Array.foldLeft<Text, Text>([ "a", "b", "c" ], "", Text.concat),
    M.equals(T.text("abc"))
  ),
  Suite.test(
    "foldRight",
    Array.foldRight<Text, Text>([ "a", "b", "c" ], "", Text.concat),
    M.equals(T.text("abc"))
  ),
  Suite.test(
    "freeze",
    {
      var xs : [var Int] = [ var 1, 2, 3 ];
      Array.freeze<Int>(xs);
    },
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3 ]))
  ),
  Suite.test(
    "flatten",
    Array.flatten<Int>([ [ 1, 2, 3 ] ]),
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3 ]))
  ),
  Suite.test(
    "map",
    {
      let isEven = func (x : Int) : Bool {
        x % 2 == 0;
      };

      Array.map<Int, Bool>([ 1, 2, 3, 4, 5, 6 ], isEven);
    },
    M.equals(T.array<Bool>(T.boolTestable, [ false, true, false, true, false, true ]))
  ),
  mapEntriesTest,
  Suite.test(
    "make",
    Array.make<Int>(0),
    M.equals(T.array<Int>(T.intTestable, [0]))
  ),
  Suite.test(
    "thaw",
    {
      let xs : [Int] = [ 1, 2, 3 ];
      Array.freeze(Array.thaw(xs))
    },
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3]))
  ),
  Suite.test(
    "tabulateVar",
    {
      // regression test for (fixed) issues in base cases, where func was called too often:
      let test0 = Array.tabulateVar<Nat>(0, func (i:Nat) { assert(false); 0 });
      let test1 = Array.tabulateVar<Nat>(1, func (i:Nat) { assert(i < 1); 0 });
      let test2 = Array.tabulateVar<Nat>(2, func (i:Nat) { assert(i < 2); 0 });
      let test3 = Array.tabulateVar<Nat>(3, func (i:Nat) { assert(i < 3); 0 });
      0
    },
    M.equals(T.nat(0))
  )
]);

Suite.run(suite);
