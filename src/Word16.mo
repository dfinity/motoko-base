/// 16-bit binary unsigned integers with modular arithmetic
///
/// Most operations are available as built-in operators (e.g. `1 | 1`).

import Nat "Nat";
import Prim "mo:⛔";

module {

  /// Conversion.
  public let toNat : Word16 -> Nat = Prim.word16ToNat;

  /// Conversion. Wraps around.
  public let fromNat : Nat -> Word16  = Prim.natToWord16;

  /// Conversion. Return a value between `-2^15` and `2^15-1`
  public func toInt(x : Word16) : Int = Prim.int16ToInt(Prim.word16ToInt16(x));

  /// Conversion. Returns `x mod 2^16`.
  public let fromInt : (x : Int) -> Word16  = Prim.intToWord16;

  /// Returns the Text representation of `x`.
  public func toText(x : Word16) : Text {
    Nat.toText(toNat(x))
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Word16, y : Word16) : Word16 {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Word16, y : Word16) : Word16 {
    if (x < y) { y } else { x }
  };

  /// Returns `x == y`.
  public func equal(x : Word16, y : Word16) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Word16, y : Word16) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Word16, y : Word16) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Word16, y : Word16) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Word16, y : Word16) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Word16, y : Word16) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Word16, y : Word16) : { #less; #equal; #greater } {
    if (x < y) { #less }
    else if (x == y) { #equal }
    else { #greater }
  };

  /// Returns the sum of `x` and `y`, `(x + y) mod 2^16`.
  public func add(x : Word16, y : Word16) : Word16 { x +% y };

  /// Returns the difference of `x` and `y`, `(2^16 + x - y) mod 2^16`.
  public func sub(x : Word16, y : Word16) : Word16 { x -% y };

  /// Returns the product of `x` and `y`, `(x * y) mod 2^16`.
  public func mul(x : Word16, y : Word16) : Word16 { x *% y };

  /// Returns the division of `x` by `y`, `x / y`.
  /// Traps when `y` is zero.
  public func div(x : Word16, y : Word16) : Word16 { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  /// Traps when `y` is zero.
  public func rem(x : Word16, y : Word16) : Word16 { x % y };

  /// Returns `x` to the power of `y`, `(x ** y) mod 2^16`.
  public func pow(x : Word16, y : Word16) : Word16 { x **% y };

  /// Returns the bitwise negation of `x`, `^x`.
  public func bitnot(x : Word16, y : Word16) : Word16 { ^x };

  /// Returns the bitwise and of `x` and `y`, `x & y`.
  public func bitand(x : Word16, y : Word16) : Word16 { x & y };

  /// Returns the bitwise or of `x` and `y`, `x \| y`.
  public func bitor(x : Word16, y : Word16) : Word16 { x | y };

  /// Returns the bitwise exclusive or of `x` and `y`, `x ^ y`.
  public func bitxor(x : Word16, y : Word16) : Word16 { x ^ y };

  /// Returns the bitwise shift left of `x` by `y`, `x << y`.
  public func bitshiftLeft(x : Word16, y : Word16) : Word16 { x << y };

  /// Returns the bitwise shift right of `x` by `y`, `x >> y`.
  public func bitshiftRight(x : Word16, y : Word16) : Word16 { x >> y };

  /// Returns the signed shift right of `x` by `y`, `x +>> y`.
  public func bitshiftRightSigned(x : Word16, y : Word16) : Word16 { x +>> y };

  /// Returns the bitwise rotate left of `x` by `y`, `x <<> y`.
  public func bitrotLeft(x : Word16, y : Word16) : Word16 { x <<> y };

  /// Returns the bitwise rotate right of `x` by `y`, `x <>> y`.
  public func bitrotRight(x : Word16, y : Word16) : Word16 { x <>> y };

  /// Returns the value of bit `p mod 16` in `x`, `(x & 2^(p mod 16)) == 2^(p mod 16)`.
  public func bittest(x : Word16, p : Nat) : Bool {
    Prim.btstWord16(x, Prim.natToWord16(p));
  };

  /// Returns the value of setting bit `p mod 16` in `x` to `1`.
  public func bitset(x : Word16, p : Nat) : Word16 {
    x | (1 << Prim.natToWord16(p));
  };

  /// Returns the value of clearing bit `p mod 16` in `x` to `0`.
  public func bitclear(x : Word16, p : Nat) : Word16 {
    x & ^(1 << Prim.natToWord16(p));
  };

  /// Returns the value of flipping bit `p mod 16` in `x`.
  public func bitflip(x : Word16, p : Nat) : Word16 {
    x ^ (1 << Prim.natToWord16(p));
  };

  /// Returns the count of non-zero bits in `x`.
  public let bitcountNonZero : (x : Word16) -> Word16 = Prim.popcntWord16;

  /// Returns the count of leading zero bits in `x`.
  public let bitcountLeadingZero : (x : Word16) -> Word16 = Prim.clzWord16;

  /// Returns the count of trailing zero bits in `x`.
  public let bitcountTrailingZero : (x : Word16) -> Word16 = Prim.ctzWord16;

}
