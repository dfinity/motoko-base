import Trie "../src/Trie";
import Nat "../src/Nat";
import Hash "../src/Hash";
import Option "../src/Option";
import Iter "../src/Iter";
import Text "../src/Text";
import Debug "../src/Debug";
import Array "../src/Array";
import Order "../src/Order";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

func compare (kv1 : (Nat, Nat), kv2 : (Nat, Nat)) : Order.Order {
  Nat.compare(kv1.0, kv2.0)
};


func compare2D (kv1 : ((Nat, Nat), Nat), kv2: ((Nat, Nat), Nat)) : Order.Order {
   switch (Nat.compare(kv1.0.0, kv2.0.0)) {
     case (#equal) { Nat.compare(kv1.0.1, kv2.0.1) };
     case (other) { other };
   };
};

func compare3D (kv1 : ((Nat, Nat, Nat), Nat), kv2: ((Nat, Nat, Nat), Nat)) : Order.Order {
   switch (Nat.compare(kv1.0.0, kv2.0.0)) {
     case (#equal) {
       switch (Nat.compare(kv1.0.1, kv2.0.1)) {
         case (#equal) { Nat.compare(kv1.0.2, kv2.0.2); };
         case (other) { other };
       }
     };
     case (other) { other };
   };
};

// Utilities to massage types between Trie and Matchers
func prettyArray(trie : Trie.Trie<Nat, Nat>) : [(Nat, Nat)] {
  Array.sort(
    Trie.toArray<Nat, Nat, (Nat, Nat)>(trie, func kv = kv),
    compare)
};


func prettyArray2D(trie2D1 : Trie.Trie2D<Nat, Nat, Nat>) : [((Nat, Nat), Nat)] {
  Array.sort(
  Array.flatten(
    Trie.toArray<Nat, Trie.Trie<Nat, Nat>, [((Nat, Nat), Nat)]>(
      trie2D1,
      func(k1, trie) {
        let innerArray = prettyArray trie;
        Array.map<(Nat, Nat), ((Nat, Nat), Nat)>(innerArray, func(k2, v) = ((k1, k2), v))
      }
    )
  ),
  compare2D)
};

func prettyArray3D(trie3D : Trie.Trie3D<Nat, Nat, Nat, Nat>) : [((Nat, Nat, Nat), Nat)] {
  Array.sort(
  Array.flatten(
    Trie.toArray<Nat, Trie.Trie<Nat, Trie.Trie<Nat, Nat>>, [((Nat, Nat, Nat), Nat)]>(
      trie3D,
      func(k1, trie2D1) {
        let innerArray = prettyArray2D trie2D1;
        Array.map<((Nat, Nat), Nat), ((Nat, Nat, Nat), Nat)>(innerArray, func((k2, k3), v) = ((k1, k2, k3), v))
      }
    )
  ),
  compare3D)
};


func arrayTest(array : [(Nat, Nat)]) : M.Matcher<[(Nat, Nat)]> {
  let array1 = Array.sort(array, compare);
  M.equals<[(Nat, Nat)]>(T.array<(Nat, Nat)>(T.tuple2Testable<Nat, Nat>(T.natTestable, T.natTestable), array1))
};

func arrayTest2D(array : [((Nat, Nat), Nat)]) : M.Matcher<[((Nat, Nat), Nat)]> {
  let array1 = Array.sort(array, compare2D);
  M.equals<[((Nat, Nat), Nat)]>(
    T.array<((Nat, Nat), Nat)>(
      T.tuple2Testable<(Nat, Nat), Nat>(
        T.tuple2Testable<Nat, Nat>(T.natTestable, T.natTestable),
        T.natTestable
      ),
      array1
    )
  )
};


func arrayTest3D(array : [((Nat, Nat, Nat), Nat)]) : M.Matcher<[((Nat, Nat, Nat), Nat)]> {
  let array1 = Array.sort(array, compare3D);
  let tuple3Testable : T.Testable<(Nat, Nat, Nat)> = {
    display = func t { debug_show t };
    equals = func(t1, t2) { t1 == t2 }
  };

  M.equals<[((Nat, Nat, Nat), Nat)]>(
    T.array<((Nat, Nat, Nat), Nat)>(
      T.tuple2Testable<(Nat, Nat, Nat), Nat>(
        tuple3Testable,
        T.natTestable
      ),
      array1
    )
  )
};

func natKey(nat : Nat) : Trie.Key<Nat> { { hash = Hash.hash(nat); key = nat } };
let natKeyTestable : T.Testable<Trie.Key<Nat>> = {
  display = func k { debug_show k.key };
  equals = func(k1, k2) { k1 == k2 }
};

// Sample tries for testing
// FIXME tweak the keys to force collisions here
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

// Sample 2D trie for testing
var trie2D1 = Trie.empty<Nat, Trie.Trie<Nat, Nat>>();
trie2D1 := Trie.put2D<Nat, Nat, Nat>(trie2D1, natKey(0), Nat.equal, natKey(10), Nat.equal, 100);
trie2D1 := Trie.put2D<Nat, Nat, Nat>(trie2D1, natKey(2), Nat.equal, natKey(12), Nat.equal, 102);
trie2D1 := Trie.put2D<Nat, Nat, Nat>(trie2D1, natKey(4), Nat.equal, natKey(14), Nat.equal, 104);

var trie2D2 = Trie.empty<Nat, Trie.Trie<Nat, Nat>>();
trie2D2 := Trie.put2D<Nat, Nat, Nat>(trie2D2, natKey(1), Nat.equal, natKey(11), Nat.equal, 101);
trie2D2 := Trie.put2D<Nat, Nat, Nat>(trie2D2, natKey(1), Nat.equal, natKey(21), Nat.equal, 201);
trie2D2 := Trie.put2D<Nat, Nat, Nat>(trie2D2, natKey(2), Nat.equal, natKey(12), Nat.equal, 102);
trie2D2 := Trie.put2D<Nat, Nat, Nat>(trie2D2, natKey(3), Nat.equal, natKey(13), Nat.equal, 103);
trie2D2 := Trie.put2D<Nat, Nat, Nat>(trie2D2, natKey(3), Nat.equal, natKey(23), Nat.equal, 203);
trie2D2 := Trie.put2D<Nat, Nat, Nat>(trie2D2, natKey(3), Nat.equal, natKey(33), Nat.equal, 303);

// Sample 3D trie for testing
var trie3D = Trie.empty<Nat, Trie.Trie<Nat, Trie.Trie<Nat, Nat>>>();
trie3D := Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(0), Nat.equal, natKey(10), Nat.equal, natKey(100), Nat.equal, 1000);
trie3D := Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(2), Nat.equal, natKey(12), Nat.equal, natKey(102), Nat.equal, 1002);
trie3D := Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(4), Nat.equal, natKey(14), Nat.equal, natKey(104), Nat.equal, 1004);

