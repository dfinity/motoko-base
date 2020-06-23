/// 32-bit unsigned integers with checked arithmetic
///
/// Most operations are available as built-in operators (`1 + 1`).
import Nat "Nat";

module {

  /// Returns the Text representation of x.
  public func toText(x : Nat32) : Text {
    Nat.toText(Nat.fromNat32(x))
  };

  /// Returns the minimum of x and y.
  public func min(x : Nat32, y : Nat32) : Nat32 {
    if (x < y) x else y
  };

  /// Returns the maximum of x and y.
  public func max( x : Nat32, y : Nat32) : Nat32 {
    if (x < y) y else x
  };

  /// Returns x == y.
  public func equal(x : Nat32, y : Nat32) : Bool { x == y };

  /// Returns x != y.
  public func notEqual(x : Nat32, y : Nat32) : Bool { x != y };

  /// Returns x < y.
  public func less(x : Nat32, y : Nat32) : Bool { x < y };

  /// Returns x <= y.
  public func lessOrEqual(x : Nat32, y : Nat32) : Bool { x <= y };

  /// Returns x > y.
  public func greater(x : Nat32, y : Nat32) : Bool { x > y };

  /// Returns x >= y.
  public func greaterOrEqual(x : Nat32, y : Nat32) : Bool { x >= y };

  /// Returns the order of x and y.
  public func compare(x : Nat32, y : Nat32) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the sum of x and y, x + y. Traps on overflow.
  public func add(x : Nat32, y : Nat32) : Nat32 { x + y };

  /// Returns the difference of x and y, x - y. Traps on underflow.
  public func sub(x : Nat32, y : Nat32) : Nat32 { x - y };

  /// Returns the product of x and y, x * y. Traps on overflow.
  public func mul(x : Nat32, y : Nat32) : Nat32 { x * y };

  /// Returns the division of x by y, x / y. Traps on division by zero.
  public func div(x : Nat32, y : Nat32) : Nat32 { x / y };

  /// Returns the remainder of x divided by y, x % y.
  public func rem(x : Nat32, y : Nat32) : Nat32 { x % y };

  /// Returns x to the power of y, x ** y. Traps on overflow.
  public func pow(x : Nat32, y : Nat32) : Nat32 { x ** y };

}
