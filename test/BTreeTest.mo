import Debug "mo:base/Debug";
import BT "mo:base/BTree";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

Debug.print "BTree tests: Begin.";

let empty1 = #internal({data=[]; trees=[]});
let empty2 = #leaf([]);
let leaf_of_one = #leaf([("oak", 1)]);
let leaf_of_two = #leaf([("ash", 1), ("oak", 2)]);
let leaf_of_three_a_c = #leaf([("apple", 1), ("ash", 4), ("crab apple", 3)]);
let leaf_of_three_s_w = #leaf([("salix", 11), ("sallows", 44), ("willow", 33)]);
let binary_internal = #internal(
  {
    data=[("pine", 42)];
    trees=[leaf_of_three_a_c, leaf_of_three_s_w]
  });

let _ = Suite.suite(
  "constructions and checks.",
  [ // These checks-as-assertions can be refactored into value-producing checks,
    // if that seems useful.  Then, they can be individual matchers tests.  Again, if useful.
    Suite.test("assertions.", try {
      Debug.print "empty1.";
      BT.assertIsValidTextKeys(empty1);

      Debug.print "empty2.";
      BT.assertIsValidTextKeys(empty2);

      Debug.print "leaf of one.";
      BT.assertIsValidTextKeys(leaf_of_one);

      Debug.print "leaf of two.";
      BT.assertIsValidTextKeys(leaf_of_two);

      Debug.print "leaf of three. A-C";
      BT.assertIsValidTextKeys(leaf_of_three_a_c);

      Debug.print "leaf of three. S-W";
      BT.assertIsValidTextKeys(leaf_of_three_s_w);

      Debug.print "binary internal.";
      BT.assertIsValidTextKeys(binary_internal);

      true
    } catch _ { false },
    M.equals(T.bool(true))
  )]);

let _ = Suite.suite("find", [
  Suite.test("pine",
    BT.find<Text, Nat>(binary_internal, "pine", Text.compare),
    M.equals(T.optional<Nat>(T.natTestable, ?42))
  ),
  Suite.test("apple",
    BT.find<Text, Nat>(binary_internal, "apple", Text.compare),
    M.equals(T.optional<Nat>(T.natTestable, ?1))
  ),
  Suite.test("willow",
    BT.find<Text, Nat>(binary_internal, "willow", Text.compare),
    M.equals(T.optional<Nat>(T.natTestable, ?33))
  ),
]);

Debug.print "BTree tests: End.";
