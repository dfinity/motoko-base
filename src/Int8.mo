/// 8-bit signed integers with checked arithmetic.
///
/// Common 8-bit integer functions.
/// Most operations are available as built-in operators (e.g. `1 + 1`).
import Int "Int";
import Prim "mo:⛔";

module {

  /// 8-bit signed integers.
  public type Int8 = Prim.Types.Int8;

  /// Minimum 8-bit integer value, `-2 ** 7`.
  public let minimumValue = -128 : Int8;

  /// Maximum 8-bit integer value, `+2 ** 7 - 1`.
  public let maximumValue = 127 : Int8;

  /// Converts a 8-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.toInt(123) // => 123 : Int
  /// ```
  public let toInt : Int8 -> Int = Prim.int8ToInt;

  /// Converts a signed integer with infinite precision to a 8-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.fromInt(123) // => +123 : Int8
  /// ```
  public let fromInt : Int -> Int8 = Prim.intToInt8;

  /// Converts a signed integer with infinite precision to a 8-bit signed integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.fromIntWrap(-123) // => -123 : Int
  /// ```
  public let fromIntWrap : Int -> Int8 = Prim.intToInt8Wrap;

  /// Converts an unsigned 8-bit integer to a signed 8-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.fromNat8(123) // => +123 : Int8
  /// ```
  public let fromNat8 : Nat8 -> Int8 = Prim.nat8ToInt8;

  /// Converts a signed 8-bit integer to an unsigned 8-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.toNat8(-1) // => 255 : Nat8 // underflow
  /// ```
  public let toNat8 : Int8 -> Nat8 = Prim.int8ToNat8;

  /// Returns the Text representation of `x`.
  /// Formats the integer in decimal representation.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.toText(-123) // => "-123"
  /// ```
  public func toText(x : Int8) : Text {
    Int.toText(toInt(x))
  };

  /// Returns the absolute value of `x`.
  ///
  /// Traps when `x == -2 ** 7` (the minimum `Int8` value).
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.abs(-123) // => +123
  /// ```
  public func abs(x : Int8) : Int8 {
    fromInt(Int.abs(toInt(x)))
  };

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.min(+2, -3) // => -3
  /// ```
  public func min(x : Int8, y : Int8) : Int8 {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.max(+2, -3) // => +2
  /// ```
  public func max(x : Int8, y : Int8) : Int8 {
    if (x < y) { y } else { x }
  };

  /// Returns `x == y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.equal(123, 123) // => true
  /// ```
  public func equal(x : Int8, y : Int8) : Bool { x == y };

  /// Returns `x != y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.notEqual(123, 123) // => false
  /// ```
  public func notEqual(x : Int8, y : Int8) : Bool { x != y };

  /// Returns `x < y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.less(123, 124) // => true
  /// ```
  public func less(x : Int8, y : Int8) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.lessOrEqual(123, 124) // => true
  /// ```
  public func lessOrEqual(x : Int8, y : Int8) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.greater(124, 123) // => true
  /// ```
  public func greater(x : Int8, y : Int8) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.greaterOrEqual(124, 123) // => true
  /// ```
  public func greaterOrEqual(x : Int8, y : Int8) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.compare(123, 124) // => #less
  /// ```
  public func compare(x : Int8, y : Int8) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the negation of `x`, `-x`.
  ///
  /// Traps on overflow, i.e. for `neg(-2 ** 7)`.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.neg(123) // => -123
  /// ```
  public func neg(x : Int8) : Int8 { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.add(100, 23) // => +123
  /// ```
  public func add(x : Int8, y : Int8) : Int8 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.sub(123, 23) // => +100
  /// ```
  public func sub(x : Int8, y : Int8) : Int8 { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.mul(12, 10) // => +120
  /// ```
  public func mul(x : Int8, y : Int8) : Int8 { x * y };

  /// Returns the signed integer division of `x` by `y`, `x / y`.
  /// Rounds the quotient towards zero, which is the same as truncating the decimal places of the quotient.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.div(123, 10) // => +12
  /// ```
  public func div(x : Int8, y : Int8) : Int8 { x / y };

  /// Returns the remainder of the signed integer division of `x` by `y`, `x % y`,
  /// which is defined as `x - x / y * y`.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.rem(123, 10) // => +3
  /// ```
  public func rem(x : Int8, y : Int8) : Int8 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Traps on overflow/underflow and when `y < 0 or y >= 8`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.pow(2, 6) // => +64
  /// ```
  public func pow(x : Int8, y : Int8) : Int8 { x ** y };

  /// Returns the bitwise negation of `x`, `^x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitnot(-16 /* 0xf0 */) // => +15 // 0x0f
  /// ```
  public func bitnot(x : Int8) : Int8 { ^x };

  /// Returns the bitwise "and" of `x` and `y`, `x & y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitand(0x1f, 0x70) // => +16 // 0x10
  /// ```
  public func bitand(x : Int8, y : Int8) : Int8 { x & y };

  /// Returns the bitwise "or" of `x` and `y`, `x | y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitor(0x0f, 0x70) // => +127 // 0x7f
  /// ```
  public func bitor(x : Int8, y : Int8) : Int8 { x | y };

  /// Returns the bitwise "exclusive or" of `x` and `y`, `x ^ y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitxor(0x70, 0x7f) // => +15 // 0x0f
  /// ```
  public func bitxor(x : Int8, y : Int8) : Int8 { x ^ y };

  /// Returns the bitwise left shift of `x` by `y`, `x << y`.
  /// The right bits of the shift filled with zeros.
  /// Left-overflowing bits, including the sign bit, are discarded.
  ///
  /// For `y >= 8`, the semantics is the same as for `bitshiftLeft(x, y % 8)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftLeft(x, y + y % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitshiftLeft(1, 4) // => +16 // 0x10 equivalent to `2 ** 4`.
  /// ```
  public func bitshiftLeft(x : Int8, y : Int8) : Int8 { x << y };

  /// Returns the signed bitwise right shift of `x` by `y`, `x >> y`.
  /// The sign bit is retained and the left side is filled with the sign bit.
  /// Right-underflowing bits are discarded, i.e. not rotated to the left side.
  ///
  /// For `y >= 8`, the semantics is the same as for `bitshiftRight(x, y % 8)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftRight (x, y + y % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitshiftRight(64, 4) // => +4 // equivalent to `64 / (2 ** 4)`
  /// ```
  public func bitshiftRight(x : Int8, y : Int8) : Int8 { x >> y };

  /// Returns the bitwise left rotatation of `x` by `y`, `x <<> y`.
  /// Each left-overflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 8`, the semantics is the same as for `bitrotLeft(x, y % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitrotLeft(0x11 /* 0b0001_0001 */, 2) // => +68 // 0b0100_0100 == 0x44.
  /// ```
  public func bitrotLeft(x : Int8, y : Int8) : Int8 { x <<> y };

  /// Returns the bitwise right rotation of `x` by `y`, `x <>> y`.
  /// Each right-underflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 8`, the semantics is the same as for `bitrotRight(x, y % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitrotRight(0x11 /* 0b0001_0001 */, 1) // => -120 // 0b1000_1000 == 0x88.
  /// ```
  public func bitrotRight(x : Int8, y : Int8) : Int8 { x <>> y };

  /// Returns the value of bit `p` in `x`, `x & 2**p == 2**p`.
  /// If `p >= 8`, the semantics is the same as for `bittest(x, p % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bittest(64, 6) // => true
  /// ```
  public func bittest(x : Int8, p : Nat) : Bool {
    Prim.btstInt8(x, Prim.intToInt8(p))
  };

  /// Returns the value of setting bit `p` in `x` to `1`.
  /// If `p >= 8`, the semantics is the same as for `bitset(x, p % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitset(0, 6) // => +64
  /// ```
  public func bitset(x : Int8, p : Nat) : Int8 {
    x | (1 << Prim.intToInt8(p))
  };

  /// Returns the value of clearing bit `p` in `x` to `0`.
  /// If `p >= 8`, the semantics is the same as for `bitclear(x, p % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitclear(-1, 6) // => -65
  /// ```
  public func bitclear(x : Int8, p : Nat) : Int8 {
    x & ^(1 << Prim.intToInt8(p))
  };

  /// Returns the value of flipping bit `p` in `x`.
  /// If `p >= 8`, the semantics is the same as for `bitclear(x, p % 8)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitflip(127, 6) // => +63
  /// ```
  public func bitflip(x : Int8, p : Nat) : Int8 {
    x ^ (1 << Prim.intToInt8(p))
  };

  /// Returns the count of non-zero bits in `x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitcountNonZero(0x0f) // => +4
  /// ```
  public let bitcountNonZero : (x : Int8) -> Int8 = Prim.popcntInt8;

  /// Returns the count of leading zero bits in `x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitcountLeadingZero(0x08) // => +4
  /// ```
  public let bitcountLeadingZero : (x : Int8) -> Int8 = Prim.clzInt8;

  /// Returns the count of trailing zero bits in `x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.bitcountTrailingZero(0x10) // => +4
  /// ```
  public let bitcountTrailingZero : (x : Int8) -> Int8 = Prim.ctzInt8;

  /// Returns the sum of `x` and `y`, `x +% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.addWrap(2 ** 6, 2 ** 6) // => -128 // overflow
  /// ```
  public func addWrap(x : Int8, y : Int8) : Int8 { x +% y };

  /// Returns the difference of `x` and `y`, `x -% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.subWrap(-2 ** 7, 1) // => +127 // underflow
  /// ```
  public func subWrap(x : Int8, y : Int8) : Int8 { x -% y };

  /// Returns the product of `x` and `y`, `x *% y`. Wraps on overflow.
  ///
  /// Wraps on overflow/underflow.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.mulWrap(2 ** 4, 2 ** 4) // => 0 // overflow
  /// ```
  public func mulWrap(x : Int8, y : Int8) : Int8 { x *% y };

  /// Returns `x` to the power of `y`, `x **% y`.
  ///
  /// Wraps on overflow/underflow.
  /// Traps if `y < 0 or y >= 8`.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int8 "mo:base/Int8";
  ///
  /// Int8.powWrap(2, 7) // => -128 // overflow
  /// ```
  public func powWrap(x : Int8, y : Int8) : Int8 { x **% y };

}
