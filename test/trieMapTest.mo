import Prim "mo:⛔";
import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Order "mo:base/Order";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

// Utilities to work with Matchers
func arrayTest(array : [(Nat, Nat)]) : M.Matcher<[(Nat, Nat)]> {
  M.equals<[(Nat, Nat)]>(T.array<(Nat, Nat)>(T.tuple2Testable<Nat, Nat>(T.natTestable, T.natTestable), array))
};

// Sample maps to use for testing
let map1 = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);
// resulting map is {(0, 10), (2, 12), (4, 14)}
map1.put(0, 10);
map1.put(2, 12);
map1.put(3, 13);
map1.put(4, 24);
map1.delete(3);
map1.delete(4);
map1.put(4, 14);

let suite = Suite.suite(
  "TrieMap",
  [
    Suite.test(
      "size",
      map1.size(),
      M.equals(T.nat(3))
    ),
    Suite.test(
      "size empty",
      TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash).size(),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "put",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.put(5, 15);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 10), (2, 12), (4, 14), (5, 15)])
    ),
    Suite.test(
      "put overwrite",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.put(0, 20);
        map.put(4, 24);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 20), (2, 12), (4, 24)])
    ),
    Suite.test(
      "put empty",
      do {
        let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);
        map.put(0, 10);
        map.put(2, 12);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 10), (2, 12)])
    ),
    Suite.test(
      "replace old value",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.replace(5, 15)
      },
      M.equals(T.optional<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "replace new map",
      do {
        let map = TrieMap.clone<Nat, Nat>(map1, Nat.equal, Hash.hash);
        ignore map.replace(5, 15);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 10), (2, 12), (4, 14), (5, 15)])
    ),
    Suite.test(
      "replace overwrite old value",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.replace(0, 20)
      },
      M.equals(T.optional(T.natTestable, ?10))
    ),
    Suite.test(
      "replace overwrite new map",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        ignore map.replace(0, 20);
        ignore map.replace(4, 24);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 20), (2, 12), (4, 24)])
    ),
    Suite.test(
      "replace empty",
      do {
        let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);
        ignore map.replace(0, 20);
        ignore map.replace(4, 24);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 20), (4, 24)])
    ),
    Suite.test(
      "get",
      map1.get(4),
      M.equals(T.optional(T.natTestable, ?14))
    ),
    Suite.test(
      "get key not present",
      map1.get(3),
      M.equals(T.optional<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "get empty",
      TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash).get(3),
      M.equals(T.optional<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "delete",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.delete(2);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 10), (4, 14)])
    ),
    Suite.test(
      "delete key not present",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.delete(3);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "delete empty",
      do {
        let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);
        map.delete(3);
        Iter.toArray(map.entries())
      },
      arrayTest([])
    ),
    Suite.test(
      "remove old value",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.remove(4)
      },
      M.equals(T.optional(T.natTestable, ?14))
    ),
    Suite.test(
      "remove new map",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        ignore map.remove(4);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 10), (2, 12)])
    ),
    Suite.test(
      "remove key not present old value",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.remove(3)
      },
      M.equals(T.optional<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "remove key not present new map",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        ignore map.remove(3);
        Iter.toArray(map.entries())
      },
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "remove empty old value",
      do {
        let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);
        map.remove(3)
      },
      M.equals(T.optional<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "remove empty new map",
      do {
        let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);
        ignore map.remove(3);
        Iter.toArray(map.entries())
      },
      arrayTest([])
    ),
    Suite.test(
      "keys",
      Iter.toArray(map1.keys()),
      M.equals(T.array(T.natTestable, [0, 2, 4]))
    ),
    Suite.test(
      "keys empty",
      Iter.toArray(TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash).keys()),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "vals",
      Iter.toArray(map1.vals()),
      M.equals(T.array(T.natTestable, [10, 12, 14]))
    ),
    Suite.test(
      "vals empty",
      Iter.toArray(TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash).vals()),
      M.equals(T.array<Nat>(T.natTestable, []))
    ),
    Suite.test(
      "entries",
      Iter.toArray(map1.entries()),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "entries empty",
      Iter.toArray(TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash).entries()),
      arrayTest([])
    ),
    Suite.test(
      "clone",
      Iter.toArray(TrieMap.clone<Nat, Nat>(map1, Nat.equal, Hash.hash).entries()),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "clone empty",
      Iter.toArray(
        TrieMap.clone(
          TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash),
          Nat.equal,
          Hash.hash
        ).entries()
      ),
      arrayTest([])
    ),
    Suite.test(
      "fromEntries round trip",
      Iter.toArray(
        TrieMap.fromEntries<Nat, Nat>(
          [(0, 10), (2, 12), (4, 14)].vals(),
          Nat.equal,
          Hash.hash
        ).entries()
      ),
      arrayTest([(0, 10), (2, 12), (4, 14)])
    ),
    Suite.test(
      "fromEntries empty round trip",
      Iter.toArray(
        TrieMap.fromEntries<Nat, Nat>(
          [].vals(),
          Nat.equal,
          Hash.hash
        ).entries()
      ),
      arrayTest([])
    ),
    Suite.test(
      "map",
      Iter.toArray(
        TrieMap.map<Nat, Nat, Nat>(
          map1,
          Nat.equal,
          Hash.hash,
          Nat.add
        ).entries()
      ),
      arrayTest([(0, 10), (2, 14), (4, 18)])
    ),
    Suite.test(
      "map empty",
      Iter.toArray(
        TrieMap.map<Nat, Nat, Nat>(
          TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash),
          Nat.equal,
          Hash.hash,
          Nat.add
        ).entries()
      ),
      arrayTest([])
    ),
    Suite.test(
      "mapFilter",
      Iter.toArray(
        TrieMap.mapFilter<Nat, Nat, Nat>(
          map1,
          Nat.equal,
          Hash.hash,
          func(k, v) {
            if (k == 0) {
              null
            } else {
              ?(k + v)
            }
          }
        ).entries()
      ),
      arrayTest([(2, 14), (4, 18)])
    ),
    Suite.test(
      "mapFilter all",
      Iter.toArray(
        TrieMap.mapFilter<Nat, Nat, Nat>(
          map1,
          Nat.equal,
          Hash.hash,
          func _ = null
        ).entries()
      ),
      arrayTest([])
    ),
    Suite.test(
      "mapFilter none",
      Iter.toArray(
        TrieMap.mapFilter<Nat, Nat, Nat>(
          map1,
          Nat.equal,
          Hash.hash,
          func(k, v) = ?(k + v)
        ).entries()
      ),
      arrayTest([(0, 10), (2, 14), (4, 18)])
    ),
    Suite.test(
      "mapFilter empty",
      Iter.toArray(
        TrieMap.mapFilter<Nat, Nat, Nat>(
          TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash),
          Nat.equal,
          Hash.hash,
          func(k, v) = ?(k + v)
        ).entries()
      ),
      arrayTest([])
    )
  ]
);

