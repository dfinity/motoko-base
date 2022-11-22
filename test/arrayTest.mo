import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import M "mo:matchers/Matchers";
import Nat "../src/Nat";
import Result "mo:base/Result";
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Text "mo:base/Text";

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

func arrayNat(xs : [Nat]) : T.TestableItem<[Nat]> {
  T.array(T.natTestable, xs)
};

let suite = Suite.suite("Array", [
  mapResult,
  Suite.test(
    "init",
    Array.freeze(Array.init<Int>(3, 4)),
    M.equals(T.array<Int>(T.intTestable, [4, 4, 4]))),
  Suite.test(
    "init empty",
    Array.freeze(Array.init<Int>(0, 4)),
    M.equals(T.array<Int>(T.intTestable, []))),
  Suite.test(
    "tabulate",
    Array.tabulate<Int>(3, func (i : Nat)= i * 2),
    M.equals(T.array<Int>(T.intTestable, [0, 2, 4]))),
  Suite.test(
    "tabulate empty",
    Array.tabulate<Int>(0, func (i : Nat) = i),
    M.equals(T.array<Int>(T.intTestable, []))),
  Suite.test(
    "tabulateVar",
    Array.freeze(Array.tabulateVar<Int>(3, func (i : Nat)= i * 2)),
    M.equals(T.array<Int>(T.intTestable, [0, 2, 4]))),
  Suite.test(
    "tabulateVar empty",
    Array.freeze(Array.tabulateVar<Int>(0, func (i : Nat) = i)),
    M.equals(T.array<Int>(T.intTestable, []))),
  Suite.test(
    "freeze",
    Array.freeze<Int>([ var 1, 2, 3 ]),
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3 ]))
  ),
  Suite.test(
    "freeze empty",
    Array.freeze<Int>([var]),
    M.equals(T.array<Int>(T.intTestable, []))
  ),
  Suite.test(
    "thaw round trip",
    Array.freeze(Array.thaw<Int>([1, 2, 3])),
    M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
  ),
  Suite.test(
    "thaw round trip empty",
    Array.freeze(Array.thaw<Int>([])),
    M.equals(T.array<Int>(T.intTestable, []))
  ),
  Suite.test(
    "equal",
    Array.equal<Int>([1, 2, 3], [1, 2, 3], Int.equal),
    M.equals(T.bool(true))
  ),
  Suite.test(
    "equal empty",
    Array.equal<Int>([], [], Int.equal),
    M.equals(T.bool(true))
  ),
  Suite.test(
    "not equal one empty",
    Array.equal<Int>([], [2, 3], Int.equal),
    M.equals(T.bool(false))
  ),
  Suite.test(
    "not equal different lengths",
    Array.equal<Int>([1, 2, 3], [2, 4], Int.equal),
    M.equals(T.bool(false))
  ),
  Suite.test(
    "not equal same lengths",
    Array.equal<Int>([1, 2, 3], [1, 2, 4], Int.equal),
    M.equals(T.bool(false))
  ),
  Suite.test(
    "find",
    Array.find<Nat>([1, 9, 4, 8], func x = x == 9),
    M.equals(T.optional(T.natTestable, ?9))
  ),
  Suite.test(
    "find fail",
    Array.find<Nat>([1, 9, 4, 8], func _ = false),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
  Suite.test(
    "find empty",
    Array.find<Nat>([], func _ = true),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
  Suite.test(
    "append",
    Array.append<Int>([1, 2, 3], [4, 5, 6]),
    M.equals(T.array<Int>(T.intTestable, [ 1, 2, 3, 4, 5, 6 ]))
  ),
  Suite.test(
    "append first empty",
    Array.append<Int>([], [4, 5, 6]),
    M.equals(T.array<Int>(T.intTestable, [4, 5, 6]))
  ),
  Suite.test(
    "append second empty",
    Array.append<Int>([1, 2, 3], []),
    M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
  ),
  Suite.test(
    "append both empty",
    Array.append<Int>([], []),
    M.equals(T.array<Int>(T.intTestable, []))
  ),
  Suite.test("sort",
    Array.sort([2, 3, 1], Nat.compare),
    M.equals(arrayNat([1, 2, 3]))
  ),
  Suite.test("sort empty array",
    Array.sort([], Nat.compare),
    M.equals(arrayNat([]))
  ),
  Suite.test("sort already sorted",
    Array.sort([1, 2, 3, 4, 5], Nat.compare),
    M.equals(arrayNat([1, 2, 3, 4, 5]))
  ),
  Suite.test("sort repeated elements",
    Array.sort([2, 2, 2, 2, 2], Nat.compare),
    M.equals(arrayNat([2, 2, 2, 2, 2]))
  ),
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
    "filter empty",
    do {
      let isEven = func (x : Nat) : Bool { x % 2 == 0 };
      Array.filter([] : [Nat], isEven);
    },
    M.equals(T.array<Nat>(T.natTestable, [] : [Nat]))
  ),
  Suite.test(
    "mapFilter",
    do {
      let isEven = func (x : Nat) : ?Nat { if (x % 2 == 0) ?x else null };
      Array.mapFilter([ 1, 2, 3, 4, 5, 6 ], isEven);
    },
    M.equals(T.array<Nat>(T.natTestable, [ 2, 4, 6 ]))
  ),
  Suite.test(
    "mapFilter empty",
    do {
      let isEven = func (x : Nat) : ?Nat { if (x % 2 == 0) ?x else null };
      Array.mapFilter([] : [Nat], isEven);
    },
    M.equals(T.array<Nat>(T.natTestable, [] : [Nat]))
  ),
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
  ),
  Suite.test(
    "reverse",
    Array.reverse<Nat>([0, 1, 2, 3]),
    M.equals(T.array<Nat>(T.natTestable, [3, 2, 1, 0]))
  )
]);

Suite.run(suite);
