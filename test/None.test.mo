import Array "../src/Array";
import None "../src/None";
import Debug "../src/Debug";

Debug.print("None");

do {
  Debug.print("  impossible");

  func showNone(x : None) : Text {
    None.impossible<Text>(x)
  }
}
