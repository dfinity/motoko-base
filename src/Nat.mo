/// Natural numbers
///
/// Most operations on natural numbers (e.g. addition) are available as built-in operators (e.g. `1 + 1`).
/// This module provides equivalent functions and `Text` conversion.

import Int "Int";
import Order "Order";
import Prim "mo:⛔";
import Char "Char";

module {

  /// Infinite precision natural numbers.
  public type Nat = Prim.Types.Nat;

  /// Conversion.
  public func toText(n : Nat) : Text = Int.toText n;

  public func fromText(text : Text) : ?Nat {
    var n = 0;
    for (c in text.chars()) {
      if (Char.isDigit(c)) {
        let charAsNat = Prim.nat32ToNat(Prim.charToNat32(c) -% Prim.charToNat32('0'));
        n := n * 10 + charAsNat
      } else {
        return null
      }
    };
    ?n
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Nat, y : Nat) : Nat {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  public func max(x : Nat, y : Nat) : Nat {
    if (x < y) { y } else { x }
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
  public func compare(x : Nat, y : Nat) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the sum of `x` and `y`, `x + y`.
  public func add(x : Nat, y : Nat) : Nat { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  /// Traps on underflow.
  public func sub(x : Nat, y : Nat) : Nat { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  public func mul(x : Nat, y : Nat) : Nat { x * y };

  /// Returns the division of `x` by `y`, `x / y`.
  /// Traps when `y` is zero.
  public func div(x : Nat, y : Nat) : Nat { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  /// Traps when `y` is zero.
  public func rem(x : Nat, y : Nat) : Nat { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  public func pow(x : Nat, y : Nat) : Nat { x ** y };

}
