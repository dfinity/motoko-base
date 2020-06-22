/// 32-bit integers with checked arithmetic
///
/// Most operations are available as built-in operators (`1 + 1`).
import Int "Int";

module {

  /// Returns the Text representation of x.
  public func toText(x : Int32) : Text {
    Int.toText(Int.fromInt32(x))
  };

  /// Returns the minimum of x and y.
  public func min(x : Int32, y : Int32) : Int32 {
    if (x < y) x else y;
  };

  /// Returns the maximum of x and y.
  public func max( x : Int32, y : Int32) : Int32 {
    if (x < y) y else x;
  };

  /// Returns x == y.
  public func equal(x : Int32, y : Int32) : Bool { x == y };

  /// Returns x != y.
  public func notEqual(x : Int32, y : Int32) : Bool { x != y };

  /// Returns x < y.
  public func less(x : Int32, y : Int32) : Bool { x < y };

  /// Returns x <= y.
  public func lessOrEqual(x : Int32, y : Int32) : Bool { x <= y };

  /// Returns x > y.
  public func greater(x : Int32, y : Int32) : Bool { x > y };

  /// Returns x >= y.
  public func greaterOrEqual(x : Int32, y : Int32) : Bool { x >= y };

  /// Returns the order of x and y.
  public func compare(x : Int32, y : Int32) : { #less; #equal; #greater} {
    if (x < y)
     #less
    else if (x == y)
     #equal
    else #greater
  };

  /// Returns the negation of x, -x. Traps on overflow.
  public func neq(x : Int32) : Int32 { -x; };

  /// Returns the sum of x and y, x + y. Traps on underflow.
  public func add(x : Int32, y : Int32) : Int32 { x + y };

  /// Returns the difference of x and y, x - y.
  public func sub(x : Int32, y : Int32) : Int32 { x - y };

  /// Returns the product of x and y. Traps on overflow.
  public func mul(x : Int32, y : Int32) : Int32 { x * y };

  /// Returns the division of x by y. Traps on division by zero.
  public func div(x : Int32, y : Int32) : Int32 { x / y };

  /// Returns the remainder of x divided by y, x % y.
  public func rem(x : Int32, y : Int32) : Int32 { x % y };

  /// Returns x to the power of y, x ** y. Traps on overflow.
  public func pow(x : Int32, y : Int32) : Int32 { x ** y };

}
