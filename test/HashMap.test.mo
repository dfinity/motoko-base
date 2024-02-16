import Prim "mo:⛔";
import HashMap "../src/HashMap";
import Hash "../src/Hash";
import Text "../src/Text";
import Nat "../src/Nat";
import Array "../src/Array";
import Iter "../src/Iter";
import Debug "../src/Debug";
import Order "../src/Order";
import Char "../src/Char";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

/*
* A note about the following test data. There are three functions that returns
* test maps: newMap, newCollidedMap, and newEmptyMap. newMap returns a map that is
* populate but has not resized. newCollidedMap returns a map that is populated
* and has gone through multiple resizes, with some forced collisions. newEmptyMap
* returns an empty map.
*
* There are functions that sort the keys and values by the number N, and returns
* the entries as an array.
*/

// Small map that has not resized
let smallSize = 6;
let smallKeys = Array.tabulate<Nat>(smallSize, func i = i);
let smallValues = Array.tabulate<Nat>(smallSize, func i = i);
let smallEntries = Array.tabulate<(Nat, Nat)>(smallSize, func i = (smallKeys[i], smallValues[i]));
func newMap() : HashMap.HashMap<Nat, Nat> {
  let map = HashMap.HashMap<Nat, Nat>(7, Nat.equal, Hash.hash);
  var i = 0;
  while (i < smallSize) {
    map.put(smallKeys[i], smallValues[i]);
    i += 1
  };
  map
};

// Map that is large enough to have gone through multiple resizes
let largeSize = 100;
let largeKeys = Array.tabulate<Nat>(largeSize, func i = i);
let largeValues = Array.tabulate<Nat>(largeSize, func i = i);
let largeEntries = Array.tabulate<(Nat, Nat)>(largeSize, func i = (largeKeys[i], largeValues[i]));
// mix in some forced collisions
let collideHash : Nat -> Hash.Hash = func key {
  if (key < 10) {
    0
  } else if (key < 20) {
    1
  } else {
    Hash.hash(key)
  }
};

func newCollidedMap() : HashMap.HashMap<Nat, Nat> {
  let collidedMap = HashMap.HashMap<Nat, Nat>(3, Nat.equal, collideHash);
  var i = 0;
  while (i < largeSize) {
    collidedMap.put(largeKeys[i], largeValues[i]);
    i += 1
  };
  collidedMap
};

func newEmptyMap() : HashMap.HashMap<Nat, Nat> {
  HashMap.HashMap<Nat, Nat>(1, Nat.equal, Hash.hash)
};

// Need to sort the entries because the order is not guaranteed for equality tests
func sortedEntries<V>(map : HashMap.HashMap<Nat, V>) : [(Nat, V)] {
  Array.sort<(Nat, V)>(
    Iter.toArray(map.entries()),
    func(p1, p2) {
      Nat.compare(p1.0, p2.0)
    }
  )
};

func sortedKeys<V>(map : HashMap.HashMap<Nat, V>) : [Nat] {
  Array.sort<Nat>(Iter.toArray(map.keys()), Nat.compare)
};

func sortedValues(map : HashMap.HashMap<Nat, Nat>) : [Nat] {
  Array.sort<Nat>(Iter.toArray(map.vals()), Nat.compare)
};

