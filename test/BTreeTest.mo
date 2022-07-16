import Debug "mo:base/Debug";
import BT "mo:base/BTree";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

Debug.print "BTree tests: Begin.";

func check(t : BT.Tree<Text, Nat>){ BT.Check.root<Text, Nat>({compare=Text.compare; show=func (t:Text) : Text { t }}, t) };

Debug.print "empty1.";
let empty1 = #internal({data=[]; trees=[]});
check(empty1);

Debug.print "empty2.";
let empty2 = #leaf([]);
check(empty2);

Debug.print "leaf of one.";
let leaf_of_one = #leaf([("oak", 1)]);
check(leaf_of_one);

Debug.print "leaf of two.";
let leaf_of_two = #leaf([("ash", 1), ("oak", 2)]);
check(leaf_of_two);

Debug.print "leaf of three. A-C";
let leaf_of_three_a_c = #leaf([("apple", 1), ("ash", 4), ("crab apple", 3)]);
check(leaf_of_three_a_c);

Debug.print "leaf of three. S-W";
let leaf_of_three_s_w = #leaf([("salix", 1), ("sallows", 4), ("willow", 3)]);
check(leaf_of_three_s_w);

Debug.print "binary internal.";
let binary_internal = #internal({data=[("pine", 42)]; trees=[leaf_of_three_a_c, leaf_of_three_s_w]});
check(binary_internal);

let _ = Suite.suite("find", [
  Suite.test("pine",
    BT.find<Text, Nat>(binary_internal, "pine", Text.compare),
    M.equals(T.optional<Nat>(T.natTestable, ?42))
  )
]);


Debug.print "BTree tests: End.";
