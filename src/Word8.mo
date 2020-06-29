/// 8-bit binary unsigned integers with modular arithmetic
///
/// Most operations are available as built-in operators (e.g. `1 | 1`).

import Nat "Nat";
import Prim "mo:prim";

module {

  /// Conversion.
  public let toNat : Word8 -> Nat = Prim.word8ToNat;

  /// Conversion. Wraps around.
  public let fromNat : Nat -> Word8  = Prim.natToWord8;

  /// Conversion. Returns `x mod 2^8`.
  public let toInt: (x : Word8) -> Int = Prim.word8ToInt;

  /// Conversion. Returns `x mod 2^8`.
  public let fromInt : (x : Int) -> Word8  = Prim.intToWord8;

  /// Returns the Text representation of `x`.
  public func toText(x : Word8) : Text {
    Nat.toText(toNat(x))
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Word8, y : Word8) : Word8 {
    if (x < y) x else y
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Word8, y : Word8) : Word8 {
    if (x < y) y else x
  };

  /// Returns `x == y`.
  public func equal(x : Word8, y : Word8) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Word8, y : Word8) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Word8, y : Word8) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Word8, y : Word8) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Word8, y : Word8) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Word8, y : Word8) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Word8, y : Word8) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the sum of `x` and `y`, `(x + y) mod 2^8`.
  public func add(x : Word8, y : Word8) : Word8 { x + y };

  /// Returns the difference of `x` and `y`, `(2^8 + x - y) mod 2^8`.
  public func sub(x : Word8, y : Word8) : Word8 { x - y };

  /// Returns the product of `x` and `y`, `(x * y) mod 2^8`.
  public func mul(x : Word8, y : Word8) : Word8 { x * y };

  /// Returns the division of `x` by `y`, `x / y`.
  /// Traps when `y` is zero.
  public func div(x : Word8, y : Word8) : Word8 { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  /// Traps when `y` is zero.
  public func rem(x : Word8, y : Word8) : Word8 { x % y };

  /// Returns `x` to the power of `y`, `(x ** y) mod 2^8`.
  public func pow(x : Word8, y : Word8) : Word8 { x ** y };

  /// Returns the bitwise negation of `x`, `^x`.
  public func bitnot(x : Word8, y : Word8) : Word8 { ^x };

  /// Returns the bitwise and of `x` and `y`, `x & y`.
  public func bitand(x : Word8, y : Word8) : Word8 { x & y };

  /// Returns the bitwise or of `x` and `y`, `x \| y`.
  public func bitor(x : Word8, y : Word8) : Word8 { x | y };

  /// Returns the bitwise exclusive or of `x` and `y`, `x ^ y`.
  public func bitxor(x : Word8, y : Word8) : Word8 { x ^ y };

  /// Returns the bitwise shift left of `x` by `y`, `x << y`.
  public func bitshiftLeft(x : Word8, y : Word8) : Word8 { x << y };

  /// Returns the bitwise shift right of `x` by `y`, `x >> y`.
  public func bitshiftRight(x : Word8, y : Word8) : Word8 { x >> y };

  /// Returns the signed shift right of `x` by `y`, `x +>> y`.
  public func bitshiftRightSigned(x : Word8, y : Word8) : Word8 { x +>> y };

  /// Returns the bitwise rotate left of `x` by `y`, `x <<> y`.
  public func bitrotLeft(x : Word8, y : Word8) : Word8 { x <<> y };

  /// Returns the bitwise rotate right of `x` by `y`, `x <>> y`.
  public func bitrotRight(x : Word8, y : Word8) : Word8 { x <>> y };

  /// Returns the value of bit `p mod 8` in `x`, `(x & 2^(p mod 8)) == 2^(p mod 8)`.
  public func bittest(x : Word8, p : Nat) : Bool {
    Prim.btstWord8(x, Prim.natToWord8 p);
  };

  /// Returns the value of setting bit `p mod 8` in `x` to `1`.
  public func bitset(x : Word8, p : Nat) : Word8 {
    x | (1 << Prim.natToWord8 p);
  };

  /// Returns the value of clearing bit `p mod 8` in `x` to `0`.
  public func bitclear(x : Word8, p : Nat) : Word8 {
    x & ^(1 << Prim.natToWord8 p);
  };

  /// Returns the value of flipping bit `p mod 8` in `x`.
  public func bitflip(x : Word8, p : Nat) : Word8 {
    x ^ (1 << Prim.natToWord8 p);
  };

  /// Returns the count of non-zero bits in `x`.
  public let bitcountNonZero : (x : Word8) -> Word8 = Prim.popcntWord8;

  /// Returns the count of leading zero bits in `x`.
  public let bitcountLeadingZero : (x : Word8) -> Word8 = Prim.clzWord8;

  /// Returns the count of trailing zero bits in `x`.
  public let bitcountTrailingZero : (x : Word8) -> Word8 = Prim.ctzWord8;

}
