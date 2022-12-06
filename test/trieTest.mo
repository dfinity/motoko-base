import Trie "mo:base/Trie";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Debug "mo:base/Debug";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let test = Suite;

// Utilities to massage types between Trie and Matchers
func prettyArray(trie : Trie.Trie<Nat, Nat>) : [(Nat, Nat)] {
  Trie.toArray<Nat, Nat, (Nat, Nat)>(trie, func(k, v) = (k, v));
};
func arrayTest(array : [(Nat, Nat)]) : M.Matcher<[(Nat, Nat)]> {
  M.equals<[(Nat, Nat)]>(T.array<(Nat, Nat)>(T.tuple2Testable<Nat, Nat>(T.natTestable, T.natTestable), array));
};
func natKey(nat : Nat) : Trie.Key<Nat> { { hash = Hash.hash(nat); key = nat } };

// Sample tries for testing
var trie1 = Trie.empty<Nat, Nat>();
trie1 := Trie.put<Nat, Nat>(trie1, natKey(0), Nat.equal, 10).0;
trie1 := Trie.put<Nat, Nat>(trie1, natKey(2), Nat.equal, 12).0;
trie1 := Trie.put<Nat, Nat>(trie1, natKey(4), Nat.equal, 14).0;

var trie2 = Trie.empty<Nat, Nat>();
trie2 := Trie.put<Nat, Nat>(trie2, natKey(1), Nat.equal, 11).0;
trie2 := Trie.put<Nat, Nat>(trie2, natKey(3), Nat.equal, 13).0;

var trie3 = Trie.empty<Nat, Nat>();
trie3 := Trie.put<Nat, Nat>(trie3, natKey(1), Nat.equal, 21).0;
trie3 := Trie.put<Nat, Nat>(trie3, natKey(2), Nat.equal, 22).0;

