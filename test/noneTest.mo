import Array "mo:base/Array";
import None "mo:base/None";
import Prelude "mo:base/Prelude";

Prelude.debugPrintLine("None");

{
  Prelude.debugPrintLine("  impossible");

  func showNone(x : None) : Text {
    None.impossible<Text>(x);
  };
};
