import Array "mo:base/Array";
import None "mo:base/None";
import Debug "mo:base/Debug";

Debug.print("None");

do {
  Debug.print("  impossible");

  func showNone(x : None) : Text {
    None.impossible<Text>(x)
  }
}
