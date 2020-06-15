import Debug "mo:base/Debug";
import P "mo:base/Prelude";
import Nat "mo:base/Nat";
import I "mo:base/Iter";
import List "mo:base/List";
import RBT "mo:base/RBTree";

let sorted =
  [
    (1, "reformer"),
    (2, "helper"),
    (3, "achiever"),
    (4, "individualist"),
    (5, "investigator"),
    (6, "loyalist"),
    (7, "enthusiast"),
    (8, "challenger"),
    (9, "peacemaker"),
  ];

let unsort =
  [
    (6, "loyalist"),
    (3, "achiever"),
    (9, "peacemaker"),
    (1, "reformer"),
    (4, "individualist"),
    (2, "helper"),
    (8, "challenger"),
    (5, "investigator"),
    (7, "enthusiast"),
  ];

var t = RBT.RBTree<Nat, Text>(Nat.compare);

for ((num, lab) in unsort.vals()) {
  Debug.print (Nat.toText num);
  Debug.print lab;
  t.put(num, lab);
};

{ var i = 1;
for ((num, lab) in t.entries()) {
  assert(num == i);
 i += 1;
}};

{ var i = 9;
for ((num, lab) in t.entriesRev()) {
  assert(num == i);
  i -= 1;
}};
