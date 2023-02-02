import Prim "mo:⛔";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Order "mo:base/Order";
import Char "mo:base/Char";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

// Small map that has not resized
let smallSize = 6;
let smallKeys = Array.tabulate<Text>(smallSize, func i = "key" # Nat.toText(i));
let smallValues = Array.tabulate<Text>(smallSize, func i = "value" # Nat.toText(i));
let smallEntries = Array.tabulate<(Text, Text)>(smallSize, func i = (smallKeys[i], smallValues[i]));
func newMap() : HashMap.HashMap<Text, Text> {
  let map = HashMap.HashMap<Text, Text>(7, Text.equal, Text.hash);
  var i = 0;
  while (i < smallSize) {
    map.put(smallKeys[i], smallValues[i]);
    i += 1
  };
  map
};

// Map that is large enough to have gone through multiple resizes
let largeSize = 100;
let largeKeys = Array.tabulate<Text>(largeSize, func i = "key" # Nat.toText(i));
let largeValues = Array.tabulate<Text>(largeSize, func i = "value" # Nat.toText(i));
let largeEntries = Array.tabulate<(Text, Text)>(largeSize, func i = (largeKeys[i], largeValues[i]));
// mix in some forced collisions
let collideHash : Text -> Hash.Hash = func key {
  if (key < "key10") {
    0
  } else if (key < "key20") {
    1
  } else {
    Text.hash(key)
  }
};

func newCollidedMap() : HashMap.HashMap<Text, Text> {
  let collidedMap = HashMap.HashMap<Text, Text>(3, Text.equal, collideHash);
  var i = 0;
  while (i < largeSize) {
    collidedMap.put(largeKeys[i], largeValues[i]);
    i += 1
  };
  collidedMap
};

func newEmptyMap() : HashMap.HashMap<Text, Text> {
  HashMap.HashMap<Text, Text>(1, Text.equal, Text.hash)
};

//FIXME move into Nat module in next PR
func fromText(text : Text) : ?Nat {
  var n = 0;
  for (c in text.chars()) {
    if (Char.isDigit(c)) {
      let charAsNat = Prim.nat32ToNat(Prim.charToNat32(c) -% Prim.charToNat32('0'));
      n := n * 10 + charAsNat
    } else {
      return null
    }
  };
  ?n
};

// Need to sort the entries because the order is not guaranteed for equality tests
func sortedEntries<V>(map : HashMap.HashMap<Text, V>) : [(Text, V)] {
  Array.sort<(Text, V)>(
    Iter.toArray(map.entries()),
    func(p1, p2) {
      ignore do ? {
        let key1Index = Text.stripStart(p1.0, #text "key");
        let key2Index = Text.stripStart(p2.0, #text "key");
        return Nat.compare(fromText(key1Index!)!, fromText(key2Index!)!)
      };
      Debug.print("key1Index: " # p1.0);
      Debug.print("key2Index: " # p2.0);
      Debug.trap "unreachable in sortedEntries"
    }
  )
};

func sortedKeys<V>(map : HashMap.HashMap<Text, V>) : [Text] {
  Array.sort<Text>(
    Iter.toArray(map.keys()),
    func(key1, key2) {
      ignore do ? {
        let key1Index = Text.stripStart(key1, #text "key");
        let key2Index = Text.stripStart(key2, #text "key");
        return Nat.compare(fromText(key1Index!)!, fromText(key2Index!)!)
      };
      Debug.trap "unreachable in sortedKeys"
    }
  )
};

func sortedValues(map : HashMap.HashMap<Text, Text>) : [Text] {
  Array.sort<Text>(
    Iter.toArray(map.vals()),
    func(value1, value2) {
      ignore do ? {
        let value1Index = Text.stripStart(value1, #text "value");
        let value2Index = Text.stripStart(value2, #text "value");
        return Nat.compare(fromText(value1Index!)!, fromText(value2Index!)!)
      };
      Debug.trap "unreachable in sortedValues"
    }
  )
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
      newEmptyMap().get("key"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "get with collisions",
      newCollidedMap().get("key1"),
      M.equals(T.optional(T.textTestable, ?"value1"))
    ),
    Suite.test(
      "get",
      newMap().get("key1"),
      M.equals(T.optional(T.textTestable, ?"value1"))
    ),
    Suite.test(
      "get not found",
      newMap().get("not a key"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "put",
      do {
        let tempMap = newMap();
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "put override",
      do {
        let tempMap = newMap();
        tempMap.put("key2", "new value2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, ?"new value2" : ?Text))
    ),
    Suite.test(
      "put override with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.put("key2", "new value2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, ?"new value2" : ?Text))
    ),
    Suite.test(
      "replace new key return val",
      newEmptyMap().replace("key1", "value1"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "replace new key insertion",
      do {
        let tempMap = newEmptyMap();
        ignore tempMap.replace("key1", "value1");
        tempMap.get("key1")
      },
      M.equals(T.optional(T.textTestable, ?"value1" : ?Text))
    ),
    Suite.test(
      "replace overwrite return val",
      newMap().replace("key2", "new value2"),
      M.equals(T.optional(T.textTestable, ?"value2" : ?Text))
    ),
    Suite.test(
      "replace overwrite insertion",
      do {
        let tempMap = newMap();
        ignore tempMap.replace("key2", "new value2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, ?"new value2" : ?Text))
    ),
    Suite.test(
      "delete empty",
      do {
        let tempMap = newEmptyMap();
        tempMap.delete("key");
        tempMap.get("key")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "delete with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.delete("key2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "delete",
      do {
        let tempMap = newMap();
        tempMap.delete("key2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "delete preserve structure with collision",
      do {
        let tempMap = newCollidedMap();
        tempMap.delete("key2");
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "delete preserve structure",
      do {
        let tempMap = newMap();
        tempMap.delete("key2");
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "delete not exist with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.delete("fake key");
        tempMap.size()
      },
      M.equals(T.nat(largeSize))
    ),
    Suite.test(
      "delete not exist",
      do {
        let tempMap = newMap();
        tempMap.delete("fake key");
        tempMap.size()
      },
      M.equals(T.nat(smallSize))
    ),
    Suite.test(
      "remove empty return val",
      newEmptyMap().remove("key"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "remove empty size",
      do {
        let tempMap = newEmptyMap();
        ignore tempMap.remove("key");
        tempMap.size()
      },
      M.equals(T.nat(0))
    ),
    Suite.test(
      "remove return val",
      newMap().remove("key2"),
      M.equals(T.optional(T.textTestable, ?"value2" : ?Text))
    ),
    Suite.test(
      "remove deletion",
      do {
        let tempMap = newMap();
        ignore tempMap.remove("key2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "remove preserve structure",
      do {
        let tempMap = newMap();
        ignore tempMap.remove("key2");
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "remove not exist",
      do {
        let tempMap = newMap();
        tempMap.remove("fake key")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "keys empty",
      newEmptyMap().keys().next(),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "keys with collisions",
      sortedKeys(newCollidedMap()),
      M.equals(T.array(T.textTestable, largeKeys))
    ),
    Suite.test(
      "keys",
      sortedKeys(newMap()),
      M.equals(T.array(T.textTestable, smallKeys))
    ),
    Suite.test(
      "vals empty",
      newEmptyMap().vals().next(),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "vals with collisions",
      sortedValues(newCollidedMap()),
      M.equals(T.array(T.textTestable, largeValues))
    ),
    Suite.test(
      "vals",
      sortedValues(newMap()),
      M.equals(T.array(T.textTestable, smallValues))
    ),
    Suite.test(
      "entries empty",
      newEmptyMap().entries().next(),
      M.equals(T.optional(T.tuple2Testable(T.textTestable, T.textTestable), null : ?(Text, Text)))
    ),
    Suite.test(
      "entries with collisions",
      sortedEntries(newCollidedMap()),
      M.equals(T.array(T.tuple2Testable(T.textTestable, T.textTestable), largeEntries))
    ),
    Suite.test(
      "entries",
      sortedEntries(newMap()),
      M.equals(T.array(T.tuple2Testable(T.textTestable, T.textTestable), smallEntries))
    ),
    Suite.test(
      "clone empty",
      HashMap.clone(newEmptyMap(), Text.equal, Text.hash).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "clone with collisions",
      do {
        let mapClone = HashMap.clone(newCollidedMap(), Text.equal, Text.hash);
        sortedEntries(mapClone)
      },
      M.equals(T.array(T.tuple2Testable(T.textTestable, T.textTestable), largeEntries))
    ),
    Suite.test(
      "clone",
      do {
        let mapClone = HashMap.clone(newMap(), Text.equal, Text.hash);
        sortedEntries(mapClone)
      },
      M.equals(T.array(T.tuple2Testable(T.textTestable, T.textTestable), smallEntries))
    ),
    Suite.test(
      "fromIter empty",
      HashMap.fromIter<Text, Text>([].vals(), 3, Text.equal, Text.hash).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "fromIter with collisions",
      do {
        let iter = largeEntries.vals();
        let tempMap = HashMap.fromIter<Text, Text>(iter, 3, Text.equal, collideHash);
        sortedEntries(tempMap)
      },
      M.equals(T.array(T.tuple2Testable(T.textTestable, T.textTestable), largeEntries))
    ),
    Suite.test(
      "fromIter",
      do {
        let iter = smallEntries.vals();
        let tempMap = HashMap.fromIter<Text, Text>(iter, 7, Text.equal, Text.hash);
        sortedEntries(tempMap)
      },
      M.equals(T.array(T.tuple2Testable(T.textTestable, T.textTestable), smallEntries))
    ),
    Suite.test(
      "map empty",
      HashMap.map<Text, Text, Nat>(newEmptyMap(), Text.equal, Text.hash, func _ = 0).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "map with collisions",
      do {
        let tempMap = HashMap.map<Text, Text, Nat>(
          newCollidedMap(),
          Text.equal,
          collideHash,
          func p = p.1.size()
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.natTestable),
          Array.map<(Text, Text), (Text, Nat)>(largeEntries, func p = (p.0, p.1.size()))
        )
      )
    ),
    Suite.test(
      "map",
      do {
        let tempMap = HashMap.map<Text, Text, Nat>(
          newMap(),
          Text.equal,
          Text.hash,
          func p = p.1.size()
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.natTestable),
          Array.map<(Text, Text), (Text, Nat)>(smallEntries, func p = (p.0, p.1.size()))
        )
      )
    ),
    Suite.test(
      "mapFilter empty",
      HashMap.mapFilter<Text, Text, Nat>(newEmptyMap(), Text.equal, Text.hash, func _ = ?0).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "mapFilter with collisions",
      do {
        let tempMap = HashMap.mapFilter<Text, Text, Text>(
          newCollidedMap(),
          Text.equal,
          collideHash,
          // drop the first 10 keys
          func(key, value) = if (key.size() > 4) { ?value } else { null }
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          Array.filter<(Text, Text)>(largeEntries, func p = p.0.size() > 4)
        )
      )
    ),
    Suite.test(
      "mapFilter",
      do {
        let tempMap = HashMap.mapFilter<Text, Text, Text>(
          newMap(),
          Text.equal,
          Text.hash,
          func(key, value) = if (key != "key1") { ?value } else { null }
        );
        sortedEntries(tempMap)
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          Array.sort<(Text, Text)>(
            Array.filter<(Text, Text)>(smallEntries, func p = p.0 != "key1"),
            func(p1, p2) = Text.compare(p1.0, p2.0)
          )
        )
      )
    ),
    Suite.test(
      "Issue #228",
      do {
        let tempMap = HashMap.HashMap<Text, Nat>(50, Text.equal, Text.hash);
        tempMap.remove("test")
      },
      M.equals(T.optional(T.natTestable, null : ?Nat))
    )
  ]
);

Suite.run(suite)
