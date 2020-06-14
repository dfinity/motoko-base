import Array "mo:base/Array";
import None "mo:base/None";
import Prelude "mo:base/Prelude";

Prelude.printLn("None");

{
  Prelude.printLn("  absurd");

  func showNone(x : None) : Text {
    None.absurd<Text>(x);
  };
};