// Matchers tests
let suite = Suite.suite(
  "Trie",
  [
    Suite.test(
      "empty trie size 0",
      Trie.size(Trie.empty()),
      M.equals(T.nat(0)),
    ),
    Suite.test(
      "empty trie array roundtrip",
      prettyArray(Trie.empty()),
      arrayTest([]),
    ),
    Suite.test(
      "put 1",
      prettyArray(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0),
      arrayTest([(0, 10)]),
    ),
    Suite.test(
      "put get 1",
      Trie.get(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal),
      M.equals(T.optional(T.natTestable, ?10)),
    ),
    Suite.test(
      "put find 1",
      Trie.find(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal),
      M.equals(T.optional(T.natTestable, ?10)),
    ),
    Suite.test(
      "merge",
      prettyArray(Trie.merge(trie1, trie3, Nat.equal)),
      arrayTest([(0, 10), (4, 14), (1, 21), (2, 12)]),
    ),
    Suite.test(
      "merge with empty",
      prettyArray(Trie.merge(trie1, Trie.empty(), Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14)]),
    ),
    Suite.test(
      "merge two empties",
      prettyArray(Trie.merge(Trie.empty(), Trie.empty(), Nat.equal)),
      arrayTest([]),
    ),
    Suite.test(
      "merge disjoint",
      prettyArray(Trie.mergeDisjoint(trie1, trie2, Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14), (1, 11), (3, 13)]),
    ),
    Suite.test(
      "merge disjoint",
      prettyArray(Trie.mergeDisjoint(trie1, Trie.empty(), Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14)]),
    ),
    Suite.test(
      "merge disjoint two empties",
      prettyArray(Trie.mergeDisjoint(Trie.empty(), Trie.empty(), Nat.equal)),
      arrayTest([]),
    ),
    Suite.test(
      "diff",
      prettyArray(Trie.diff(trie1, trie3, Nat.equal)),
      arrayTest([(0, 10), (4, 14)]),
    ),
    Suite.test(
      "diff non-commutative",
      prettyArray(Trie.diff(trie3, trie1, Nat.equal)),
      arrayTest([(1, 21)]),
    ),
    Suite.test(
      "diff empty right",
      prettyArray(Trie.diff(trie1, Trie.empty(), Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14)]),
    ),
    Suite.test(
      "diff empty left",
      prettyArray(Trie.diff(Trie.empty(), trie1, Nat.equal)),
      arrayTest([]),
    ),
    Suite.test(
      "disj",
      prettyArray(
        Trie.disj<Nat, Nat, Nat, Nat>(
          trie1,
          trie3,
          Nat.equal,
          func(v1, v2) {
            switch (v1, v2) {
              case (?v1, ?v2) v1 + v2; // add values to combine
              case (?v1, null) v1;
              case (null, ?v2) v2;
              case (null, null) Debug.trap "unreachable in disj";
            };
          },
        ),
      ),
      arrayTest([(0, 10), (4, 14), (1, 21), (2, 34)]),
    ),
    Suite.test(
      "disj with empty first",
      prettyArray(
        Trie.disj<Nat, Nat, Nat, Nat>(
          Trie.empty(),
          trie1,
          Nat.equal,
          func(v1, v2) {
            switch (v1, v2) {
              case (?v1, ?v2) v1 + v2; // add values to combine
              case (?v1, null) v1;
              case (null, ?v2) v2;
              case (null, null) Debug.trap "unreachable in disj";
            };
          },
        ),
      ),
      arrayTest([(0, 10), (2, 12), (4, 14)]),
    ),
    Suite.test(
      "disj with empty second",
      prettyArray(
        Trie.disj<Nat, Nat, Nat, Nat>(
          trie1,
          Trie.empty(),
          Nat.equal,
          func(v1, v2) {
            switch (v1, v2) {
              case (?v1, ?v2) v1 + v2; // add values to combine
              case (?v1, null) v1;
              case (null, ?v2) v2;
              case (null, null) Debug.trap "unreachable in disj";
            };
          },
        ),
      ),
      arrayTest([(0, 10), (2, 12), (4, 14)]),
    ),
    Suite.test(
      "disj two empties",
      prettyArray(
        Trie.disj<Nat, Nat, Nat, Nat>(
          Trie.empty(),
          Trie.empty(),
          Nat.equal,
          func(v1, v2) {
            switch (v1, v2) {
              case (?v1, ?v2) v1 + v2; // add values to combine
              case (?v1, null) v1;
              case (null, ?v2) v2;
              case (null, null) Debug.trap "unreachable in disj";
            };
          },
        ),
      ),
      arrayTest([]),
    ),
    Suite.test(
      "join",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(trie1, trie3, Nat.equal, Nat.add),
      ),
      arrayTest([(2, 34)]),
    ),
    Suite.test(
      "join with empty first",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(Trie.empty(), trie1, Nat.equal, Nat.add),
      ),
      arrayTest([]),
    ),
    Suite.test(
      "join with empty second",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(trie1, Trie.empty(), Nat.equal, Nat.add),
      ),
      arrayTest([]),
    ),
    Suite.test(
      "join with two empties",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(Trie.empty(), Trie.empty(), Nat.equal, Nat.add),
      ),
      arrayTest([]),
    ),
    Suite.test(
      "foldUp",
      Trie.foldUp<Nat, Nat, Nat>(trie1, Nat.mul, Nat.add, 1),
      M.equals(T.nat(2520)),
    ), // 1 * (0 + 10) * (2 + 12) * (4 + 14)
    Suite.test(
      "foldUp empty",
      Trie.foldUp<Nat, Nat, Nat>(Trie.empty(), Nat.mul, Nat.add, 1),
      M.equals(T.nat(1)),
    ),
    Suite.test(
      "prod",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(trie1, trie3, func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([(1, 31), (2, 32), (3, 33), (4, 34), (5, 35), (6, 36)]),
    ),
    Suite.test(
      "prod first empty",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(Trie.empty(), trie3, func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([]),
    ),
    Suite.test(
      "prod second empty",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(trie1, Trie.empty(), func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([]),
    ),
    Suite.test(
      "prod both empty",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(Trie.empty(), Trie.empty(), func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([]),
    ),
    Suite.test(
      "iter",
      Iter.toArray(Trie.iter(trie1)),
      arrayTest([(0, 10), (2, 12), (4, 14)]),
    ),
    Suite.test(
      "iter empty",
      Iter.toArray(Trie.iter(Trie.empty())),
      arrayTest([]),
    ),
    Suite.test(
      "fold",
      Trie.fold<Nat, Nat, Nat>(trie1, func(k, v, acc) = k + v + acc, 0),
      M.equals(T.nat(42)),
    ), // 0 + 10 + 2 + 12 + 4 + 14
    Suite.test(
      "fold empty",
      Trie.fold<Nat, Nat, Nat>(Trie.empty(), func(k, v, acc) = k + v + acc, 0),
      M.equals(T.nat(0)),
    ),
    Suite.test(
      "some true",
      Trie.some<Nat, Nat>(trie1, func(k, v) = k * v == 0),
      M.equals(T.bool(true)),
    ),
    Suite.test(
      "some false",
      Trie.some<Nat, Nat>(trie1, func(k, _) = k % 2 != 0),
      M.equals(T.bool(false)),
    ),
    Suite.test(
      "some empty",
      Trie.some<Nat, Nat>(Trie.empty(), func _ = true),
      M.equals(T.bool(false)),
    ),
    Suite.test(
      "all true",
      Trie.all<Nat, Nat>(trie1, func(k, _) = k % 2 == 0),
      M.equals(T.bool(true)),
    ),
    Suite.test(
      "all false",
      Trie.all<Nat, Nat>(trie1, func(k, v) = k * v == 0),
      M.equals(T.bool(false)),
    ),
    Suite.test(
      "all empty",
      Trie.all<Nat, Nat>(Trie.empty(), func _ = false),
      M.equals(T.bool(true)),
    ),
    // FIXME test nth
    Suite.test(
      "isEmpty false",
      Trie.isEmpty<Nat, Nat>(trie1),
      M.equals(T.bool(false)),
    ),
    Suite.test(
      "isEmpty true",
      Trie.isEmpty<Nat, Nat>(Trie.empty()),
      M.equals(T.bool(true)),
    ),
    Suite.test(
      "isEmpty put remove",
      Trie.isEmpty<Nat, Nat>(
        Trie.remove<Nat, Nat>(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal).0,
      ),
      M.equals(T.bool(true)),
    ),
    Suite.test(
      "filter",
      prettyArray(Trie.filter<Nat, Nat>(trie1, func(k, v) = k * v == 0)),
      arrayTest([(0, 10)]),
    ),
    Suite.test(
      "filter all",
      prettyArray(Trie.filter<Nat, Nat>(trie1, func _ = false)),
      arrayTest([]),
    ),
    Suite.test(
      "filter none",
      prettyArray(Trie.filter<Nat, Nat>(trie1, func _ = true)),
      arrayTest([(0, 10), (2, 12), (4, 14)]),
    ),
  ],
);

// FIXME add tests for bitpos functions
// FIXME test structure of resulting trie, instead of flattening to array

Suite.run(suite);

// Assertion tests
debug {
  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;

  func key(i : Nat) : Key<Text> {
    let t = Nat.toText i;
    { key = t; hash = Text.hash t };
  };

  let max = 100;

  // put k-v elements, one by one (but hashes are expected random).
  Debug.print "Trie.put";
  var t : Trie<Text, Nat> = Trie.empty();
  for (i in Iter.range(0, max - 1)) {
    let (t1_, x) = Trie.put<Text, Nat>(t, key i, Text.equal, i);
    assert (Option.isNull(x));
    assert Trie.isValid(t1_, false);
    t := t1_;
  };
  assert Trie.size(t) == max;

  // remove all elements, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.remove";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      let (t1_, x) = Trie.remove<Text, Nat>(t1, key i, Text.equal);
      assert Trie.isValid(t1_, false);
      assert (Option.isSome(x));
      t1 := t1_;
    };
  };

  // filter all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.filter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.filter(t1, func(t : Text, n : Nat) : Bool { n != i });
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat);
    };
  };

  // filter-map all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.mapFilter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.mapFilter(
        t1,
        func(t : Text, n : Nat) : ?Nat {
          if (n != i) ?n else null;
        },
      );
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat);
    };
  };
};
