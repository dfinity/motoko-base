import Prim "mo:⛔";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

func newMap() : HashMap.HashMap<Text, Text> {
  HashMap.HashMap<Text, Text>(3, Text.equal, Text.hash)
};

func newCollidedMap() : HashMap.HashMap<Text, Text> {
  HashMap.HashMap<Text, Text>(1, Text.equal, func _ = 0)
};

let map = newMap();
map.put("key1", "value1");
map.put("key2", "value2");

let emptyMap = newMap();

let collidedMap = newCollidedMap();
collidedMap.put("key1", "value1");
collidedMap.put("key2", "value2");

let suite = Suite.suite(
  "HashMap",
  [
    Suite.test(
      "init size",
      emptyMap.size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "size",
      map.size(),
      M.equals(T.nat(2))
    ),
    Suite.test(
      "size with collisions",
      collidedMap.size(),
      M.equals(T.nat(2))
    ),
    Suite.test(
      "empty get",
      emptyMap.get("key"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "get with collisions",
      collidedMap.get("key1"),
      M.equals(T.optional(T.textTestable, ?"value1"))
    ),
    Suite.test(
      "get",
      map.get("key1"),
      M.equals(T.optional(T.textTestable, ?"value1"))
    ),
    Suite.test(
      "get not found",
      map.get("not a key"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "put",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.put("key5", "value5");
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "put override",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");

        tempMap.put("key2", "new value2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, ?"new value2" : ?Text))
    ),
    Suite.test(
      "put override with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");

        tempMap.put("key2", "new value2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, ?"new value2" : ?Text))
    ),
    Suite.test(
      "replace new key return val",
      newMap().replace("key1", "value1"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "replace new key insertion",
      do {
        let tempMap = newMap();
        ignore tempMap.replace("key1", "value1");
        tempMap.get("key1")
      },
      M.equals(T.optional(T.textTestable, ?"value1" : ?Text))
    ),
    Suite.test(
      "replace overwrite return val",
      do {
        let tempMap = newMap();
        ignore tempMap.replace("key1", "value1");
        ignore tempMap.replace("key2", "value2");
        ignore tempMap.replace("key3", "value3");
        ignore tempMap.replace("key4", "value4");
        ignore tempMap.replace("key5", "value5");

        tempMap.replace("key2", "new value2")
      },
      M.equals(T.optional(T.textTestable, ?"value2" : ?Text))
    ),
    Suite.test(
      "replace overwrite insertion",
      do {
        let tempMap = newMap();
        ignore tempMap.replace("key1", "value1");
        ignore tempMap.replace("key2", "value2");
        ignore tempMap.replace("key3", "value3");
        ignore tempMap.replace("key4", "value4");
        ignore tempMap.replace("key5", "value5");

        ignore tempMap.replace("key2", "new value2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, ?"new value2" : ?Text))
    ),
    Suite.test(
      "delete empty",
      do {
        let tempMap = newMap();
        tempMap.delete("key");
        tempMap.get("key")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "delete with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.delete("key2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "delete",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.delete("key2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "delete preserve structure with collision",
      do {
        let tempMap = newCollidedMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.delete("key2");
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "delete preserve structure",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.delete("key2");
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "delete not exist with collisions",
      do {
        let tempMap = newCollidedMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.delete("key5");
        tempMap.size()
      },
      M.equals(T.nat(4))
    ),
    Suite.test(
      "delete not exist",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.delete("key5");
        tempMap.size()
      },
      M.equals(T.nat(4))
    ),
    Suite.test(
      "remove empty return val",
      newMap().remove("key"),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "remove empty size",
      do {
        let tempMap = newMap();
        ignore tempMap.remove("key");
        tempMap.size()
      },
      M.equals(T.nat(0))
    ),
    Suite.test(
      "remove return val",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.remove("key2")
      },
      M.equals(T.optional(T.textTestable, ?"value2" : ?Text))
    ),
    Suite.test(
      "remove deletion",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        ignore tempMap.remove("key2");
        tempMap.get("key2")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "remove preserve structure",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        ignore tempMap.remove("key2");
        tempMap.get("key4")
      },
      M.equals(T.optional(T.textTestable, ?"value4" : ?Text))
    ),
    Suite.test(
      "remove not exist",
      do {
        let tempMap = newMap();
        tempMap.put("key1", "value1");
        tempMap.put("key2", "value2");
        tempMap.put("key3", "value3");
        tempMap.put("key4", "value4");
        tempMap.remove("key5")
      },
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "keys empty",
      emptyMap.keys().next(),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "keys with collisions",
      Iter.toArray(collidedMap.keys()),
      M.equals(T.array(T.textTestable, ["key1", "key2"]))
    ),
    Suite.test(
      "keys",
      Iter.toArray(map.keys()),
      M.equals(T.array(T.textTestable, ["key1", "key2"]))
    ),
    Suite.test(
      "vals empty",
      emptyMap.vals().next(),
      M.equals(T.optional(T.textTestable, null : ?Text))
    ),
    Suite.test(
      "vals with collisions",
      Iter.toArray(collidedMap.vals()),
      M.equals(T.array(T.textTestable, ["value1", "value2"]))
    ),
    Suite.test(
      "vals",
      Iter.toArray(map.vals()),
      M.equals(T.array(T.textTestable, ["value1", "value2"]))
    ),
    Suite.test(
      "entries empty",
      emptyMap.entries().next(),
      M.equals(
        T.optional(T.tuple2Testable(T.textTestable, T.textTestable), null : ?(Text, Text))
      )
    ),
    Suite.test(
      "entries with collisions",
      Iter.toArray(collidedMap.entries()),
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key1", "value1"), ("key2", "value2")]
        )
      )
    ),
    Suite.test(
      "entries",
      Iter.toArray(map.entries()),
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key1", "value1"), ("key2", "value2")]
        )
      )
    ),
    Suite.test(
      "clone empty",
      HashMap.clone(emptyMap, Text.equal, Text.hash).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "clone with collisions",
      do {
        let mapClone = HashMap.clone(collidedMap, Text.equal, Text.hash);
        Iter.toArray(mapClone.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key2", "value2"), ("key1", "value1")]
        )
      )
    ),
    Suite.test(
      "clone",
      do {
        let mapClone = HashMap.clone(map, Text.equal, Text.hash);
        Iter.toArray(mapClone.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key2", "value2"), ("key1", "value1")]
        )
      )
    ),
    Suite.test(
      "fromIter empty",
      HashMap.fromIter<Text, Text>([].vals(), 3, Text.equal, Text.hash).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "fromIter with collisions",
      do {
        let iter = [("key1", "value1"), ("key2", "value2")].vals();
        let tempMap = HashMap.fromIter<Text, Text>(
          iter,
          3,
          Text.equal,
          func _ = 0 // force collisions
        );
        Iter.toArray(tempMap.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key1", "value1"), ("key2", "value2")]
        )
      )
    ),
    Suite.test(
      "fromIter",
      do {
        let iter = [("key1", "value1"), ("key2", "value2")].vals();
        let tempMap = HashMap.fromIter<Text, Text>(
          iter,
          3,
          Text.equal,
          Text.hash
        );
        Iter.toArray(tempMap.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key1", "value1"), ("key2", "value2")]
        )
      )
    ),
    Suite.test(
      "map empty",
      HashMap.map<Text, Text, Nat>(emptyMap, Text.equal, Text.hash, func _ = 0).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "map with collisions",
      do {
        let tempMap = HashMap.map<Text, Text, Nat>(
          collidedMap,
          Text.equal,
          func _ = 0, // force collisions
          func p = p.1.size()
        );
        Iter.toArray(tempMap.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.natTestable),
          [("key1", 6), ("key2", 6)]
        )
      )
    ),
    Suite.test(
      "map",
      do {
        let tempMap = HashMap.map<Text, Text, Nat>(
          map,
          Text.equal,
          Text.hash,
          func p = p.1.size()
        );
        Iter.toArray(tempMap.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.natTestable),
          [("key2", 6), ("key1", 6)]
        )
      )
    ),
    Suite.test(
      "mapFilter empty",
      HashMap.mapFilter<Text, Text, Nat>(emptyMap, Text.equal, Text.hash, func _ = ?0).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "mapFilter with collisions",
      do {
        let tempMap = HashMap.mapFilter<Text, Text, Text>(
          collidedMap,
          Text.equal,
          func _ = 0, // force collisions
          func(key, value) = if (key == "key1") { ?value } else { null }
        );
        Iter.toArray(tempMap.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key1", "value1")]
        )
      )
    ),
    Suite.test(
      "mapFilter",
      do {
        let tempMap = HashMap.mapFilter<Text, Text, Text>(
          map,
          Text.equal,
          Text.hash,
          func(key, value) = if (key == "key1") { ?value } else { null }
        );
        Iter.toArray(tempMap.entries())
      },
      M.equals(
        T.array(
          T.tuple2Testable(T.textTestable, T.textTestable),
          [("key1", "value1")]
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