let suite = Suite.suite(
  "HashMap",
  [
    Suite.test(
      "init size",
      newEmptyMap().size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "size",
      newMap().size(),
      M.equals(T.nat(smallSize))
    ),
    Suite.test(
      "size with collisions",
      newCollidedMap().size(),
      M.equals(T.nat(largeSize))
    ),
    Suite.test(
      "empty get",
      newEmptyMap().get(101),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "get with collisions",
      newCollidedMap().get(1),
      M.equals(T.optional(T.natTestable, ?1))
    ),
    Suite.test(
      "get",
      newMap().get(1),
      M.equals(T.optional(T.natTestable, ?1))
    ),
    Suite.test(
      "get not found",
      newMap().get(101),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "put",
      do {
        let tempMap = newMap();
        tempMap.get(4)
      },
      M.equals(T.optional(T.natTestable, ?4 : ?Nat))
    ),
    Suite.test(
      "put override",
      do {
        let tempMap = newMap();
        tempMap.put(2, 102);
        tempMap.get(2)
      },
      M.equals(T.optional(T.natTestable, ?102 : ?Nat))
    ),
    Suite.test(
      "put override with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.put(2, 102);
        tempMap.get(2)
      },
      M.equals(T.optional(T.natTestable, ?102 : ?Nat))
    ),
    Suite.test(
      "replace new key return val",
      newEmptyMap().replace(1, 1),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "replace new key insertion",
      do {
        let tempMap = newEmptyMap();
        ignore tempMap.replace(1, 1);
        tempMap.get(1)
      },
      M.equals(T.optional(T.natTestable, ?1 : ?Nat))
    ),
    Suite.test(
      "replace overwrite return val",
      newMap().replace(2, 102),
      M.equals(T.optional(T.natTestable, ?2 : ?Nat))
    ),
    Suite.test(
      "replace overwrite insertion",
      do {
        let tempMap = newMap();
        ignore tempMap.replace(2, 102);
        tempMap.get(2)
      },
      M.equals(T.optional(T.natTestable, ?102 : ?Nat))
    ),
    Suite.test(
      "delete empty",
      do {
        let tempMap = newEmptyMap();
        tempMap.delete(101);
        tempMap.get(101)
      },
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "delete with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.delete(2);
        tempMap.get(2)
      },
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "delete",
      do {
        let tempMap = newMap();
        tempMap.delete(2);
        tempMap.get(2)
      },
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "delete preserve structure with collision",
      do {
        let tempMap = newCollidedMap();
        tempMap.delete(2);
        tempMap.get(4)
      },
      M.equals(T.optional(T.natTestable, ?4 : ?Nat))
    ),
    Suite.test(
      "delete preserve structure",
      do {
        let tempMap = newMap();
        tempMap.delete(2);
        tempMap.get(4)
      },
      M.equals(T.optional(T.natTestable, ?4 : ?Nat))
    ),
    Suite.test(
      "delete not exist with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.delete(101);
        tempMap.size()
      },
      M.equals(T.nat(largeSize))
    ),
    Suite.test(
      "delete not exist",
      do {
        let tempMap = newMap();
        tempMap.delete(101);
        tempMap.size()
      },
      M.equals(T.nat(smallSize))
    ),
    Suite.test(
      "remove empty return val",
      newEmptyMap().remove(101),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "remove empty size",
      do {
        let tempMap = newEmptyMap();
        ignore tempMap.remove(101);
        tempMap.size()
      },
      M.equals(T.nat(0))
    ),
    Suite.test(
      "remove return val",
      newMap().remove(2),
      M.equals(T.optional(T.natTestable, ?2 : ?Nat))
    ),
    Suite.test(
      "remove deletion",
      do {
        let tempMap = newMap();
        ignore tempMap.remove(2);
        tempMap.get(2)
      },
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "remove preserve structure",
      do {
        let tempMap = newMap();
        ignore tempMap.remove(2);
        tempMap.get(4)
      },
      M.equals(T.optional(T.natTestable, ?4 : ?Nat))
    ),
    Suite.test(
      "remove not exist",
      do {
        let tempMap = newMap();
        tempMap.remove(101)
      },
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "keys empty",
      newEmptyMap().keys().next(),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "keys with collisions",
      sortedKeys(newCollidedMap()),
      M.equals(T.array(T.natTestable, largeKeys))
    ),
    Suite.test(
      "keys",
      sortedKeys(newMap()),
      M.equals(T.array(T.natTestable, smallKeys))
    ),
    Suite.test(
      "vals empty",
      newEmptyMap().vals().next(),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "vals with collisions",
      sortedValues(newCollidedMap()),
      M.equals(T.array(T.natTestable, largeValues))
    ),
    Suite.test(
      "vals",
      sortedValues(newMap()),
      M.equals(T.array(T.natTestable, smallValues))
    ),
    Suite.test(
      "entries empty",
      newEmptyMap().entries().next(),
      M.equals(T.optional(T.tuple2Testable(T.natTestable, T.natTestable), null : ?(Nat, Nat)))
    ),
    Suite.test(
      "entries with collisions",
      sortedEntries(newCollidedMap()),
      M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), largeEntries))
    ),
    Suite.test(
      "entries",
      sortedEntries(newMap()),
      M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), smallEntries))
    ),
    Suite.test(
      "clone empty",
      HashMap.clone(newEmptyMap(), Nat.equal, Hash.hash).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "clone with collisions",
      do {
        let mapClone = HashMap.clone(newCollidedMap(), Nat.equal, Hash.hash);
        sortedEntries(mapClone)
      },
      M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), largeEntries))
    ),
    Suite.test(
      "clone",
      do {
        let mapClone = HashMap.clone(newMap(), Nat.equal, Hash.hash);
        sortedEntries(mapClone)
      },
      M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), smallEntries))
    ),
    Suite.test(
      "fromIter empty",
      HashMap.fromIter<Nat, Nat>([].vals(), 3, Nat.equal, Hash.hash).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "fromIter with collisions",
      do {
        let iter = largeEntries.vals();
        let tempMap = HashMap.fromIter<Nat, Nat>(iter, 3, Nat.equal, collideHash);
        sortedEntries(tempMap)
      },
      M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), largeEntries))
    ),
    Suite.test(
      "fromIter",
      do {
        let iter = smallEntries.vals();
        let tempMap = HashMap.fromIter<Nat, Nat>(iter, 7, Nat.equal, Hash.hash);
        sortedEntries(tempMap)
      },
      M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), smallEntries))
    ),
    Suite.test(
      "map empty",
      HashMap.map<Nat, Nat, Nat>(newEmptyMap(), Nat.equal, Hash.hash, func _ = 0).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "map with collisions",
      do {
        let tempMap = HashMap.map<Nat, Nat, Nat>(
          newCollidedMap(),
          Nat.equal,
          collideHash,
          func p = p.1 * 2
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.natTestable, T.natTestable),
          Array.map<(Nat, Nat), (Nat, Nat)>(largeEntries, func p = (p.0, p.1 * 2))
        )
      )
    ),
    Suite.test(
      "map",
      do {
        let tempMap = HashMap.map<Nat, Nat, Nat>(
          newMap(),
          Nat.equal,
          Hash.hash,
          func p = p.1 * 2
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.natTestable, T.natTestable),
          Array.map<(Nat, Nat), (Nat, Nat)>(smallEntries, func p = (p.0, p.1 * 2))
        )
      )
    ),
    Suite.test(
      "mapFilter empty",
      HashMap.mapFilter<Nat, Nat, Nat>(newEmptyMap(), Nat.equal, Hash.hash, func _ = ?0).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "mapFilter with collisions",
      do {
        let tempMap = HashMap.mapFilter<Nat, Nat, Nat>(
          newCollidedMap(),
          Nat.equal,
          collideHash,
          // drop the first 10 keys
          func(key, value) = if (key < 10) { ?value } else { null }
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.natTestable, T.natTestable),
          Array.filter<(Nat, Nat)>(largeEntries, func p = p.0 < 10)
        )
      )
    ),
    Suite.test(
      "mapFilter",
      do {
        let tempMap = HashMap.mapFilter<Nat, Nat, Nat>(
          newMap(),
          Nat.equal,
          Hash.hash,
          func(key, value) = if (key != 1) { ?value } else { null }
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.natTestable, T.natTestable),
          Array.sort<(Nat, Nat)>(
            Array.filter<(Nat, Nat)>(smallEntries, func p = p.0 != 1),
            func(p1, p2) = Nat.compare(p1.0, p2.0)
          )
        )
      )
    ),
    Suite.test(
      "Issue #228",
      do {
        let tempMap = HashMap.HashMap<Nat, Nat>(50, Nat.equal, Hash.hash);
        tempMap.remove(0)
      },
      M.equals(T.optional(T.natTestable, null : ?Nat))
    )
  ]
);

Suite.run(suite)
