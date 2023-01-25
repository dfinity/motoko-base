import Prim "mo:⛔";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

func newMap() : HashMap.HashMap<Text, Text> {
  HashMap.HashMap<Text, Text>(3, Text.equal, Text.hash)
};

let map = newMap();
map.put("key1", "value1");
map.put("key2", "value2");

let emptyMap = newMap();

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
      "empty get",
      emptyMap.get("key"),
      M.equals(T.optional(T.textTestable, null : ?Text))
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
    )
  ]
);

// FIXME test for collided and non collided maps

Suite.run(suite);

// debug {
//   let a = HashMap.HashMap<Text, Nat>(3, Text.equal, Text.hash);

//   a.put("apple", 1);
//   a.put("banana", 2);
//   a.put("pear", 3);
//   a.put("avocado", 4);
//   a.put("Apple", 11);
//   a.put("Banana", 22);
//   a.put("Pear", 33);
//   a.put("Avocado", 44);
//   a.put("ApplE", 111);
//   a.put("BananA", 222);
//   a.put("PeaR", 333);
//   a.put("AvocadO", 444);

//   // need to resupply the constructor args; they are private to the object; but, should they be?
//   let b = H.clone<Text, Nat>(a, Text.equal, Text.hash);

//   // ensure clone has each key-value pair present in original
//   for ((k, v) in a.entries()) {
//     Prim.debugPrint(debug_show (k, v));
//     switch (b.get(k)) {
//       case null { assert false };
//       case (?w) { assert v == w }
//     }
//   };

//   // ensure original has each key-value pair present in clone
//   for ((k, v) in b.entries()) {
//     Prim.debugPrint(debug_show (k, v));
//     switch (a.get(k)) {
//       case null { assert false };
//       case (?w) { assert v == w }
//     }
//   };

//   // ensure clone has each key present in original
//   for (k in a.keys()) {
//     switch (b.get(k)) {
//       case null { assert false };
//       case (?_) {}
//     }
//   };

//   // ensure clone has each value present in original
//   for (v in a.vals()) {
//     var foundMatch = false;
//     for (w in b.vals()) {
//       if (v == w) { foundMatch := true }
//     };
//     assert foundMatch
//   };

//   // do some more operations:
//   a.put("apple", 1111);
//   a.put("banana", 2222);
//   switch (a.remove("pear")) {
//     case null { assert false };
//     case (?three) { assert three == 3 }
//   };
//   a.delete("avocado");

//   // check them:
//   switch (a.get("apple")) {
//     case (?1111) {};
//     case _ { assert false }
//   };
//   switch (a.get("banana")) {
//     case (?2222) {};
//     case _ { assert false }
//   };
//   switch (a.get("pear")) {
//     case null {};
//     case (?_) { assert false }
//   };
//   switch (a.get("avocado")) {
//     case null {};
//     case (?_) { assert false }
//   };

//   // undo operations above:
//   a.put("apple", 1);
//   // .. and test that replace works
//   switch (a.replace("apple", 666)) {
//     case null { assert false };
//     case (?one) {
//       assert one == 1; // ...and revert
//       a.put("apple", 1)
//     }
//   };
//   a.put("banana", 2);
//   a.put("pear", 3);
//   a.put("avocado", 4);

//   // ensure clone has each key-value pair present in original
//   for ((k, v) in a.entries()) {
//     Prim.debugPrint(debug_show (k, v));
//     switch (b.get(k)) {
//       case null { assert false };
//       case (?w) { assert v == w }
//     }
//   };

//   // ensure original has each key-value pair present in clone
//   for ((k, v) in b.entries()) {
//     Prim.debugPrint(debug_show (k, v));
//     switch (a.get(k)) {
//       case null { assert false };
//       case (?w) { assert v == w }
//     }
//   };

//   // test fromIter method
//   let c = H.fromIter<Text, Nat>(b.entries(), 0, Text.equal, Text.hash);

//   // c agrees with each entry of b
//   for ((k, v) in b.entries()) {
//     Prim.debugPrint(debug_show (k, v));
//     switch (c.get(k)) {
//       case null { assert false };
//       case (?w) { assert v == w }
//     }
//   };

//   // b agrees with each entry of c
//   for ((k, v) in c.entries()) {
//     Prim.debugPrint(debug_show (k, v));
//     switch (b.get(k)) {
//       case null { assert false };
//       case (?w) { assert v == w }
//     }
//   };

//   // Issue #228
//   let d = H.HashMap<Text, Nat>(50, Text.equal, Text.hash);
//   switch (d.remove("test")) {
//     case null {};
//     case (?_) { assert false }
//   }
// }