// Matchers tests
let suite = Suite.suite(
  "Trie",
  [
    Suite.test(
      "empty trie size 0",
      Trie.size(Trie.empty()),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "empty trie array roundtrip",
      prettyArray(Trie.empty()),
      arrayTest([])
    ),
    Suite.test(
      "put 1",
      prettyArray(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0),
      arrayTest([(0, 10)])
    ),
    Suite.test(
      "put get 1",
      Trie.get(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal),
      M.equals(T.optional(T.natTestable, ?10))
    ),
    Suite.test(
      "put find 1",
      Trie.find(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal),
      M.equals(T.optional(T.natTestable, ?10))
    ),
    Suite.test(
      "merge",
      prettyArray(Trie.merge(trie1, trie3, Nat.equal)),
      arrayTest([(0, 10), (4, 14), (1, 21), (2, 12)])
    ),
    Suite.test(
      "merge with empty",
      prettyArray(Trie.merge(trie1, Trie.empty(), Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "merge two empties",
      prettyArray(Trie.merge(Trie.empty(), Trie.empty(), Nat.equal)),
      arrayTest([])
    ),
    Suite.test(
      "merge disjoint",
      prettyArray(Trie.mergeDisjoint(trie1, trie2, Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14), (1, 11), (3, 13)])
    ),
    Suite.test(
      "merge disjoint one empty",
      prettyArray(Trie.mergeDisjoint(trie1, Trie.empty(), Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "merge disjoint two empties",
      prettyArray(Trie.mergeDisjoint(Trie.empty(), Trie.empty(), Nat.equal)),
      arrayTest([])
    ),
    Suite.test(
      "diff",
      prettyArray(Trie.diff(trie1, trie3, Nat.equal)),
      arrayTest([(0, 10), (4, 14)])
    ),
    Suite.test(
      "diff non-commutative",
      prettyArray(Trie.diff(trie3, trie1, Nat.equal)),
      arrayTest([(1, 21)])
    ),
    Suite.test(
      "diff empty right",
      prettyArray(Trie.diff(trie1, Trie.empty(), Nat.equal)),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "diff empty left",
      prettyArray(Trie.diff(Trie.empty(), trie1, Nat.equal)),
      arrayTest([])
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
              case (null, null) Debug.trap "unreachable in disj"
            }
          }
        )
      ),
      arrayTest([(0, 10), (4, 14), (1, 21), (2, 34)])
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
              case (null, null) Debug.trap "unreachable in disj"
            }
          }
        )
      ),
      arrayTest([(0, 10), (2, 12), (4, 14)])
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
              case (null, null) Debug.trap "unreachable in disj"
            }
          }
        )
      ),
      arrayTest([(0, 10), (2, 12), (4, 14)])
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
              case (null, null) Debug.trap "unreachable in disj"
            }
          }
        )
      ),
      arrayTest([])
    ),
    Suite.test(
      "join",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(trie1, trie3, Nat.equal, Nat.add)
      ),
      arrayTest([(2, 34)])
    ),
    Suite.test(
      "join with empty first",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(Trie.empty(), trie1, Nat.equal, Nat.add)
      ),
      arrayTest([])
    ),
    Suite.test(
      "join with empty second",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(trie1, Trie.empty(), Nat.equal, Nat.add)
      ),
      arrayTest([])
    ),
    Suite.test(
      "join with two empties",
      prettyArray(
        Trie.join<Nat, Nat, Nat, Nat>(Trie.empty(), Trie.empty(), Nat.equal, Nat.add)
      ),
      arrayTest([])
    ),
    Suite.test(
      "foldUp",
      Trie.foldUp<Nat, Nat, Nat>(trie1, Nat.mul, Nat.add, 1),
      M.equals(T.nat(2520))
    ), // 1 * (0 + 10) * (2 + 12) * (4 + 14)
    Suite.test(
      "foldUp empty",
      Trie.foldUp<Nat, Nat, Nat>(Trie.empty(), Nat.mul, Nat.add, 1),
      M.equals(T.nat(1))
    ),
    Suite.test(
      "prod",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(trie1, trie3, func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([(1, 31), (2, 32), (3, 33), (4, 34), (5, 35), (6, 36)])
    ),
    Suite.test(
      "prod first empty",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(Trie.empty(), trie3, func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([])
    ),
    Suite.test(
      "prod second empty",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(trie1, Trie.empty(), func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([])
    ),
    Suite.test(
      "prod both empty",
      prettyArray(Trie.prod<Nat, Nat, Nat, Nat, Nat, Nat>(Trie.empty(), Trie.empty(), func(k1, v1, k2, v2) = ?(natKey(k1 + k2), v1 + v2), Nat.equal)),
      arrayTest([])
    ),
    Suite.test(
      "iter",
      Array.sort(Iter.toArray(Trie.iter(trie1)), compare),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "iter empty",
      Iter.toArray(Trie.iter(Trie.empty())),
      arrayTest([])
    ),
    Suite.test(
      "fold",
      Trie.fold<Nat, Nat, Nat>(trie1, func(k, v, acc) = k + v + acc, 0),
      M.equals(T.nat(42))
    ), // 0 + 10 + 2 + 12 + 4 + 14
    Suite.test(
      "fold empty",
      Trie.fold<Nat, Nat, Nat>(Trie.empty(), func(k, v, acc) = k + v + acc, 0),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "some true",
      Trie.some<Nat, Nat>(trie1, func(k, v) = k * v == 0),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "some false",
      Trie.some<Nat, Nat>(trie1, func(k, _) = k % 2 != 0),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "some empty",
      Trie.some<Nat, Nat>(Trie.empty(), func _ = true),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "all true",
      Trie.all<Nat, Nat>(trie1, func(k, _) = k % 2 == 0),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "all false",
      Trie.all<Nat, Nat>(trie1, func(k, v) = k * v == 0),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "all empty",
      Trie.all<Nat, Nat>(Trie.empty(), func _ = false),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "nth",
      Trie.nth<Nat, Nat>(trie1, 1),
      M.equals(
        T.optional(
          T.tuple2Testable(
            natKeyTestable,
            T.natTestable
          ),
          ?(natKey(2), 12)
        )
      )
    ),
    Suite.test(
      "nth OOB",
      Trie.nth<Nat, Nat>(trie1, 3),
      M.equals(
        T.optional(
          T.tuple2Testable(
            natKeyTestable,
            T.natTestable
          ),
          null : ?(Trie.Key<Nat>, Nat)
        )
      )
    ),
    Suite.test(
      "nth empty",
      Trie.nth<Nat, Nat>(Trie.empty(), 0),
      M.equals(
        T.optional(
          T.tuple2Testable(
            natKeyTestable,
            T.natTestable
          ),
          null : ?(Trie.Key<Nat>, Nat)
        )
      )
    ),
    Suite.test(
      "isEmpty false",
      Trie.isEmpty<Nat, Nat>(trie1),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "isEmpty true",
      Trie.isEmpty<Nat, Nat>(Trie.empty()),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isEmpty put remove",
      Trie.isEmpty<Nat, Nat>(
        Trie.remove<Nat, Nat>(Trie.put<Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, 10).0, natKey(0), Nat.equal).0
      ),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "filter",
      prettyArray(Trie.filter<Nat, Nat>(trie1, func(k, v) = k * v == 0)),
      arrayTest([(0, 10)])
    ),
    Suite.test(
      "filter all",
      prettyArray(Trie.filter<Nat, Nat>(trie1, func _ = false)),
      arrayTest([])
    ),
    Suite.test(
      "filter none",
      prettyArray(Trie.filter<Nat, Nat>(trie1, func _ = true)),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "mapFilter",
      prettyArray(Trie.mapFilter<Nat, Nat, Nat>(trie1, func(k, v) = if (k * v != 0) { ?(k * v) } else { null })),
      arrayTest([(2, 24), (4, 56)])
    ),
    Suite.test(
      "mapFilter all",
      prettyArray(Trie.mapFilter<Nat, Nat, Nat>(trie1, func _ = null)),
      arrayTest([])
    ),
    Suite.test(
      "mapFilter none",
      prettyArray(Trie.mapFilter<Nat, Nat, Nat>(trie1, func(k, v) = ?v)),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "equalStructure reflexivity",
      Trie.equalStructure<Nat, Nat>(trie1, trie1, Nat.equal, Nat.equal),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "equalStructure not equal maps",
      Trie.equalStructure<Nat, Nat>(trie1, trie2, Nat.equal, Nat.equal),
      M.equals(T.bool(false))
    ),
    // FIXME add case for maps that are equivalent (map-wise) but structually non-equal
    Suite.test(
      "equalStructure first empty",
      Trie.equalStructure<Nat, Nat>(Trie.empty(), trie2, Nat.equal, Nat.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "equalStructure second empty",
      Trie.equalStructure<Nat, Nat>(trie1, Trie.empty(), Nat.equal, Nat.equal),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "equalStructure both empty",
      Trie.equalStructure<Nat, Nat>(Trie.empty(), Trie.empty(), Nat.equal, Nat.equal),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "replaceThen success old value",
      Trie.replaceThen<Nat, Nat, Nat>(
        trie1,
        natKey(0),
        Nat.equal,
        100,
        func(newTrie, oldV) = oldV,
        func _ = Debug.trap "unreachable"
      ),
      M.equals(T.nat(10))
    ),
    Suite.test(
      "replaceThen success new trie",
      prettyArray(
        Trie.replaceThen<Nat, Nat, Trie.Trie<Nat, Nat>>(
          trie1,
          natKey(0),
          Nat.equal,
          100,
          func(newTrie, oldV) = newTrie,
          func _ = Debug.trap "unreachable"
        )
      ),
      arrayTest([(0, 100), (2, 12), (4, 14)])
    ),
    Suite.test(
      "replaceThen failure",
      Trie.replaceThen<Nat, Nat, Nat>(
        trie1,
        natKey(3),
        Nat.equal,
        13,
        func _ = Debug.trap "unreachable",
        func() = 99
      ),
      M.equals(T.nat(99))
    ),
    Suite.test(
      "replaceThen empty",
      Trie.replaceThen<Nat, Nat, Nat>(
        Trie.empty(),
        natKey(0),
        Nat.equal,
        100,
        func _ = Debug.trap "unreachable",
        func() = 99
      ),
      M.equals(T.nat(99))
    ),
    Suite.test(
      "putFresh success",
      prettyArray(Trie.putFresh<Nat, Nat>(trie1, natKey(6), Nat.equal, 16)),
      arrayTest([(0, 10), (2, 12), (4, 14), (6, 16)])
    ),
    Suite.test(
      "putFresh empty",
      prettyArray(Trie.putFresh<Nat, Nat>(Trie.empty(), natKey(6), Nat.equal, 16)),
      arrayTest([(6, 16)])
    ),
    Suite.test(
      "put2D",
      prettyArray2D(Trie.put2D<Nat, Nat, Nat>(trie2D1, natKey(1), Nat.equal, natKey(11), Nat.equal, 101)),
      arrayTest2D([((0, 10), 100), ((2, 12), 102), ((4, 14), 104), ((1, 11), 101)])
    ),
    Suite.test(
      "put2D overlapping k1",
      prettyArray2D(Trie.put2D<Nat, Nat, Nat>(trie2D1, natKey(0), Nat.equal, natKey(11), Nat.equal, 101)),
      arrayTest2D([((0, 10), 100), ((0, 11), 101), ((2, 12), 102), ((4, 14), 104)])
    ),
    Suite.test(
      "put2D overlapping k2",
      prettyArray2D(Trie.put2D<Nat, Nat, Nat>(trie2D1, natKey(1), Nat.equal, natKey(10), Nat.equal, 101)),
      arrayTest2D([((0, 10), 100), ((2, 12), 102), ((4, 14), 104), ((1, 10), 101)])
    ),
    Suite.test(
      "put2D overlapping both",
      prettyArray2D(Trie.put2D<Nat, Nat, Nat>(trie2D1, natKey(0), Nat.equal, natKey(10), Nat.equal, 1001)),
      arrayTest2D([((0, 10), 1001), ((2, 12), 102), ((4, 14), 104)])
    ),
    Suite.test(
      "put2D empty",
      prettyArray2D(Trie.put2D<Nat, Nat, Nat>(Trie.empty(), natKey(0), Nat.equal, natKey(10), Nat.equal, 100)),
      arrayTest2D([((0, 10), 100)])
    ),
    Suite.test(
      "put3D",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(1), Nat.equal, natKey(11), Nat.equal, natKey(101), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1000), ((2, 12, 102), 1002), ((4, 14, 104), 1004), ((1, 11, 101), 1001)])
    ),
    Suite.test(
      "put3D overlapping k1",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(0), Nat.equal, natKey(11), Nat.equal, natKey(101), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1000), ((0, 11, 101), 1001), ((2, 12, 102), 1002), ((4, 14, 104), 1004)])
    ),
    Suite.test(
      "put3D overlapping k2",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(1), Nat.equal, natKey(12), Nat.equal, natKey(101), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1000), ((2, 12, 102), 1002), ((4, 14, 104), 1004), ((1, 12, 101), 1001)])
    ),
    Suite.test(
      "put3D overlapping k3",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(1), Nat.equal, natKey(11), Nat.equal, natKey(102), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1000), ((2, 12, 102), 1002), ((4, 14, 104), 1004), ((1, 11, 102), 1001)])
    ),
    Suite.test(
      "put3D overlapping k1 and k2",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(0), Nat.equal, natKey(10), Nat.equal, natKey(101), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1000), ((0, 10, 101), 1001), ((2, 12, 102), 1002), ((4, 14, 104), 1004)])
    ),
    Suite.test(
      "put3D overlapping k1 and k3",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(0), Nat.equal, natKey(11), Nat.equal, natKey(100), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1000), ((0, 11, 100), 1001), ((2, 12, 102), 1002), ((4, 14, 104), 1004)])
    ),
    Suite.test(
      "put3D overlapping k2 and k3",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(1), Nat.equal, natKey(10), Nat.equal, natKey(100), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1000), ((2, 12, 102), 1002), ((4, 14, 104), 1004), ((1, 10, 100), 1001)])
    ),
    Suite.test(
      "put3D overlapping all",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(trie3D, natKey(0), Nat.equal, natKey(10), Nat.equal, natKey(100), Nat.equal, 1001)),
      arrayTest3D([((0, 10, 100), 1001), ((2, 12, 102), 1002), ((4, 14, 104), 1004)])
    ),
    Suite.test(
      "put3D empty",
      prettyArray3D(Trie.put3D<Nat, Nat, Nat, Nat>(Trie.empty(), natKey(1), Nat.equal, natKey(11), Nat.equal, natKey(101), Nat.equal, 1001)),
      arrayTest3D([((1, 11, 101), 1001)])
    ),
    Suite.test(
      "remove success, new trie",
      prettyArray(Trie.remove<Nat, Nat>(trie1, natKey(2), Nat.equal).0),
      arrayTest([(0, 10), (4, 14)])
    ),
    Suite.test(
      "remove success, old value",
      Trie.remove<Nat, Nat>(trie1, natKey(2), Nat.equal).1,
      M.equals(T.optional(T.natTestable, ?12))
    ),
    Suite.test(
      "remove failure, new trie",
      prettyArray(Trie.remove<Nat, Nat>(trie1, natKey(1), Nat.equal).0),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "remove failure, old value",
      Trie.remove<Nat, Nat>(trie1, natKey(1), Nat.equal).1,
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "remove empty, new trie",
      prettyArray(Trie.remove<Nat, Nat>(Trie.empty(), natKey(1), Nat.equal).0),
      arrayTest([])
    ),
    Suite.test(
      "remove empty, old value",
      Trie.remove<Nat, Nat>(Trie.empty(), natKey(1), Nat.equal).1,
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "removeThen success old value",
      Trie.removeThen<Nat, Nat, Nat>(
        trie1,
        natKey(0),
        Nat.equal,
        func(newTrie, oldV) = oldV,
        func _ = Debug.trap "unreachable"
      ),
      M.equals(T.nat(10))
    ),
    Suite.test(
      "removeThen success new trie",
      prettyArray(
        Trie.removeThen<Nat, Nat, Trie.Trie<Nat, Nat>>(
          trie1,
          natKey(0),
          Nat.equal,
          func(newTrie, oldV) = newTrie,
          func _ = Debug.trap "unreachable"
        )
      ),
      arrayTest([(2, 12), (4, 14)])
    ),
    Suite.test(
      "removeThen failure",
      Trie.removeThen<Nat, Nat, Nat>(
        trie1,
        natKey(1),
        Nat.equal,
        func _ = Debug.trap "unreachable",
        func() = 99
      ),
      M.equals(T.nat(99))
    ),
    Suite.test(
      "removeThen empty",
      Trie.removeThen<Nat, Nat, Nat>(
        Trie.empty() : Trie.Trie<Nat, Nat>,
        natKey(1),
        Nat.equal,
        func _ = Debug.trap "unreachable",
        func() = 99
      ),
      M.equals(T.nat(99))
    ),
    Suite.test(
      "remove2D success, new trie",
      prettyArray2D(Trie.remove2D<Nat, Nat, Nat>(trie2D1, natKey(2), Nat.equal, natKey(12), Nat.equal).0),
      arrayTest2D([((0, 10), 100), ((4, 14), 104)])
    ),
    Suite.test(
      "remove2D success, old value",
      Trie.remove2D<Nat, Nat, Nat>(trie2D1, natKey(2), Nat.equal, natKey(12), Nat.equal).1,
      M.equals(T.optional(T.natTestable, ?102))
    ),
    Suite.test(
      "remove2D failure, new trie",
      prettyArray2D(Trie.remove2D<Nat, Nat, Nat>(trie2D1, natKey(1), Nat.equal, natKey(11), Nat.equal).0),
      arrayTest2D([((0, 10), 100), ((2, 12), 102), ((4, 14), 104)])
    ),
    Suite.test(
      "remove2D failure, old value",
      Trie.remove2D<Nat, Nat, Nat>(trie2D1, natKey(1), Nat.equal, natKey(11), Nat.equal).1,
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "remove2D failure empty, new trie",
      prettyArray2D(Trie.remove2D<Nat, Nat, Nat>(Trie.empty(), natKey(1), Nat.equal, natKey(11), Nat.equal).0),
      arrayTest2D([])
    ),
    Suite.test(
      "remove2D failure empty, old value",
      Trie.remove2D<Nat, Nat, Nat>(Trie.empty(), natKey(1), Nat.equal, natKey(11), Nat.equal).1,
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "remove3D success, new trie",
      prettyArray3D(Trie.remove3D<Nat, Nat, Nat, Nat>(trie3D, natKey(2), Nat.equal, natKey(12), Nat.equal, natKey(102), Nat.equal).0),
      arrayTest3D([((0, 10, 100), 1000), ((4, 14, 104), 1004)])
    ),
    Suite.test(
      "remove3D success, old value",
      Trie.remove3D<Nat, Nat, Nat, Nat>(trie3D, natKey(2), Nat.equal, natKey(12), Nat.equal, natKey(102), Nat.equal).1,
      M.equals(T.optional(T.natTestable, ?1002 : ?Nat))
    ),
    Suite.test(
      "remove3D failure, new trie",
      prettyArray3D(Trie.remove3D<Nat, Nat, Nat, Nat>(trie3D, natKey(1), Nat.equal, natKey(11), Nat.equal, natKey(101), Nat.equal).0),
      arrayTest3D([((0, 10, 100), 1000), ((2, 12, 102), 1002), ((4, 14, 104), 1004)])
    ),
    Suite.test(
      "remove3D failure, old value",
      Trie.remove3D<Nat, Nat, Nat, Nat>(trie3D, natKey(1), Nat.equal, natKey(11), Nat.equal, natKey(101), Nat.equal).1,
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "remove3D failure empty, new trie",
      prettyArray3D(Trie.remove3D<Nat, Nat, Nat, Nat>(Trie.empty(), natKey(1), Nat.equal, natKey(11), Nat.equal, natKey(101), Nat.equal).0),
      arrayTest3D([])
    ),
    Suite.test(
      "remove3D failure empty, old value",
      Trie.remove3D<Nat, Nat, Nat, Nat>(Trie.empty(), natKey(1), Nat.equal, natKey(11), Nat.equal, natKey(101), Nat.equal).1,
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "mergeDisjoint2D",
      prettyArray(Trie.mergeDisjoint2D<Nat, Nat, Nat>(trie2D2, Nat.equal, Nat.equal)),
      arrayTest([(11, 101), (21, 201), (12, 102), (13, 103), (23, 203), (33, 303)])
    ),
    Suite.test(
      "mergeDisjoint2D empty",
      prettyArray(Trie.mergeDisjoint2D<Nat, Nat, Nat>(Trie.empty(), Nat.equal, Nat.equal)),
      arrayTest([])
    )
  ]
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
    { key = t; hash = Text.hash t }
  };

  let max = 100;

  // put k-v elements, one by one (but hashes are expected random).
  Debug.print "Trie.put";
  var t : Trie<Text, Nat> = Trie.empty();
  for (i in Iter.range(0, max - 1)) {
    let (t1_, x) = Trie.put<Text, Nat>(t, key i, Text.equal, i);
    assert (Option.isNull(x));
    assert Trie.isValid(t1_, false);
    t := t1_
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
      t1 := t1_
    }
  };

  // filter all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.filter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.filter(t1, func(t : Text, n : Nat) : Bool { n != i });
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat)
    }
  };

  // filter-map all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.mapFilter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.mapFilter(
        t1,
        func(t : Text, n : Nat) : ?Nat {
          if (n != i) ?n else null
        }
      );
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat)
    }
  }
}
