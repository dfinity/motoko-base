/// Natural numbers
///
/// Most operations on natural numbers (e.g. addition) are available as built-in operators (`1 + 1`).
/// This module provides conversion functions.
///
/// The conversions `toNat*` will trap if the number is out of bounds; the conversions `toWord*` will wrap-around.

import Int "Int";
import Order "Order";
import Prim "mo:prim";

module {

  /// Conversion.
  public let toText : Nat -> Text = Int.toText;

  /// Conversion.
  public let fromWord16 : Word16 -> Nat = Prim.word16ToNat;
  /// Conversion.
  public let fromWord32 : Word32 -> Nat = Prim.word32ToNat;
  /// Conversion.
  public let fromWord64 : Word64 -> Nat = Prim.word64ToNat;

  /// Conversion. Traps on overflow.
  public let toWord16   : Nat -> Word16 = Prim.natToWord16;
  /// Conversion. Traps on overflow.
  public let toWord32   : Nat -> Word32 = Prim.natToWord32;
  /// Conversion. Traps on overflow.
  public let toWord64   : Nat -> Word64 = Prim.natToWord64;

  /// Returns the minimum of `x` and `y`.
  public func min(x : Nat, y : Nat) : Nat {
    if (x < y) x else y
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Nat, y : Nat) : Nat {
    if (x < y) y else x
  };

  /// Returns `x == y`.
  public func equal(x : Nat, y : Nat) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Nat, y : Nat) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Nat, y : Nat) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Nat, y : Nat) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Nat, y : Nat) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Nat, y : Nat) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Nat, y : Nat) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the sum of `x` and `y`, `x + y`.
  public func add(x : Nat, y : Nat) : Nat { x + y };

  /// Returns the difference of `x` and `y`, `x - y`. Traps on underflow.
  public func sub(x : Nat, y : Nat) : Nat { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  public func mul(x : Nat, y : Nat) : Nat { x * y };

  /// Returns the division of `x` by `y`, `x / y`. Traps on division by zero.
  public func div(x : Nat, y : Nat) : Nat { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  public func rem(x : Nat, y : Nat) : Nat { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  public func pow(x : Nat, y : Nat) : Nat { x ** y };

}
