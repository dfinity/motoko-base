import Debug "mo:base/Debug";
import Text "mo:base/Text";

Debug.print("Text");

{
  Debug.print("  concat");

  let actual = Text.concat("x", "y");
  let expected = "xy";

  assert(actual == expected);
};
