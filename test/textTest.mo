import Prelude "mo:base/Prelude";
import Text "mo:base/Text";

Prelude.printLn("Text");

{
  Prelude.printLn("  append");

  let actual = Text.append("x", "y");
  let expected = "xy";

  assert(actual == expected);
};
