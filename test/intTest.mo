import Prelude "mo:base/Prelude";
import Int "mo:base/Int";

Prelude.debugPrintLine("Int");

{
  Prelude.debugPrintLine("  add");

  assert(Int.add(1, Int.add(2, 3)) == Int.add(1, Int.add(2, 3)));
  assert(Int.add(0, 1) == 1);
  assert(1 == Int.add(1, 0));
  assert(Int.add(0, 1) == Int.add(1, 0));
  assert(Int.add(1, 2) == Int.add(2, 1));
};

{
  Prelude.debugPrintLine("  toText");

  assert(Int.toText(0) == "0");
  assert(Int.toText(-0) == "0");
  assert(Int.toText(1234) == "1234");
  assert(Int.toText(-1234) == "-1234");
};
