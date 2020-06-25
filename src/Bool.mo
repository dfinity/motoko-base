/// Characters

import Prim "mo:prim";
module {

  /// Conversion.
  public func toText(x : Bool) : Text {
    if (x) "true" else "false"
  };

  /// Returns `x == y`.
  public func equal(x : Bool, y : Bool) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Bool, y : Bool) : Bool { x != y };

}