Suite.run(suite);

/* --------------------------------------- */

object Random {
  var number = 4711;
  public func next() : Nat {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

func shuffle(array : [Nat]) : [Nat] {
  let extended = Array.map<Nat, (Nat, Nat)>(array, func(value) { (value, Random.next()) });
  let sorted = Array.sort<(Nat, Nat)>(
    extended,
    func(first, second) {
      Nat.compare(first.1, second.1)
    }
  );
  Array.map<(Nat, Nat), Nat>(
    sorted,
    func(value) {
      value.0
    }
  )
};

let testSize = 1_000;

let testKeys = shuffle(Array.tabulate<Nat>(testSize, func(index) { index }));

func buildTestTrie() : TrieMap.TrieMap<Nat, Text> {
  let trie = TrieMap.TrieMap<Nat, Text>(Nat.equal, Hash.hash);
  for (key in testKeys.vals()) {
    trie.put(key, debug_show (key))
  };
  trie
};

func expectedKeyValuePairs(keys : [Nat]) : [(Nat, Text)] {
  Array.tabulate<(Nat, Text)>(keys.size(), func(index) { (keys[index], debug_show (keys[index])) })
};

let expectedEntries = expectedKeyValuePairs(Array.sort(testKeys, Nat.compare));
let expectedKeys = Array.sort(testKeys, Nat.compare);
let expectedValues = Array.sort(Array.map<Nat, Text>(expectedKeys, func(key) { debug_show (key) }), Text.compare);

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

func compareByKey(first : (Nat, Text), second : (Nat, Text)) : Order.Order {
  Nat.compare(first.0, second.0)
};

func sortedEntries(trie : TrieMap.TrieMap<Nat, Text>) : [(Nat, Text)] {
  Array.sort(Iter.toArray(trie.entries()), compareByKey)
};

class TrieMatcher(expected : [(Nat, Text)]) : M.Matcher<TrieMap.TrieMap<Nat, Text>> {
  public func describeMismatch(actual : TrieMap.TrieMap<Nat, Text>, description : M.Description) {
    Prim.debugPrint(debug_show (sortedEntries(actual)) # " should be " # debug_show (expected))
  };

  public func matches(actual : TrieMap.TrieMap<Nat, Text>) : Bool {
    sortedEntries(actual) == expected
  }
};

let randomTestSuite = Suite.suite(
  "random trie",
  [
    Suite.test(
      "size",
      buildTestTrie().size(),
      M.equals(T.nat(testSize))
    ),
    Suite.test(
      "iterate entries",
      sortedEntries(buildTestTrie()),
      M.equals(T.array<(Nat, Text)>(entryTestable, expectedEntries))
    ),
    Suite.test(
      "iterate keys",
      Array.sort(Iter.toArray(buildTestTrie().keys()), Nat.compare),
      M.equals(T.array<Nat>(T.natTestable, expectedKeys))
    ),
    Suite.test(
      "iterate values",
      Array.sort(Iter.toArray(buildTestTrie().vals()), Text.compare),
      M.equals(T.array<Text>(T.textTestable, expectedValues))
    ),
    Suite.test(
      "get all",
      do {
        let trie = buildTestTrie();
        for (key in testKeys.vals()) {
          let value = trie.get(key);
          assert (value == ?debug_show (key))
        };
        trie
      },
      TrieMatcher(expectedEntries)
    ),
    Suite.test(
      "replace all",
      do {
        let trie = buildTestTrie();
        for (key in testKeys.vals()) {
          let value = trie.replace(key, "TEST-" # debug_show (key));
          assert (value == ?debug_show (key))
        };
        trie
      },
      TrieMatcher(Array.map<Nat, (Nat, Text)>(expectedKeys, func(key) { (key, "TEST-" # debug_show (key)) }))
    ),
    Suite.test(
      "remove randomized",
      do {
        let trie = buildTestTrie();
        var count = 0;
        for (key in testKeys.vals()) {
          if (Random.next() % 2 == 0) {
            let result = trie.remove(key);
            assert (result == ?debug_show (key));
            count += 1
          }
        };
        trie.size() == +testKeys.size() - count
      },
      M.equals(T.bool(true))
    ),
    Suite.test(
      "clear",
      do {
        let trie = buildTestTrie();
        for ((key, value) in trie.entries()) {
          // stable iteration
          assert (debug_show (key) == value);
          let result = trie.remove(key);
          assert (result == ?debug_show (key))
        };
        trie
      },
      TrieMatcher([])
    )
  ]
);

Suite.run(randomTestSuite);

/* --------------------------------------- */

debug {
  let a = TrieMap.TrieMap<Text, Nat>(Text.equal, Text.hash);

  assert a.size() == 0;
  ignore a.remove("apple");
  assert a.size() == 0;

  a.put("apple", 1);
  assert a.size() == 1;
  ignore a.remove("apple");
  assert a.size() == 0;

  a.put("apple", 1);
  a.put("banana", 2);
  a.put("pear", 3);
  a.put("avocado", 4);
  a.put("Apple", 11);
  a.put("Banana", 22);
  a.put("Pear", 33);
  a.put("Avocado", 44);
  a.put("ApplE", 111);
  a.put("BananA", 222);
  a.put("PeaR", 333);
  a.put("AvocadO", 444);

  // need to resupply the constructor args; they are private to the object; but, should they be?
  let b = TrieMap.clone<Text, Nat>(a, Text.equal, Text.hash);

  // ensure clone has each key-value pair present in original
  for ((k, v) in a.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (b.get(k)) {
      case null { assert false };
      case (?w) { assert v == w }
    }
  };

  // ensure clone has each key present in original
  for (k in a.keys()) {
    switch (b.get(k)) {
      case null { assert false };
      case (?_) {}
    }
  };

  // ensure clone has each value present in original
  for (v in a.vals()) {
    var foundMatch = false;
    for (w in b.vals()) {
      if (v == w) { foundMatch := true }
    };
    assert foundMatch
  };

  // ensure original has each key-value pair present in clone
  for ((k, v) in b.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (a.get(k)) {
      case null { assert false };
      case (?w) { assert v == w }
    }
  };

  // do some more operations:
  a.put("apple", 1111);
  a.put("banana", 2222);
  a.delete("pear");
  a.delete("avocado");

  // check them:
  switch (a.get("apple")) {
    case (?1111) {};
    case _ { assert false }
  };
  switch (a.get("banana")) {
    case (?2222) {};
    case _ { assert false }
  };
  switch (a.get("pear")) {
    case null {};
    case (?_) { assert false }
  };
  switch (a.get("avocado")) {
    case null {};
    case (?_) { assert false }
  };

  // undo operations above:
  a.put("apple", 1);
  a.put("banana", 2);
  a.put("pear", 3);
  a.put("avocado", 4);

  // ensure clone has each key-value pair present in original
  for ((k, v) in a.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (b.get(k)) {
      case null { assert false };
      case (?w) { assert v == w }
    }
  };

  // ensure original has each key-value pair present in clone
  for ((k, v) in b.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (a.get(k)) {
      case null { assert false };
      case (?w) { assert v == w }
    }
  };

  // test fromEntries method
  let c = TrieMap.fromEntries<Text, Nat>(b.entries(), Text.equal, Text.hash);

  // c agrees with each entry of b
  for ((k, v) in b.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (c.get(k)) {
      case null { assert false };
      case (?w) { assert v == w }
    }
  };

  // b agrees with each entry of c
  for ((k, v) in c.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (b.get(k)) {
      case null { assert false };
      case (?w) { assert v == w }
    }
  }
}
