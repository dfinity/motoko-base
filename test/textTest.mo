import Debug "mo:base/Debug";
import Text "mo:base/Text";

Debug.print("Text");

{
  Debug.print("  append");

  let actual = Text.append("x", "y");
  let expected = "xy";

  assert(actual == expected);
};
