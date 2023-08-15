/// Provides utility functions on 16-bit signed integers.
///
/// Note that most operations are available as built-in operators (e.g. `1 + 1`).
///
/// Import from the base library to use this module.
/// ```motoko name=import
/// import Int16 "mo:base/Int16";
/// ```
import Int "Int";
import Prim "mo:⛔";

module {

  /// 16-bit signed integers.
  public type Int16 = Prim.Types.Int16;

  /// Minimum 16-bit integer value, `-2 ** 15`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.minimumValue // => -32_768 : Int16
  /// ```
  public let minimumValue = -32_768 : Int16;

  /// Maximum 16-bit integer value, `+2 ** 15 - 1`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.maximumValue // => +32_767 : Int16
  /// ```
  public let maximumValue = 32_767 : Int16;

  /// Converts a 16-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.toInt(12_345) // => 12_345 : Int
  /// ```
  public let toInt : Int16 -> Int = Prim.int16ToInt;

  /// Converts a signed integer with infinite precision to a 16-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.fromInt(12_345) // => +12_345 : Int16
  /// ```
  public let fromInt : Int -> Int16 = Prim.intToInt16;

  /// Converts a signed integer with infinite precision to a 16-bit signed integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.fromIntWrap(-12_345) // => -12_345 : Int
  /// ```
  public let fromIntWrap : Int -> Int16 = Prim.intToInt16Wrap;

  /// Converts a 8-bit signed integer to a 16-bit signed integer.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.fromInt8(-123) // => -123 : Int16
  /// ```
  public let fromInt8 : Int8 -> Int16 = Prim.int8ToInt16;

  /// Converts a 16-bit signed integer to a 8-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.toInt8(-123) // => -123 : Int8
  /// ```
  public let toInt8 : Int16 -> Int8 = Prim.int16ToInt8;

  /// Converts a 32-bit signed integer to a 16-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.fromInt32(-12_345) // => -12_345 : Int16
  /// ```
  public let fromInt32 : Int32 -> Int16 = Prim.int32ToInt16;

  /// Converts a 16-bit signed integer to a 32-bit signed integer.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.toInt32(-12_345) // => -12_345 : Int32
  /// ```
  public let toInt32 : Int16 -> Int32 = Prim.int16ToInt32;

  /// Converts an unsigned 16-bit integer to a signed 16-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.fromNat16(12_345) // => +12_345 : Int16
  /// ```
  public let fromNat16 : Nat16 -> Int16 = Prim.nat16ToInt16;

  /// Converts a signed 16-bit integer to an unsigned 16-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.toNat16(-1) // => 65_535 : Nat16 // underflow
  /// ```
  public let toNat16 : Int16 -> Nat16 = Prim.int16ToNat16;

  /// Returns the Text representation of `x`.
  /// Formats the integer in decimal representation without underscore separators for thousand figures.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.toText(-12345) // => "-12345"
  /// ```
  public func toText(x : Int16) : Text {
    Int.toText(toInt(x))
  };

  /// Returns the absolute value of `x`.
  ///
  /// Traps when `x == -2 ** 15` (the minimum `Int16` value).
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.abs(-12345) // => +12_345
  /// ```
  public func abs(x : Int16) : Int16 {
    fromInt(Int.abs(toInt(x)))
  };

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.min(+2, -3) // => -3
  /// ```
  public func min(x : Int16, y : Int16) : Int16 {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.max(+2, -3) // => +2
  /// ```
  public func max(x : Int16, y : Int16) : Int16 {
    if (x < y) { y } else { x }
  };

  /// Returns `x == y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.equal(123, 123) // => true
  /// ```
  public func equal(x : Int16, y : Int16) : Bool { x == y };

  /// Returns `x != y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.notEqual(123, 123) // => false
  /// ```
  public func notEqual(x : Int16, y : Int16) : Bool { x != y };

  /// Returns `x < y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.less(123, 1234) // => true
  /// ```
  public func less(x : Int16, y : Int16) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.lessOrEqual(123, 1234) // => true
  /// ```
  public func lessOrEqual(x : Int16, y : Int16) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.greater(1234, 123) // => true
  /// ```
  public func greater(x : Int16, y : Int16) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.greaterOrEqual(1234, 123) // => true
  /// ```
  public func greaterOrEqual(x : Int16, y : Int16) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.compare(123, 1234) // => #less
  /// ```
  public func compare(x : Int16, y : Int16) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the negation of `x`, `-x`.
  ///
  /// Traps on overflow, i.e. for `neg(-2 ** 15)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.neg(123) // => -123
  /// ```
  public func neg(x : Int16) : Int16 { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.add(1234, 123) // => +1_357
  /// ```
  public func add(x : Int16, y : Int16) : Int16 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.sub(1234, 123) // => +1_111
  /// ```
  public func sub(x : Int16, y : Int16) : Int16 { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.mul(123, 100) // => +12_300
  /// ```
  public func mul(x : Int16, y : Int16) : Int16 { x * y };

  /// Returns the signed integer division of `x` by `y`, `x / y`.
  /// Rounds the quotient towards zero, which is the same as truncating the decimal places of the quotient.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.div(123, 10) // => +12
  /// ```
  public func div(x : Int16, y : Int16) : Int16 { x / y };

  /// Returns the remainder of the signed integer division of `x` by `y`, `x % y`,
  /// which is defined as `x - x / y * y`.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.rem(123, 10) // => +3
  /// ```
  public func rem(x : Int16, y : Int16) : Int16 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Traps on overflow/underflow and when `y < 0 or y >= 16`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.pow(2, 10) // => +1_024
  /// ```
  public func pow(x : Int16, y : Int16) : Int16 { x ** y };

  /// Returns the bitwise negation of `x`, `^x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitnot(-256 /* 0xff00 */) // => +255 // 0xff
  /// ```
  public func bitnot(x : Int16) : Int16 { ^x };

  /// Returns the bitwise "and" of `x` and `y`, `x & y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitand(0x0fff, 0x00f0) // => +240 // 0xf0
  /// ```
  public func bitand(x : Int16, y : Int16) : Int16 { x & y };

  /// Returns the bitwise "or" of `x` and `y`, `x | y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitor(0x0f0f, 0x00f0) // => +4_095 // 0x0fff
  /// ```
  public func bitor(x : Int16, y : Int16) : Int16 { x | y };

  /// Returns the bitwise "exclusive or" of `x` and `y`, `x ^ y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitxor(0x0fff, 0x00f0) // => +3_855 // 0x0f0f
  /// ```
  public func bitxor(x : Int16, y : Int16) : Int16 { x ^ y };

  /// Returns the bitwise left shift of `x` by `y`, `x << y`.
  /// The right bits of the shift filled with zeros.
  /// Left-overflowing bits, including the sign bit, are discarded.
  ///
  /// For `y >= 16`, the semantics is the same as for `bitshiftLeft(x, y % 16)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftLeft(x, y + y % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitshiftLeft(1, 8) // => +256 // 0x100 equivalent to `2 ** 8`.
  /// ```
  public func bitshiftLeft(x : Int16, y : Int16) : Int16 { x << y };

  /// Returns the signed bitwise right shift of `x` by `y`, `x >> y`.
  /// The sign bit is retained and the left side is filled with the sign bit.
  /// Right-underflowing bits are discarded, i.e. not rotated to the left side.
  ///
  /// For `y >= 16`, the semantics is the same as for `bitshiftRight(x, y % 16)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftRight (x, y + y % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitshiftRight(1024, 8) // => +4 // equivalent to `1024 / (2 ** 8)`
  /// ```
  public func bitshiftRight(x : Int16, y : Int16) : Int16 { x >> y };

  /// Returns the bitwise left rotatation of `x` by `y`, `x <<> y`.
  /// Each left-overflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 16`, the semantics is the same as for `bitrotLeft(x, y % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitrotLeft(0x2001, 4) // => +18 // 0x12.
  /// ```
  public func bitrotLeft(x : Int16, y : Int16) : Int16 { x <<> y };

  /// Returns the bitwise right rotation of `x` by `y`, `x <>> y`.
  /// Each right-underflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 16`, the semantics is the same as for `bitrotRight(x, y % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitrotRight(0x2010, 8) // => +4_128 // 0x01020.
  /// ```
  public func bitrotRight(x : Int16, y : Int16) : Int16 { x <>> y };

  /// Returns the value of bit `p` in `x`, `x & 2**p == 2**p`.
  /// If `p >= 16`, the semantics is the same as for `bittest(x, p % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bittest(128, 7) // => true
  /// ```
  public func bittest(x : Int16, p : Nat) : Bool {
    Prim.btstInt16(x, Prim.intToInt16(p))
  };

  /// Returns the value of setting bit `p` in `x` to `1`.
  /// If `p >= 16`, the semantics is the same as for `bitset(x, p % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitset(0, 7) // => +128
  /// ```
  public func bitset(x : Int16, p : Nat) : Int16 {
    x | (1 << Prim.intToInt16(p))
  };

  /// Returns the value of clearing bit `p` in `x` to `0`.
  /// If `p >= 16`, the semantics is the same as for `bitclear(x, p % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitclear(-1, 7) // => -129
  /// ```
  public func bitclear(x : Int16, p : Nat) : Int16 {
    x & ^(1 << Prim.intToInt16(p))
  };

  /// Returns the value of flipping bit `p` in `x`.
  /// If `p >= 16`, the semantics is the same as for `bitclear(x, p % 16)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitflip(255, 7) // => +127
  /// ```
  public func bitflip(x : Int16, p : Nat) : Int16 {
    x ^ (1 << Prim.intToInt16(p))
  };

  /// Returns the count of non-zero bits in `x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitcountNonZero(0xff) // => +8
  /// ```
  public let bitcountNonZero : (x : Int16) -> Int16 = Prim.popcntInt16;

  /// Returns the count of leading zero bits in `x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitcountLeadingZero(0x80) // => +8
  /// ```
  public let bitcountLeadingZero : (x : Int16) -> Int16 = Prim.clzInt16;

  /// Returns the count of trailing zero bits in `x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.bitcountTrailingZero(0x0100) // => +8
  /// ```
  public let bitcountTrailingZero : (x : Int16) -> Int16 = Prim.ctzInt16;

  /// Returns the sum of `x` and `y`, `x +% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.addWrap(2 ** 14, 2 ** 14) // => -32_768 // overflow
  /// ```
  public func addWrap(x : Int16, y : Int16) : Int16 { x +% y };

  /// Returns the difference of `x` and `y`, `x -% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.subWrap(-2 ** 15, 1) // => +32_767 // underflow
  /// ```
  public func subWrap(x : Int16, y : Int16) : Int16 { x -% y };

  /// Returns the product of `x` and `y`, `x *% y`. Wraps on overflow.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int16.mulWrap(2 ** 8, 2 ** 8) // => 0 // overflow
  /// ```
  public func mulWrap(x : Int16, y : Int16) : Int16 { x *% y };

  /// Returns `x` to the power of `y`, `x **% y`.
  ///
  /// Wraps on overflow/underflow.
  /// Traps if `y < 0 or y >= 16`.
  ///
  /// Example:
  /// ```motoko include=import
  ///
  /// Int16.powWrap(2, 15) // => -32_768 // overflow
  /// ```
  public func powWrap(x : Int16, y : Int16) : Int16 { x **% y }
}
