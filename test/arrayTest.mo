import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import M "mo:matchers/Matchers";
import Nat "../src/Nat";
import Result "mo:base/Result";
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Text "mo:base/Text";

let findTest = do {
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

let mapEntriesTest = do {

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

func makeNatural(x : Int) : Result.Result<Nat, Text> =
  if (x >= 0) { #ok(Int.abs(x)) } else { #err(Int.toText(x) # " is not a natural number.") };

func arrayRes(itm : Result.Result<[Nat], Text>) : T.TestableItem<Result.Result<[Nat], Text>> {
  let resT = T.resultTestable(T.arrayTestable<Nat>(T.intTestable), T.textTestable);
  { display = resT.display; equals = resT.equals; item = itm }
};

let mapResult = Suite.suite("mapResult", [
  Suite.test("empty array",
    Array.mapResult<Int, Nat, Text>([], makeNatural),
    M.equals(arrayRes(#ok([])))
  ),
  Suite.test("success",
    Array.mapResult<Int, Nat, Text>([ 1, 2, 3 ], makeNatural),
    M.equals(arrayRes(#ok([1, 2, 3])))
  ),
  Suite.test("fail fast",
    Array.mapResult<Int, Nat, Text>([ -1, 2, 3 ], makeNatural),
    M.equals(arrayRes(#err("-1 is not a natural number.")))
  ),
  Suite.test("fail last",
    Array.mapResult<Int, Nat, Text>([ 1, 2, -3 ], makeNatural),
    M.equals(arrayRes(#err("-3 is not a natural number.")))
  ),
]);

func arrayNat(xs : [Nat]) : T.TestableItem<[A]> {
  T.array(T.natTestable, xs)
};

let sort = Suite.suite("sort", [
  Suite.test("empty array",
    Array.sort([], Nat.compare),
    M.equals(arrayNat([]))
  ),
  Suite.test("already sorted",
    Array.sort([1, 2, 3, 4, 5], Nat.compare),
    M.equals(arrayNat([1, 2, 3, 4, 5]))
  ),
  Suite.test("reversed array",
    Array.sort([3, 2, 1], Nat.compare),
    M.equals(arrayNat([1, 2, 3]))
  ),
  Suite.test("repeated elements",
    Array.sort([2, 2, 2, 2, 2], Nat.compare),
    M.equals(arrayNat([2, 2, 2, 2, 2]))
  )
]);

let suite = Suite.suite("Array", [
  mapResult,
  sort,
  Suite.test(
    "append",
    Array.append<Int>([ 1, 2, 3 ], [ 4, 5, 6 ]),
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3, 4, 5, 6 ]))),
  Suite.test(
    "chain",
    do {
      let purePlusOne = func (x : Int) : [Int] { [ x + 1 ] };
      Array.chain<Int, Int>([ 0, 1, 2 ], purePlusOne);
    },
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3 ]))
  ),
  Suite.test(
    "filter",
    do {
      let isEven = func (x : Nat) : Bool { x % 2 == 0 };
      Array.filter([ 1, 2, 3, 4, 5, 6 ], isEven);
    },
    M.equals(T.array<Nat>(T.natTestable, [ 2, 4, 6 ]))
  ),
  Suite.test(
    "mapFilter",
    do {
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
    do {
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
    do {
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
    do {
      let xs : [Int] = [ 1, 2, 3 ];
      Array.freeze(Array.thaw<Int>(xs))
    },
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3]))
  ),
  Suite.test(
    "tabulateVar",
    do {
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
