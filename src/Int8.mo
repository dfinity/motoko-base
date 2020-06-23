/// 8-bit signed integers with checked arithmetic
///
/// Most operations are available as built-in operators (`1 + 1`).
import Int "Int";
import Prim "mo:prim";

module {

  /// Returns the Text representation of `x`.
  public func toText(x : Int8) : Text {
    Int.toText(Int.fromInt8(x))
  };

  /// Conversion.
  public let toInt : Int8 -> Int = Prim.int8ToInt;

  /// Conversion. Traps on overflow/underflow.
  public let fromInt : Int -> Int8  = Prim.intToInt8;

  /// Returns the absolute value of `x`. Traps when `x = -2^7`.
  public func abs(x : Int8) : Int8 {
    Int.toInt8(Int.abs(Int.fromInt8 x))
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Int8, y : Int8) : Int8 {
    if (x < y) x else y
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Int8, y : Int8) : Int8 {
    if (x < y) y else x
  };

  /// Returns `x == y`.
  public func equal(x : Int8, y : Int8) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Int8, y : Int8) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Int8, y : Int8) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Int8, y : Int8) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Int8, y : Int8) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Int8, y : Int8) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Int8, y : Int8) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the negation of `x`, `-x`. Traps on overflow.
  public func neg(x : Int8) : Int8 { -x; };

  /// Returns the sum of `x` and `y`, `x + y`. Traps on overflow.
  public func add(x : Int8, y : Int8) : Int8 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`. Traps on underflow.
  public func sub(x : Int8, y : Int8) : Int8 { x - y };

  /// Returns the product of `x` and `y`, `x * y`. Traps on overflow.
  public func mul(x : Int8, y : Int8) : Int8 { x * y };

  /// Returns the division of `x by y`, `x / y`. Traps on division by zero.
  public func div(x : Int8, y : Int8) : Int8 { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  public func rem(x : Int8, y : Int8) : Int8 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`. Traps on overflow.
  public func pow(x : Int8, y : Int8) : Int8 { x ** y };

}
