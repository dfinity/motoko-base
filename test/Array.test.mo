import Array "mo:base/Array";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let suite = Suite.suite(
  "Array",
  [
    Suite.test(
      "init",
      Array.freeze(Array.init<Int>(3, 4)),
      M.equals(T.array<Int>(T.intTestable, [4, 4, 4]))
    ),
    Suite.test(
      "init empty",
      Array.freeze(Array.init<Int>(0, 4)),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "tabulate",
      Array.tabulate<Int>(3, func(i : Nat) = i * 2),
      M.equals(T.array<Int>(T.intTestable, [0, 2, 4]))
    ),
    Suite.test(
      "tabulate empty",
      Array.tabulate<Int>(0, func(i : Nat) = i),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "tabulateVar",
      Array.freeze(Array.tabulateVar<Int>(3, func(i : Nat) = i * 2)),
      M.equals(T.array<Int>(T.intTestable, [0, 2, 4]))
    ),
    Suite.test(
      "tabulateVar empty",
      Array.freeze(Array.tabulateVar<Int>(0, func(i : Nat) = i)),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "freeze",
      Array.freeze<Int>([var 1, 2, 3]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
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
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 4, 5, 6]))
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
    Suite.test(
      "sort",
      Array.sort([2, 3, 1], Nat.compare),
      M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
    ),
    Suite.test(
      "sort empty array",
      Array.sort([], Nat.compare),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "sort already sorted",
      Array.sort([1, 2, 3, 4, 5], Nat.compare),
      M.equals(T.array<Nat>(T.natTestable, [1, 2, 3, 4, 5]))
    ),
    Suite.test(
      "sort repeated elements",
      Array.sort([2, 2, 2, 2, 2], Nat.compare),
      M.equals(T.array<Nat>(T.natTestable, [2, 2, 2, 2, 2]))
    ),
    Suite.test(
      "sortInPlace",
      do {
        let array = [var 2, 3, 1];
        Array.sortInPlace(array, Nat.compare);
        Array.freeze(array)
      },
      M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
    ),
    Suite.test(
      "sortInPlace empty",
      do {
        let array = [var];
        Array.sortInPlace(array, Nat.compare);
        Array.freeze(array)
      },
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "sortInPlace already sorted",
      do {
        let array = [var 1, 2, 3, 4, 5];
        Array.sortInPlace(array, Nat.compare);
        Array.freeze(array)
      },
      M.equals(T.array<Nat>(T.natTestable, [1, 2, 3, 4, 5]))
    ),
    Suite.test(
      "sortInPlace repeated elements",
      do {
        let array = [var 2, 2, 2, 2, 2];
        Array.sortInPlace(array, Nat.compare);
        Array.freeze(array)
      },
      M.equals(T.array<Nat>(T.natTestable, [2, 2, 2, 2, 2]))
    ),
    Suite.test(
      "reverse",
      Array.reverse<Nat>([0, 1, 2, 2, 3]),
      M.equals(T.array<Nat>(T.natTestable, [3, 2, 2, 1, 0]))
    ),
    Suite.test(
      "reverse empty",
      Array.reverse<Nat>([]),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "reverse singleton",
      Array.reverse<Nat>([0]),
      M.equals(T.array<Nat>(T.natTestable, [0]))
    ),
    Suite.test(
      "map",
      Array.map<Nat, Bool>([1, 2, 3], func x = x % 2 == 0),
      M.equals(T.array<Bool>(T.boolTestable, [false, true, false]))
    ),
    Suite.test(
      "map empty",
      Array.map<Nat, Bool>([], func x = x % 2 == 0),
      M.equals(T.array<Bool>(T.boolTestable, []))
    ),
    Suite.test(
      "filter",
      Array.filter<Nat>([1, 2, 3, 4, 5, 6], func x = x % 2 == 0),
      M.equals(T.array<Nat>(T.natTestable, [2, 4, 6]))
    ),
    Suite.test(
      "filter empty",
      Array.filter<Nat>([], func x = x % 2 == 0),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "mapEntries",
      Array.mapEntries<Nat, Nat>([1, 2, 3], func(x, i) = x + i),
      M.equals(T.array<Nat>(T.natTestable, [1, 3, 5]))
    ),
    Suite.test(
      "mapEntries empty",
      Array.mapEntries<Nat, Nat>([], func(x, i) = x + i),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "mapFilter",
      Array.mapFilter<Nat, Nat>([1, 2, 3, 4, 5, 6], func x { if (x % 2 == 0) ?x else null }),
      M.equals(T.array<Nat>(T.natTestable, [2, 4, 6]))
    ),
    Suite.test(
      "mapFilter keep all",
      Array.mapFilter<Nat, Nat>([1, 2, 3], func x = ?x),
      M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
    ),
    Suite.test(
      "mapFilter keep none",
      Array.mapFilter<Nat, Nat>([1, 2, 3], func _ = null),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "mapFilter empty",
      Array.mapFilter<Nat, Nat>([], func x { if (x % 2 == 0) ?x else null }),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "mapResult",
      Array.mapResult<Int, Nat, Text>(
        [1, 2, 3],
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result<[Nat], Text>(T.arrayTestable(T.natTestable), T.textTestable, #ok([1, 2, 3])))
    ),
    Suite.test(
      "mapResult fail first",
      Array.mapResult<Int, Nat, Text>(
        [-1, 2, 3],
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result<[Nat], Text>(T.arrayTestable(T.natTestable), T.textTestable, #err "error message"))
    ),
    Suite.test(
      "mapResult fail last",
      Array.mapResult<Int, Nat, Text>(
        [1, 2, -3],
        func x { if (x >= 0) { #ok(Int.abs x) } else { #err "error message" } }
      ),
      M.equals(T.result<[Nat], Text>(T.arrayTestable(T.natTestable), T.textTestable, #err "error message"))
    ),
    Suite.test(
      "mapResult empty",
      Array.mapResult<Nat, Nat, Text>(
        [],
        func x = #ok x
      ),
      M.equals(T.result<[Nat], Text>(T.arrayTestable(T.natTestable), T.textTestable, #ok([])))
    ),
    Suite.test(
      "chain",
      Array.chain<Int, Int>([0, 1, 2], func x = [x, -x]),
      M.equals(T.array<Int>(T.intTestable, [0, 0, 1, -1, 2, -2]))
    ),
    Suite.test(
      "chain empty",
      Array.chain<Int, Int>([], func x = [x, -x]),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "foldLeft",
      Array.foldLeft<Text, Text>(["a", "b", "c"], "", Text.concat),
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "foldLeft empty",
      Array.foldLeft<Text, Text>([], "base", Text.concat),
      M.equals(T.text("base"))
    ),
    Suite.test(
      "foldRight",
      Array.foldRight<Text, Text>(["a", "b", "c"], "", func(x, acc) = acc # x),
      M.equals(T.text("cba"))
    ),
    Suite.test(
      "foldRight empty",
      Array.foldRight<Text, Text>([], "base", Text.concat),
      M.equals(T.text("base"))
    ),
    Suite.test(
      "flatten",
      Array.flatten<Int>([[1, 2, 3], [], [1]]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten empty start",
      Array.flatten<Int>([[], [1, 2, 3], [], [1]]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten empty end",
      Array.flatten<Int>([[1, 2, 3], [], [1], []]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3, 1]))
    ),
    Suite.test(
      "flatten singleton",
      Array.flatten<Int>([[1, 2, 3]]),
      M.equals(T.array<Int>(T.intTestable, [1, 2, 3]))
    ),
    Suite.test(
      "flatten empty",
      Array.flatten<Int>([[]]),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "flatten empty",
      Array.flatten<Int>([]),
      M.equals(T.array<Int>(T.intTestable, []))
    ),
    Suite.test(
      "make",
      Array.make<Int>(0),
      M.equals(T.array<Int>(T.intTestable, [0]))
    ),
    Suite.test(
      "vals",
      do {
        var sum = 0;
        for (x in Array.vals([1, 2, 3])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(6))
    ),
    Suite.test(
      "vals empty",
      do {
        var sum = 0;
        for (x in Array.vals([])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(0))
    ),
    Suite.test(
      "keys",
      do {
        var sum = 0;
        for (x in Array.keys([1, 2, 3])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(3))
    ),
    Suite.test(
      "keys empty",
      do {
        var sum = 0;
        for (x in Array.keys([])) {
          sum += x
        };
        sum
      },
      M.equals(T.nat(0))
    )
  ]
);

Suite.run(suite)
