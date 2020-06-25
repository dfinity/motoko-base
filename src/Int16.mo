/// 16-bit signed integers with checked arithmetic
///
/// Most operations are available as built-in operators (`1 + 1`).
import Int "Int";
import Prim "mo:prim";

module {

  /// Conversion.
  public let toInt : Int16 -> Int = Prim.int16ToInt;

  /// Conversion. Traps on overflow/underflow.
  public let fromInt : Int -> Int16  = Prim.intToInt16;

  /// Returns the Text representation of `x`.
  public func toText(x : Int16) : Text {
    Int.toText(toInt(x))
  };

  /// Returns the absolute value of `x`. Traps when `x = -2^15`.
  public func abs(x : Int16) : Int16 {
    fromInt(Int.abs(toInt(x)))
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Int16, y : Int16) : Int16 {
    if (x < y) x else y
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Int16, y : Int16) : Int16 {
    if (x < y) y else x
  };

  /// Returns `x == y`.
  public func equal(x : Int16, y : Int16) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Int16, y : Int16) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Int16, y : Int16) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Int16, y : Int16) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Int16, y : Int16) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Int16, y : Int16) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Int16, y : Int16) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the negation of `x`, `-x`. Traps on overflow.
  public func neg(x : Int16) : Int16 { -x; };

  /// Returns the sum of `x` and `y`, `x + y`. Traps on overflow.
  public func add(x : Int16, y : Int16) : Int16 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`. Traps on underflow.
  public func sub(x : Int16, y : Int16) : Int16 { x - y };

  /// Returns the product of `x` and `y`, `x * y`. Traps on overflow.
  public func mul(x : Int16, y : Int16) : Int16 { x * y };

  /// Returns the division of `x by y`, `x / y`. Traps on division by zero.
  public func div(x : Int16, y : Int16) : Int16 { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  public func rem(x : Int16, y : Int16) : Int16 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`. Traps on overflow.
  public func pow(x : Int16, y : Int16) : Int16 { x ** y };

}
