import Prim "mo:⛔";
import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Nat "mo:base/Nat";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

// Utility functions to work with Matchers
func arrayTest(array : [(Nat, Nat)]) : M.Matcher<[(Nat, Nat)]> {
  M.equals<[(Nat, Nat)]>(T.array<(Nat, Nat)>(T.tuple2Testable<Nat, Nat>(T.natTestable, T.natTestable), array));
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
      M.equals(T.nat(3)),
    ),
    Suite.test(
      "size empty",
      TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash).size(),
      M.equals(T.nat(0)),
    ),
    Suite.test(
      "size empty",
      TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash).size(),
      M.equals(T.nat(0)),
    ),
    Suite.test(
      "put",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.put(5, 15);
        Iter.toArray(map.entries());
      },
      arrayTest([(0, 10), (2, 12), (4, 14), (5, 15)]),
    ),
    Suite.test(
      "put overwrite",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.put(0, 20);
        map.put(4, 24);
        Iter.toArray(map.entries());
      },
      arrayTest([(0, 20), (2, 12), (4, 24)]),
    ),
    Suite.test(
      "put empty",
      do {
        let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash);
        map.put(0, 10);
        map.put(2, 12);
        Iter.toArray(map.entries());
      },
      arrayTest([(0, 10), (2, 12)]),
    ),
    Suite.test(
      "replace old value",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.replace(5, 15);
      },
      M.equals(T.optional(T.natTestable, null : ?Nat)),
    ),
    Suite.test(
      "replace new map",
      do {
        let map = TrieMap.clone<Nat, Nat>(map1, Nat.equal, Hash.hash);
        ignore map.replace(5, 15);
        Iter.toArray(map.entries());
      },
      arrayTest([(0, 10), (2, 12), (4, 14), (5, 15)]),
    ),
    Suite.test(
      "replace overwrite old value",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        map.replace(0, 20);
      },
      M.equals(T.optional(T.natTestable, ?10)),
    ),
    Suite.test(
      "replace overwrite new map",
      do {
        let map = TrieMap.clone(map1, Nat.equal, Hash.hash);
        ignore map.replace(0, 20);
        ignore map.replace(4, 24);
        Iter.toArray(map.entries());
      },
      arrayTest([(0, 20), (2, 12), (4, 24)]),
    ),
  ],
);

Suite.run(suite);

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
      case (?w) { assert v == w };
    };
  };

  // ensure clone has each key present in original
  for (k in a.keys()) {
    switch (b.get(k)) {
      case null { assert false };
      case (?_) {};
    };
  };

  // ensure clone has each value present in original
  for (v in a.vals()) {
    var foundMatch = false;
    for (w in b.vals()) {
      if (v == w) { foundMatch := true };
    };
    assert foundMatch;
  };

  // ensure original has each key-value pair present in clone
  for ((k, v) in b.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (a.get(k)) {
      case null { assert false };
      case (?w) { assert v == w };
    };
  };

  // do some more operations:
  a.put("apple", 1111);
  a.put("banana", 2222);
  a.delete("pear");
  a.delete("avocado");

  // check them:
  switch (a.get("apple")) {
    case (?1111) {};
    case _ { assert false };
  };
  switch (a.get("banana")) {
    case (?2222) {};
    case _ { assert false };
  };
  switch (a.get("pear")) {
    case null {};
    case (?_) { assert false };
  };
  switch (a.get("avocado")) {
    case null {};
    case (?_) { assert false };
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
      case (?w) { assert v == w };
    };
  };

  // ensure original has each key-value pair present in clone
  for ((k, v) in b.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (a.get(k)) {
      case null { assert false };
      case (?w) { assert v == w };
    };
  };

  // test fromEntries method
  let c = TrieMap.fromEntries<Text, Nat>(b.entries(), Text.equal, Text.hash);

  // c agrees with each entry of b
  for ((k, v) in b.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (c.get(k)) {
      case null { assert false };
      case (?w) { assert v == w };
    };
  };

  // b agrees with each entry of c
  for ((k, v) in c.entries()) {
    Prim.debugPrint(debug_show (k, v));
    switch (b.get(k)) {
      case null { assert false };
      case (?w) { assert v == w };
    };
  };
};
