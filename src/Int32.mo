/// 32-bit signed integers with checked arithmetic.
///
/// Common 32-bit integer functions.
/// Most operations are available as built-in operators (e.g. `1 + 1`).
import Int "Int";
import Prim "mo:⛔";

module {

  /// 32-bit signed integers.
  public type Int32 = Prim.Types.Int32;

  /// Converts a 32-bit signed integer to a signed integer with infinite precision.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.toInt(123_456) // => 123_456 : Int
  /// ```
  public let toInt : Int32 -> Int = Prim.int32ToInt;

  /// Converts a signed integer with infinite precision to a 32-bit signed integer.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.fromInt(123_456) // => +123_456 : Int32
  /// ```
  public let fromInt : Int -> Int32 = Prim.intToInt32;

  /// Converts a signed integer with infinite precision to a 32-bit signed integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.fromIntWrap(-123_456) // => -123_456 : Int
  /// ```
  public let fromIntWrap : Int -> Int32 = Prim.intToInt32Wrap;

  /// Converts an unsigned 32-bit integer to a signed 32-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.fromNat32(123_456) // => +123_456 : Int32
  /// ```
  public let fromNat32 : Nat32 -> Int32 = Prim.nat32ToInt32;

  /// Converts a signed 32-bit integer to an unsigned 32-bit integer.
  ///
  /// Wraps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.toNat32(-1) // => 4_294_967_295 : Nat32 // underflow
  /// ```
  public let toNat32 : Int32 -> Nat32 = Prim.int32ToNat32;

  /// Returns the Text representation of `x`.
  /// Formats the integer in decimal representation without underscore separators for thousand figures.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.toText(-123456) // => "-123456"
  /// ```
  public func toText(x : Int32) : Text {
    Int.toText(toInt(x))
  };

  /// Returns the absolute value of `x`.
  ///
  /// Traps when `x == -2 ** 31` (the minimum `Int32` value).
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.abs(-123456) // => +123_456
  /// ```
  public func abs(x : Int32) : Int32 {
    fromInt(Int.abs(toInt(x)))
  };

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.min(+2, -3) // => -3
  /// ```
  public func min(x : Int32, y : Int32) : Int32 {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.max(+2, -3) // => +2
  /// ```
  public func max(x : Int32, y : Int32) : Int32 {
    if (x < y) { y } else { x }
  };

  /// Returns `x == y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.equal(123, 123) // => true
  /// ```
  public func equal(x : Int32, y : Int32) : Bool { x == y };

  /// Returns `x != y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.notEqual(123, 123) // => false
  /// ```
  public func notEqual(x : Int32, y : Int32) : Bool { x != y };

  /// Returns `x < y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.less(123, 1234) // => true
  /// ```
  public func less(x : Int32, y : Int32) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.lessOrEqual(123, 1234) // => true
  /// ```
  public func lessOrEqual(x : Int32, y : Int32) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.greater(1234, 123) // => true
  /// ```
  public func greater(x : Int32, y : Int32) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.greaterOrEqual(1234, 123) // => true
  /// ```
  public func greaterOrEqual(x : Int32, y : Int32) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.compare(123, 1234) // => #less
  /// ```
  public func compare(x : Int32, y : Int32) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the negation of `x`, `-x`.
  ///
  /// Traps on overflow, i.e. for `neg(-2 ** 31)`.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.neg(123) // => -123
  /// ```
  public func neg(x : Int32) : Int32 { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.add(1234, 123) // => +1_357
  /// ```
  public func add(x : Int32, y : Int32) : Int32 { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.sub(1234, 123) // => +1_111
  /// ```
  public func sub(x : Int32, y : Int32) : Int32 { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// Traps on overflow/underflow.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.mul(123, 100) // => +12_300
  /// ```
  public func mul(x : Int32, y : Int32) : Int32 { x * y };

  /// Returns the signed integer division of `x by y`, `x / y`.
  /// Rounds the quotient towards zero, which is the same as truncating the decimal places of the quotient.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.div(123, 10) // => +12
  /// ```
  public func div(x : Int32, y : Int32) : Int32 { x / y };

  /// Returns the remainder of the signed integer division of `x` by `y`, `x % y`,
  /// which is defined as `x - x / y * y`.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.rem(123, 10) // => +3
  /// ```
  public func rem(x : Int32, y : Int32) : Int32 { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Traps on overflow/underflow and when `y < 0 or y >= 32`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.pow(2, 10) // => +1_024
  /// ```
  public func pow(x : Int32, y : Int32) : Int32 { x ** y };

  /// Returns the bitwise negation of `x`, `^x`.
  /// Issue: The argument `y` is not needed and will be removed in future.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// let unused = 0 : Int32; // will be fixed in future
  /// Int32.bitnot(-256 /* 0xffff_ff00 */, unused) // => +255 // 0xff
  /// ```
  public func bitnot(x : Int32, y : Int32) : Int32 { ^x };

  /// Returns the bitwise "and" of `x` and `y`, `x & y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitand(0xffff, 0x00f0) // => +240 // 0xf0
  /// ```
  public func bitand(x : Int32, y : Int32) : Int32 { x & y };

  /// Returns the bitwise "or" of `x` and `y`, `x | y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitor(0xffff, 0x00f0) // => +65_535 // 0xffff
  /// ```
  public func bitor(x : Int32, y : Int32) : Int32 { x | y };

  /// Returns the bitwise "exclusive or" of `x` and `y`, `x ^ y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitxor(0xffff, 0x00f0) // => +65_295 // 0xff0f
  /// ```
  public func bitxor(x : Int32, y : Int32) : Int32 { x ^ y };

  /// Returns the bitwise left shift of `x` by `y`, `x << y`.
  /// The right bits of the shift filled with zeros.
  /// Left-overflowing bits, including the sign bit, are discarded.
  ///
  /// For `y >= 32`, the semantics is the same as for `bitshiftLeft(x, y % 32)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftLeft(x, y + y % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitshiftLeft(1, 8) // => +256 // 0x100 equivalent to `2 ** 8`.
  /// ```
  public func bitshiftLeft(x : Int32, y : Int32) : Int32 { x << y };

  /// Returns the signed bitwise right shift of `x` by `y`, `x >> y`.
  /// The sign bit is retained and the left side is filled with the sign bit.
  /// Right-underflowing bits are discarded, i.e. not rotated to the left side.
  ///
  /// For `y >= 32`, the semantics is the same as for `bitshiftRight(x, y % 32)`.
  /// For `y < 0`,  the semantics is the same as for `bitshiftRight (x, y + y % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitshiftRight(1024, 8) // => +4 // equivalent to `1024 / (2 ** 8)`
  /// ```
  public func bitshiftRight(x : Int32, y : Int32) : Int32 { x >> y };

  /// Returns the bitwise left rotatation of `x` by `y`, `x <<> y`.
  /// Each left-overflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 32`, the semantics is the same as for `bitrotLeft(x, y % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitrotLeft(0x2000_0001, 4) // => +18 // 0x12.
  /// ```
  public func bitrotLeft(x : Int32, y : Int32) : Int32 { x <<> y };

  /// Returns the bitwise right rotation of `x` by `y`, `x <>> y`.
  /// Each right-underflowing bit is inserted again on the right side.
  /// The sign bit is rotated like other bits, i.e. the rotation interprets the number as unsigned.
  ///
  /// Changes the direction of rotation for negative `y`.
  /// For `y >= 32`, the semantics is the same as for `bitrotRight(x, y % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitrotRight(0x0002_0001, 8) // => +16_777_728 // 0x0100_0200.
  /// ```
  public func bitrotRight(x : Int32, y : Int32) : Int32 { x <>> y };

  /// Returns the value of bit `p` in `x`, `x & 2**p == 2**p`.
  /// If `p >= 32`, the semantics is the same as for `bittest(x, p % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bittest(128, 7) // => true
  /// ```
  public func bittest(x : Int32, p : Nat) : Bool {
    Prim.btstInt32(x, Prim.intToInt32(p))
  };

  /// Returns the value of setting bit `p` in `x` to `1`.
  /// If `p >= 32`, the semantics is the same as for `bitset(x, p % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitset(0, 7) // => +128
  /// ```
  public func bitset(x : Int32, p : Nat) : Int32 {
    x | (1 << Prim.intToInt32(p))
  };

  /// Returns the value of clearing bit `p` in `x` to `0`.
  /// If `p >= 32`, the semantics is the same as for `bitclear(x, p % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitclear(-1, 7) // => -129
  /// ```
  public func bitclear(x : Int32, p : Nat) : Int32 {
    x & ^(1 << Prim.intToInt32(p))
  };

  /// Returns the value of flipping bit `p` in `x`.
  /// If `p >= 32`, the semantics is the same as for `bitclear(x, p % 32)`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitflip(255, 7) // => +127
  /// ```
  public func bitflip(x : Int32, p : Nat) : Int32 {
    x ^ (1 << Prim.intToInt32(p))
  };

  /// Returns the count of non-zero bits in `x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitcountNonZero(0xffff) // => +16
  /// ```
  public let bitcountNonZero : (x : Int32) -> Int32 = Prim.popcntInt32;

  /// Returns the count of leading zero bits in `x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitcountLeadingZero(0x8000) // => +16
  /// ```
  public let bitcountLeadingZero : (x : Int32) -> Int32 = Prim.clzInt32;

  /// Returns the count of trailing zero bits in `x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.bitcountTrailingZero(0x0201_0000) // => +16
  /// ```
  public let bitcountTrailingZero : (x : Int32) -> Int32 = Prim.ctzInt32;

  /// Returns the sum of `x` and `y`, `x +% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.addWrap(2 ** 30, 2 ** 30) // => -2_147_483_648 // overflow
  /// ```
  public func addWrap(x : Int32, y : Int32) : Int32 { x +% y };

  /// Returns the difference of `x` and `y`, `x -% y`.
  ///
  /// Wraps on overflow/underflow.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.subWrap(-2 ** 31, 1) // => +2_147_483_647 // underflow
  /// ```
  public func subWrap(x : Int32, y : Int32) : Int32 { x -% y };

  /// Returns the product of `x` and `y`, `x *% y`. Wraps on overflow.
  ///
  /// Wraps on overflow/underflow.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.mulWrap(2 ** 16, 2 ** 16) // => 0 // overflow
  /// ```
  public func mulWrap(x : Int32, y : Int32) : Int32 { x *% y };

  /// Returns `x` to the power of `y`, `x **% y`.
  ///
  /// Wraps on overflow/underflow.
  /// Traps if `y < 0 or y >= 32`.
  ///
  ///
  /// Example:
  /// ```motoko
  /// import Int32 "mo:base/Int32";
  ///
  /// Int32.powWrap(2, 31) // => -2_147_483_648 // overflow
  /// ```
  public func powWrap(x : Int32, y : Int32) : Int32 { x **% y };

}
