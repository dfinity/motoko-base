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
  Trie.toArray<Nat, Nat, (Nat, Nat)>(trie, func(k, v) = (k, v))
};
func arrayTest(array : [(Nat, Nat)]) : M.Matcher<[(Nat, Nat)]> {
  M.equals<[(Nat, Nat)]>(T.array<(Nat, Nat)>(T.tuple2Testable<Nat, Nat>(T.natTestable, T.natTestable), array))
};
func natKey(nat : Nat) : Trie.Key<Nat> {
  { hash = Hash.hash(nat); key = nat }
};

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
let suite = Suite.suite("Array", [
  Suite.test(
    "empty trie size 0",
    Trie.size(Trie.empty()),
    M.equals(T.nat(0))),
  Suite.test(
    "empty trie array roundtrip",
    prettyArray(Trie.empty()),
    arrayTest([])),
  Suite.test(
    "put 1",
    prettyArray(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0),
    arrayTest([(0, 10)])),
  Suite.test(
    "put get 1",
    Trie.get(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal),
    M.equals(T.optional(T.natTestable, ?10))),
  Suite.test(
    "put find 1",
    Trie.find(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal),
    M.equals(T.optional(T.natTestable, ?10))),
  Suite.test(
    "merge",
    prettyArray(Trie.merge(trie1, trie3, Nat.equal)),
    arrayTest([(0, 10), (4, 14), (1, 21), (2, 22)])),
  Suite.test(
    "merge with empty",
    prettyArray(Trie.merge(trie1, Trie.empty(), Nat.equal)),
    arrayTest([(0, 10), (2, 12), (4, 14)])),
  Suite.test(
    "merge two empties",
    prettyArray(Trie.merge(Trie.empty(), Trie.empty(), Nat.equal)),
    arrayTest([])),
  Suite.test(
    "merge disjoint",
    prettyArray(Trie.mergeDisjoint(trie1, trie2, Nat.equal)),
    arrayTest([(0, 10), (2, 12), (4, 14), (1, 11), (3, 13)])),
  Suite.test(
    "merge disjoint",
    prettyArray(Trie.mergeDisjoint(trie1, Trie.empty(), Nat.equal)),
    arrayTest([(0, 10), (2, 12), (4, 14)])),
  Suite.test(
    "merge disjoint two empties",
    prettyArray(Trie.mergeDisjoint(Trie.empty(), Trie.empty(), Nat.equal)),
    arrayTest([])),
  Suite.test(
    "diff",
    prettyArray(Trie.diff(trie1, trie3, Nat.equal)),
    arrayTest([(0, 10), (4, 14)])),
  Suite.test(
    "diff non-commutative",
    prettyArray(Trie.diff(trie3, trie1, Nat.equal)),
    arrayTest([(1, 21)])),
  Suite.test(
    "diff empty right",
    prettyArray(Trie.diff(trie1, Trie.empty(), Nat.equal)),
    arrayTest([(0, 10), (2, 12), (4, 14)])),
  Suite.test(
    "diff empty left",
    prettyArray(Trie.diff(Trie.empty(), trie1, Nat.equal)),
    arrayTest([])),
  Suite.test(
    "disj",
    prettyArray(
      Trie.disj<Nat, Nat, Nat, Nat>(trie1, trie3, Nat.equal,
        func(v1, v2) {
          switch(v1, v2) {
            case(?v1, ?v2) v1 + v2; // add values to combine
            case(?v1, null) v1;
            case(null, ?v2) v2;
            case(null, null) Debug.trap "unreachable in disj";
          }
        },
        Nat.toText,
        Nat.toText,
        Nat.toText
      )
    ),
    arrayTest([(0, 10), (4, 14), (1, 21), (2, 34)])),
  ]
);

// FIXME add tests for bitpos functions

Suite.run(suite);

// Assertion tests
debug {
  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;

  func key(i: Nat) : Key<Text> {
    let t = Nat.toText i;
    { key = t ; hash = Text.hash t }
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
    }
  };

  // filter all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.filter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.filter (t1, func (t : Text, n : Nat) : Bool { n != i } );
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat);
    }
  };

  // filter-map all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.mapFilter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.mapFilter (t1,
       func (t : Text, n : Nat) : ?Nat {
         if (n != i) ?n else null }
      );
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat);
    }
  }
};
