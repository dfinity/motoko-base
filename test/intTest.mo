import Debug "mo:base/Debug";
import Int "mo:base/Int";

Debug.print("Int");

do {
  Debug.print("  add");

  assert(Int.add(1, Int.add(2, 3)) == Int.add(1, Int.add(2, 3)));
  assert(Int.add(0, 1) == 1);
  assert(1 == Int.add(1, 0));
  assert(Int.add(0, 1) == Int.add(1, 0));
  assert(Int.add(1, 2) == Int.add(2, 1));
};

do {
  Debug.print("  toText");

  assert(Int.toText(0) == "0");
  assert(Int.toText(-0) == "0");
  assert(Int.toText(1234) == "1234");
  assert(Int.toText(-1234) == "-1234");
};
