/// Provides utility functions on 8-bit signed integers.
///
/// :::info Function form for higher-order use
///
/// Several arithmetic and comparison functions (e.g. `add`, `sub`, `bitor`, `bitand`, `pow`) are defined in this module to enable their use as first-class function values, which is not possible with operators like `+`, `-`, `==`, etc., in Motoko. This allows you to pass these operations to higher-order functions such as `map`, `foldLeft`, or `sort`.
/// :::
///
/// :::note
/// Most operations are available as built-in operators (e.g. `1 + 1`).
/// :::
/// Import from the base library to use this module.
///
/// ```motoko name=import
/// import Int8 "mo:base/Int8";
/// ```
import Int "Int";
import Prim "mo:⛔";

module {

  /// 8-bit signed integers.
  public type Int8 = Prim.Types.Int8;

  /// Minimum 8-bit integer value, `-2 ** 7`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.minimumValue // => -128
  /// ```
  public let minimumValue = -128 : Int8;

  /// Maximum 8-bit integer value, `+2 ** 7 - 1`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.maximumValue // => +127
  /// ```
  public let maximumValue = 127 : Int8;

  /// Converts an 8-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.toInt(123) // => 123 : Int
  /// ```
  public let toInt : Int8 -> Int = Prim.int8ToInt;

  /// Converts a signed integer with infinite precision to an 8-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.fromInt(123) // => +123 : Int8
  /// ```
  public let fromInt : Int -> Int8 = Prim.intToInt8;

  /// Converts a signed integer with infinite precision to an 8-bit signed integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.fromIntWrap(-123) // => -123 : Int
  /// ```
  public let fromIntWrap : Int -> Int8 = Prim.intToInt8Wrap;

  /// Converts a 16-bit signed integer to an 8-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.fromInt16(123) // => +123 : Int8
  /// ```
  public let fromInt16 : Int16 -> Int8 = Prim.int16ToInt8;

  /// Converts an 8-bit signed integer to a 16-bit signed integer.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.toInt16(123) // => +123 : Int16
  /// ```
  public let toInt16 : Int8 -> Int16 = Prim.int8ToInt16;

  /// Converts an unsigned 8-bit integer to a signed 8-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.fromNat8(123) // => +123 : Int8
  /// ```
  public let fromNat8 : Nat8 -> Int8 = Prim.nat8ToInt8;

  /// Converts a signed 8-bit integer to an unsigned 8-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.toNat8(-1) // => 255 : Nat8 // underflow
  /// ```
  public let toNat8 : Int8 -> Nat8 = Prim.int8ToNat8;

  /// Converts an integer number to its textual representation.
  ///
  /// Example:
  /// ```motoko include=import
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
  /// ```motoko include=import
  /// Int8.abs(-123) // => +123
  /// ```
  public func abs(x : Int8) : Int8 {
    fromInt(Int.abs(toInt(x)))
  };

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.min(+2, -3) // => -3
  /// ```
  public func min(x : Int8, y : Int8) : Int8 {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.max(+2, -3) // => +2
  /// ```
  public func max(x : Int8, y : Int8) : Int8 {
    if (x < y) { y } else { x }
  };

  /// Equality function for Int8 types.
  /// This is equivalent to `x == y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.equal(-1, -1); // => true
  /// ```
  ///

  ///
  /// Example:
  /// ```motoko include=import
  /// import Buffer "mo:base/Buffer";
  ///
  /// let buffer1 = Buffer.Buffer<Int8>(1);
  /// buffer1.add(-3);
  /// let buffer2 = Buffer.Buffer<Int8>(1);
  /// buffer2.add(-3);
  /// Buffer.equal(buffer1, buffer2, Int8.equal) // => true
  /// ```
  public func equal(x : Int8, y : Int8) : Bool { x == y };

  /// Inequality function for Int8 types.
  /// This is equivalent to `x != y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.notEqual(-1, -2); // => true
  /// ```
  ///

  public func notEqual(x : Int8, y : Int8) : Bool { x != y };

  /// "Less than" function for Int8 types.
  /// This is equivalent to `x < y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.less(-2, 1); // => true
  /// ```
  ///

  public func less(x : Int8, y : Int8) : Bool { x < y };

  /// "Less than or equal" function for Int8 types.
  /// This is equivalent to `x <= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.lessOrEqual(-2, -2); // => true
  /// ```
  ///

  public func lessOrEqual(x : Int8, y : Int8) : Bool { x <= y };

  /// "Greater than" function for Int8 types.
  /// This is equivalent to `x > y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.greater(-2, -3); // => true
  /// ```
  ///

  public func greater(x : Int8, y : Int8) : Bool { x > y };

  /// "Greater than or equal" function for Int8 types.
  /// This is equivalent to `x >= y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.greaterOrEqual(-2, -2); // => true
  /// ```
  ///

  public func greaterOrEqual(x : Int8, y : Int8) : Bool { x >= y };

  /// General-purpose comparison function for `Int8`. Returns the `Order` (
  /// either `#less`, `#equal`, or `#greater`) of comparing `x` with `y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.compare(-3, 2) // => #less
  /// ```
  ///
  /// This function can be used as value for a high order function, such as a sort function.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:base/Array";
  /// Array.sort([1, -2, -3] : [Int8], Int8.compare) // => [-3, -2, 1]
  /// ```
  public func compare(x : Int8, y : Int8) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the negation of `x`, `-x`.
  ///
  /// Traps on overflow, i.e. for `neg(-2 ** 7)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.neg(123) // => -123
  /// ```
  ///

  public func neg(x : Int8) : Int8 { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.add(100, 23) // => +123
  /// ```
  ///

  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:base/Array";
  /// Array.foldLeft<Int8, Int8>([1, -2, -3], 0, Int8.add) // => -4
  /// ```
  public func add(x : Int8, y : Int8) : Int8 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.sub(123, 23) // => +100
  /// ```
  ///

  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:base/Array";
  /// Array.foldLeft<Int8, Int8>([1, -2, -3], 0, Int8.sub) // => 4
  /// ```
  public func sub(x : Int8, y : Int8) : Int8 { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.mul(12, 10) // => +120
  /// ```
  ///

  ///
  /// Example:
  /// ```motoko include=import
  /// import Array "mo:base/Array";
  /// Array.foldLeft<Int8, Int8>([1, -2, -3], 1, Int8.mul) // => 6
  /// ```
  public func mul(x : Int8, y : Int8) : Int8 { x * y };

  /// Returns the signed integer division of `x` by `y`, `x / y`.
  /// Rounds the quotient towards zero, which is the same as truncating the decimal places of the quotient.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.div(123, 10) // => +12
  /// ```
  ///

  public func div(x : Int8, y : Int8) : Int8 { x / y };

  /// Returns the remainder of the signed integer division of `x` by `y`, `x % y`,
  /// which is defined as `x - x / y * y`.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.rem(123, 10) // => +3
  /// ```
  ///

  public func rem(x : Int8, y : Int8) : Int8 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Traps on overflow/underflow and when `y < 0 or y >= 8`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.pow(2, 6) // => +64
  /// ```
  ///

  public func pow(x : Int8, y : Int8) : Int8 { x ** y };

  /// Returns the bitwise negation of `x`, `^x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitnot(-16 /* 0xf0 */) // => +15 // 0x0f
  /// ```
  ///

  public func bitnot(x : Int8) : Int8 { ^x };

  /// Returns the bitwise "and" of `x` and `y`, `x & y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitand(0x1f, 0x70) // => +16 // 0x10
  /// ```
  ///

  public func bitand(x : Int8, y : Int8) : Int8 { x & y };

  /// Returns the bitwise "or" of `x` and `y`, `x | y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitor(0x0f, 0x70) // => +127 // 0x7f
  /// ```
  ///

  public func bitor(x : Int8, y : Int8) : Int8 { x | y };

  /// Returns the bitwise "exclusive or" of `x` and `y`, `x ^ y`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitxor(0x70, 0x7f) // => +15 // 0x0f
  /// ```
  ///

  public func bitxor(x : Int8, y : Int8) : Int8 { x ^ y };

  /// Returns the bitwise left shift of `x` by `y`, `x << y`.
  /// The right bits of the shift filled with zeros.
  /// Left-overflowing bits, including the sign bit, are discarded.
  ///
  /// For `y >= 8`, the semantics is the same as for `bitshiftLeft(x, y % 8)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftLeft(x, y + y % 8)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitshiftLeft(1, 4) // => +16 // 0x10 equivalent to `2 ** 4`.
  /// ```
  ///

  public func bitshiftLeft(x : Int8, y : Int8) : Int8 { x << y };

  /// Returns the signed bitwise right shift of `x` by `y`, `x >> y`.
  /// The sign bit is retained and the left side is filled with the sign bit.
  /// Right-underflowing bits are discarded, i.e. not rotated to the left side.
  ///
  /// For `y >= 8`, the semantics is the same as for `bitshiftRight(x, y % 8)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftRight (x, y + y % 8)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitshiftRight(64, 4) // => +4 // equivalent to `64 / (2 ** 4)`
  /// ```
  ///

  public func bitshiftRight(x : Int8, y : Int8) : Int8 { x >> y };

  /// Returns the bitwise left rotatation of `x` by `y`, `x <<> y`.
  /// Each left-overflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 8`, the semantics is the same as for `bitrotLeft(x, y % 8)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitrotLeft(0x11 /* 0b0001_0001 */, 2) // => +68 // 0b0100_0100 == 0x44.
  /// ```
  ///

  public func bitrotLeft(x : Int8, y : Int8) : Int8 { x <<> y };

  /// Returns the bitwise right rotation of `x` by `y`, `x <>> y`.
  /// Each right-underflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 8`, the semantics is the same as for `bitrotRight(x, y % 8)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitrotRight(0x11 /* 0b0001_0001 */, 1) // => -120 // 0b1000_1000 == 0x88.
  /// ```
  ///

  public func bitrotRight(x : Int8, y : Int8) : Int8 { x <>> y };

  /// Returns the value of bit `p` in `x`, `x & 2**p == 2**p`.
  /// If `p >= 8`, the semantics is the same as for `bittest(x, p % 8)`.
  /// This is equivalent to checking if the `p`-th bit is set in `x`, using 0 indexing.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bittest(64, 6) // => true
  /// ```
  public func bittest(x : Int8, p : Nat) : Bool {
    Prim.btstInt8(x, Prim.intToInt8(p))
  };

  /// Returns the value of setting bit `p` in `x` to `1`.
  /// If `p >= 8`, the semantics is the same as for `bitset(x, p % 8)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitset(0, 6) // => +64
  /// ```
  public func bitset(x : Int8, p : Nat) : Int8 {
    x | (1 << Prim.intToInt8(p))
  };

  /// Returns the value of clearing bit `p` in `x` to `0`.
  /// If `p >= 8`, the semantics is the same as for `bitclear(x, p % 8)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitclear(-1, 6) // => -65
  /// ```
  public func bitclear(x : Int8, p : Nat) : Int8 {
    x & ^(1 << Prim.intToInt8(p))
  };

  /// Returns the value of flipping bit `p` in `x`.
  /// If `p >= 8`, the semantics is the same as for `bitclear(x, p % 8)`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitflip(127, 6) // => +63
  /// ```
  public func bitflip(x : Int8, p : Nat) : Int8 {
    x ^ (1 << Prim.intToInt8(p))
  };

  /// Returns the count of non-zero bits in `x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitcountNonZero(0x0f) // => +4
  /// ```
  public let bitcountNonZero : (x : Int8) -> Int8 = Prim.popcntInt8;

  /// Returns the count of leading zero bits in `x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitcountLeadingZero(0x08) // => +4
  /// ```
  public let bitcountLeadingZero : (x : Int8) -> Int8 = Prim.clzInt8;

  /// Returns the count of trailing zero bits in `x`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.bitcountTrailingZero(0x10) // => +4
  /// ```
  public let bitcountTrailingZero : (x : Int8) -> Int8 = Prim.ctzInt8;

  /// Returns the sum of `x` and `y`, `x +% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.addWrap(2 ** 6, 2 ** 6) // => -128 // overflow
  /// ```
  ///

  public func addWrap(x : Int8, y : Int8) : Int8 { x +% y };

  /// Returns the difference of `x` and `y`, `x -% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.subWrap(-2 ** 7, 1) // => +127 // underflow
  /// ```
  ///

  public func subWrap(x : Int8, y : Int8) : Int8 { x -% y };

  /// Returns the product of `x` and `y`, `x *% y`. Wraps on overflow.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.mulWrap(2 ** 4, 2 ** 4) // => 0 // overflow
  /// ```
  ///

  public func mulWrap(x : Int8, y : Int8) : Int8 { x *% y };

  /// Returns `x` to the power of `y`, `x **% y`.
  ///
  /// Wraps on overflow/underflow.
  /// Traps if `y < 0 or y >= 8`.
  ///
  /// Example:
  /// ```motoko include=import
  /// Int8.powWrap(2, 7) // => -128 // overflow
  /// ```
  ///

  public func powWrap(x : Int8, y : Int8) : Int8 { x **% y };

}
