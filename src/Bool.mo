/// Boolean type and operations.

import Prim "mo:prim";

module {

  /// Conversion.
  public func toText(x : Bool) : Text {
    if (x) "true" else "false"
  };

  /// Returns `x and y`. Unlike `_ and _`, `logor(_, _)` evaluates both arguments.
  public func logand(x : Bool, y : Bool) : Bool { x and y };

  /// Returns `x or y`. Unlike `_ or _`, `logor(_, _)` evaluates both arguments.
  public func logor(x : Bool, y : Bool) : Bool { x or y };

  /// Returns exclusive or of `x` and `y`.
  public func logxor(x : Bool, y : Bool) : Bool {
    (x or y) and not (x and y)
  };

  /// Returns `not x`.
  public func lognot(x : Bool) : Bool { not x };

  /// Returns `x == y`.
  public func equal(x : Bool, y : Bool) : Bool { x == y };

  /// Returns `x != y`. 
  public func notEqual(x : Bool, y : Bool) : Bool { x != y };

  /// Returns the order of `x` and `y`, where `false < true`.
  public func compare(x : Bool, y : Bool) : {#less; #equal; #greater} {
    if x (if y #equal else #greater)
    else (if y #less else #equal)
  };

}
