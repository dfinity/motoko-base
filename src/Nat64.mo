/// 64-bit unsigned integers with checked arithmetic
///
/// Most operations are available as built-in operators (e.g. `1 + 1`).
import Nat "Nat";
import Prim "mo:prim";

module {

  /// Conversion.
  public let toNat : Nat64 -> Nat = Prim.nat64ToNat;

  /// Conversion. Traps on overflow/underflow.
  public let fromNat : Nat -> Nat64  = Prim.natToNat64;

  /// Returns the Text representation of `x`.
  public func toText(x : Nat64) : Text {
    Nat.toText(toNat(x))
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Nat64, y : Nat64) : Nat64 {
    if (x < y) x else y
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Nat64, y : Nat64) : Nat64 {
    if (x < y) y else x
  };

  /// Returns `x == y`.
  public func equal(x : Nat64, y : Nat64) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Nat64, y : Nat64) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Nat64, y : Nat64) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Nat64, y : Nat64) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Nat64, y : Nat64) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Nat64, y : Nat64) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Nat64, y : Nat64) : { #less; #equal; #greater } {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the sum of `x` and `y`, `x + y`. Traps on overflow.
  public func add(x : Nat64, y : Nat64) : Nat64 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`. Traps on underflow.
  public func sub(x : Nat64, y : Nat64) : Nat64 { x - y };

  /// Returns the product of `x` and `y`, `x * y`. Traps on overflow.
  public func mul(x : Nat64, y : Nat64) : Nat64 { x * y };

  /// Returns the division of `x by y`, `x / y`.
  /// Traps when `y` is zero.
  public func div(x : Nat64, y : Nat64) : Nat64 { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  /// Traps when `y` is zero.
  public func rem(x : Nat64, y : Nat64) : Nat64 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`. Traps on overflow.
  public func pow(x : Nat64, y : Nat64) : Nat64 { x ** y };

}
