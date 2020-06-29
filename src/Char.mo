/// Characters

import Prim "mo:prim";
module {
  public func isDigit(char : Char) : Bool {
    Prim.charToWord32(char) - Prim.charToWord32('0') <= (9 : Word32)
  };

  /// Returns `x == y`.
  public func equal(x : Char, y : Char) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Char, y : Char) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Char, y : Char) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Char, y : Char) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Char, y : Char) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Char, y : Char) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Char, y : Char) : { #less; #equal; #greater } {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

}
