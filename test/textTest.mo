import Prelude "mo:base/Prelude";
import Text "mo:base/Text";

Prelude.debugPrintLine("Text");

{
  Prelude.debugPrintLine("  append");

  let actual = Text.append("x", "y");
  let expected = "xy";

  assert(actual == expected);
};
