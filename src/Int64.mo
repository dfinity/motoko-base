/// 64-bit signed integers with checked arithmetic
///
/// Common 64-bit integer functions.
/// Most operations are available as built-in operators (e.g. `1 + 1`).
import Int "Int";
import Prim "mo:⛔";

module {

  /// 64-bit signed integers.
  public type Int64 = Prim.Types.Int64;

  /// Converts a 64-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.toInt(123_456) // => 123_456 : Int
  /// ```
  public let toInt : Int64 -> Int = Prim.int64ToInt;

  /// Converts a signed integer with infinite precision to a 64-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.fromInt(123_456) // => +123_456 : Int64
  /// ```
  public let fromInt : Int -> Int64 = Prim.intToInt64;

  /// Converts a signed integer with infinite precision to a 64-bit signed integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.fromIntWrap(-123_456) // => -123_456 : Int
  /// ```
  public let fromIntWrap : Int -> Int64 = Prim.intToInt64Wrap;

  /// Converts an unsigned 64-bit integer to a signed 64-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.fromNat64(123_456) // => +123_456 : Int
  /// ```
  public let fromNat64 : Nat64 -> Int64 = Prim.nat64ToInt64;

  /// Converts a signed 64-bit integer to an unsigned 64-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.toNat64(-1) // => 18_446_744_073_709_551_615 : Nat64 // underflow
  /// ```
  public let toNat64 : Int64 -> Nat64 = Prim.int64ToNat64;

  /// Returns the Text representation of `x`.
  /// Formats the integer in decimal representation without underscore separators for thousand figures.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.toText(-123456) // => "-123456"
  /// ```
  public func toText(x : Int64) : Text {
    Int.toText(toInt(x))
  };

  /// Returns the absolute value of `x`.
  ///
  /// Traps when `x == -2 ** 63` (the minimum `Int64` value).
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.abs(123456) // => +123_456
  /// ```
  public func abs(x : Int64) : Int64 {
    fromInt(Int.abs(toInt(x)))
  };

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.min(+2, -3) // => -3
  /// ```
  public func min(x : Int64, y : Int64) : Int64 {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.max(+2, -3) // => 2
  /// ```
  public func max(x : Int64, y : Int64) : Int64 {
    if (x < y) { y } else { x }
  };

  /// Returns `x == y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.equal(123, 123) // => true
  /// ```
  public func equal(x : Int64, y : Int64) : Bool { x == y };

  /// Returns `x != y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.notEqual(123, 123) // => false
  /// ```
  public func notEqual(x : Int64, y : Int64) : Bool { x != y };

  /// Returns `x < y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.less(123, 1234) // => true
  /// ```
  public func less(x : Int64, y : Int64) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.lessOrEqual(123, 1234) // => true
  /// ```
  public func lessOrEqual(x : Int64, y : Int64) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.greater(1234, 123) // => true
  /// ```
  public func greater(x : Int64, y : Int64) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.greaterOrEqual(1234, 123) // => true
  /// ```
  public func greaterOrEqual(x : Int64, y : Int64) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.compare(123, 1234) // => #less
  /// ```
  public func compare(x : Int64, y : Int64) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the negation of `x`, `-x`.
  ///
  /// Traps on overflow, i.e. for `neg(-2 ** 63)`.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.neg(123) // => -123
  /// ```
  public func neg(x : Int64) : Int64 { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.add(1234, 123) // => +1_357
  /// ```
  public func add(x : Int64, y : Int64) : Int64 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.sub(1234, 123) // => +1_111
  /// ```
  public func sub(x : Int64, y : Int64) : Int64 { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.mul(123, 100) // => +12_300
  /// ```
  public func mul(x : Int64, y : Int64) : Int64 { x * y };

  /// Returns the signed integer division of `x by y`, `x / y`.
  /// Rounds the quotient towards zero, which is the same as truncating the decimal places of the quotient.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.div(123, 10) // => +12
  /// ```
  public func div(x : Int64, y : Int64) : Int64 { x / y };

  /// Returns the remainder of the signed integer division of `x` by `y`, `x % y`,
  /// which is defined as `x - x / y * y`.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.rem(123, 10) // => +3
  /// ```
  public func rem(x : Int64, y : Int64) : Int64 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Traps on overflow/underflow and when `y` is negative.
  ///
  /// Example:
  /// ```motoko
  /// import Int64 "mo:base/Int64";
  ///
  /// Int64.pow(2, 10) // => +1_024
  /// ```
  public func pow(x : Int64, y : Int64) : Int64 { x ** y };

  /// Returns the bitwise negation of `x`, `^x`.
  public func bitnot(x : Int64, y : Int64) : Int64 { ^x };

  /// Returns the bitwise and of `x` and `y`, `x & y`.
  public func bitand(x : Int64, y : Int64) : Int64 { x & y };

  /// Returns the bitwise or of `x` and `y`, `x \| y`.
  public func bitor(x : Int64, y : Int64) : Int64 { x | y };

  /// Returns the bitwise exclusive or of `x` and `y`, `x ^ y`.
  public func bitxor(x : Int64, y : Int64) : Int64 { x ^ y };

  /// Returns the bitwise shift left of `x` by `y`, `x << y`.
  public func bitshiftLeft(x : Int64, y : Int64) : Int64 { x << y };

  /// Returns the bitwise shift right of `x` by `y`, `x >> y`.
  public func bitshiftRight(x : Int64, y : Int64) : Int64 { x >> y };

  /// Returns the bitwise rotate left of `x` by `y`, `x <<> y`.
  public func bitrotLeft(x : Int64, y : Int64) : Int64 { x <<> y };

  /// Returns the bitwise rotate right of `x` by `y`, `x <>> y`.
  public func bitrotRight(x : Int64, y : Int64) : Int64 { x <>> y };

  /// Returns the value of bit `p mod 64` in `x`, `(x & 2^(p mod 64)) == 2^(p mod 64)`.
  public func bittest(x : Int64, p : Nat) : Bool {
    Prim.btstInt64(x, Prim.intToInt64(p))
  };

  /// Returns the value of setting bit `p mod 64` in `x` to `1`.
  public func bitset(x : Int64, p : Nat) : Int64 {
    x | (1 << Prim.intToInt64(p))
  };

  /// Returns the value of clearing bit `p mod 64` in `x` to `0`.
  public func bitclear(x : Int64, p : Nat) : Int64 {
    x & ^(1 << Prim.intToInt64(p))
  };

  /// Returns the value of flipping bit `p mod 64` in `x`.
  public func bitflip(x : Int64, p : Nat) : Int64 {
    x ^ (1 << Prim.intToInt64(p))
  };

  /// Returns the count of non-zero bits in `x`.
  public let bitcountNonZero : (x : Int64) -> Int64 = Prim.popcntInt64;

  /// Returns the count of leading zero bits in `x`.
  public let bitcountLeadingZero : (x : Int64) -> Int64 = Prim.clzInt64;

  /// Returns the count of trailing zero bits in `x`.
  public let bitcountTrailingZero : (x : Int64) -> Int64 = Prim.ctzInt64;

  /// Returns the sum of `x` and `y`, `x +% y`. Wraps on overflow.
  public func addWrap(x : Int64, y : Int64) : Int64 { x +% y };

  /// Returns the difference of `x` and `y`, `x -% y`. Wraps on underflow.
  public func subWrap(x : Int64, y : Int64) : Int64 { x -% y };

  /// Returns the product of `x` and `y`, `x *% y`. Wraps on overflow.
  public func mulWrap(x : Int64, y : Int64) : Int64 { x *% y };

  /// Returns `x` to the power of `y`, `x **% y`. Wraps on overflow. Traps if `y < 0`.
  public func powWrap(x : Int64, y : Int64) : Int64 { x **% y };

}
