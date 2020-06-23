/// 64-bit signed integers with checked arithmetic
///
/// Most operations are available as built-in operators (`1 + 1`).
import Int "Int";
import Prim "mo:prim";

module {

  /// Returns the Text representation of `x`.
  public func toText(x : Int64) : Text {
    Int.toText(Int.fromInt64(x))
  };

  /// Conversion.
  public let toInt : Int64 -> Int = Prim.int64ToInt;

  /// Conversion. Traps on overflow/underflow.
  public let fromInt : Int -> Int64  = Prim.intToInt64;

  /// Returns the absolute value of `x`. Traps when `x = Traps when `x = -2^63.`
  public func abs(x : Int64) : Int64 {
    Int.toInt64(Int.abs(Int.fromInt64 x))
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Int64, y : Int64) : Int64 {
    if (x < y) x else y
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Int64, y : Int64) : Int64 {
    if (x < y) y else x
  };

  /// Returns `x == y`.
  public func equal(x : Int64, y : Int64) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Int64, y : Int64) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Int64, y : Int64) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Int64, y : Int64) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Int64, y : Int64) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Int64, y : Int64) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Int64, y : Int64) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the negation of `x`, `-x`. Traps on overflow.
  public func neg(x : Int64) : Int64 { -x; };

  /// Returns the sum of `x` and `y`, `x + y`. Traps on overflow.
  public func add(x : Int64, y : Int64) : Int64 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`. Traps on underflow.
  public func sub(x : Int64, y : Int64) : Int64 { x - y };

  /// Returns the product of `x` and `y`, `x * y`. Traps on overflow.
  public func mul(x : Int64, y : Int64) : Int64 { x * y };

  /// Returns the division of `x by y`, `x / y`. Traps on division by zero.
  public func div(x : Int64, y : Int64) : Int64 { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  public func rem(x : Int64, y : Int64) : Int64 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`. Traps on overflow.
  public func pow(x : Int64, y : Int64) : Int64 { x ** y };

}
