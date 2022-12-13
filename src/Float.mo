/// Double precision (64-bit) floating-point numbers in IEEE 754 representation.
///
/// Common floating-point constants and functions.
/// 
/// Notation for special values in the documentation below:
/// `+inf`: Positive infinity
/// `-inf`: Negative infinity
/// `nan`: "not a number" (can have different sign bit values, but `nan != nan` regardless of the sign).
/// 
/// Note: 
/// Floating point numbers have limited precision and operations may inherently result in numerical errors.
/// 
/// Examples of numerical errors:
///   ```motoko name=initialize
///   assert(0.1 + 0.1 + 0.1 == 0.3); // Fails!
///   ```
///
///   ```motoko name=initialize
////  assert(1e16 + 1.0 != 1e16); // Fails!
///   ```
/// 
////  (and many more cases)
/// 
/// Advice:
/// * Floating point number comparisons by `==` or `!=` are discouraged. Instead, it is better to compare 
///   floating-point numbers with a numerical epsilon.
///
///   Example:
///   ```motoko name=initialize
///   let epsilon = 1e-6; // This depends on the application case (needs a numerical error analysis).
///   let equals = Float.abs(x - y) < epsilon;
///   ```
///
/// * For absolute precision, it is recommened to encode the fraction number as a pair of a Nat for the base 
//    and a Nat for the exponent (decimal point).
///

import Prim "mo:⛔";
import Int "Int";

module {

  /// 64-bit floating point number type.
  public type Float = Prim.Types.Float;

  /// Ratio of the circumference of a circle to its diameter.
  /// Note: Limited precision.
  public let pi : Float = 3.14159265358979323846; // taken from musl math.h

  /// Base of the natural logarithm.
  /// Note: Limited precision.
  public let e : Float = 2.7182818284590452354; // taken from musl math.h

  /// Returns the absolute value of `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `abs(x)` |
  /// | ------------ | --------------- |
  /// | `+inf`       | `+inf`          |
  /// | `-inf`       | `+inf`          |
  /// | `nan`        | `nan`           | 
  /// | `-0.0`       | `0.0`           |
  /// 
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.abs(-1.2); // result is 1.2
  ///   ```
  public let abs : (x : Float) -> Float = Prim.floatAbs;

  /// Returns the square root of `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `sqrt(x)` |
  /// | ------------ | ---------------- |
  /// | `+inf`       | `+inf`           |
  /// | `-0.0`       | `-0.0`           |
  /// | `< 0.0`      | `nan`            |
  /// | `nan`        | `nan`            | 
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.sqrt(6.25); // result is 2.5
  ///   ```
  public let sqrt : (x : Float) -> Float = Prim.floatSqrt;

  /// Returns the smallest integral float greater than or equal to `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `ceil(x)` |
  /// | ------------ | ---------------- |
  /// | `+inf`       | `+inf`           |
  /// | `-inf`       | `-inf`           |
  /// | `nan`        | `nan`            | 
  /// | `0.0`        | `0.0`            |
  /// | `-0.0`       | `-0.0`           |
  /// 
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.ceil(1.2); // result is 2.0
  ///   ```
  public let ceil : (x : Float) -> Float = Prim.floatCeil;

  /// Returns the largest integral float less than or equal to `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `floor(x)` |
  /// | ------------ | ----------------- |
  /// | `+inf`       | `+inf`            |
  /// | `-inf`       | `-inf`            |
  /// | `nan`        | `nan`             | 
  /// | `0.0`        | `0.0`             |
  /// | `-0.0`       | `-0.0`            |
  /// 
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.floor(1.2); // returns 1.0
  ///   ```
  public let floor : (x : Float) -> Float = Prim.floatFloor;

  /// Returns the nearest integral float not greater in magnitude than `x`.
  /// This is equilvent to returning `x` with truncating its decimal places.
  ///
  /// Special cases:
  /// | Argument `x` | Result `trunc(x)` |
  /// | ------------ | ----------------- |
  /// | `+inf`       | `+inf`            |
  /// | `-inf`       | `-inf`            |
  /// | `nan`        | `nan`             | 
  /// | `0.0`        | `0.0`             |
  /// | `-0.0`       | `-0.0`            |
  /// 
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.trunc(2.75); // returns 2.0
  ///   ```
  public let trunc : (x : Float) -> Float = Prim.floatTrunc;

  /// Returns the nearest integral float to `x`.
  /// A decimal place of exactly .5 is rounded up for `x > 0` 
  /// and rounded down for `x < 0`
  ///
  /// Special cases:
  /// | Argument `x` | Result `nearest(x)` |
  /// | ------------ | ------------------- |
  /// | `+inf`       | `+inf`              |
  /// | `-inf`       | `-inf`              |
  /// | `nan`        | `nan`               | 
  /// | `0.0`        | `0.0`               |
  /// | `-0.0`       | `-0.0`              |
  /// 
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.nearest(2.75); // returns 3.0
  ///   ```
  public let nearest : (x : Float) -> Float = Prim.floatNearest;

  /// Returns `x` if `x` and `y` have same sign, otherwise `x` with negated sign.
  ///
  /// The sign bit of zero, infinity, and `nan` is considered. 
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.copySign(1.5, 2.5); // returns 1.5
  ///   ```
  public let copySign : (x : Float, y : Float) -> Float = Prim.floatCopySign;

  /// Returns the smaller value of `x` and `y`.
  /// 
  /// If `x` or `y` is `nan`, the result is also `nan`.
  public let min : (x : Float, y : Float) -> Float = Prim.floatMin;

  /// Returns the larger value of `x` and `y`.
  /// 
  /// If `x` or `y` is `nan`, the result is also `nan`.
  public let max : (x : Float, y : Float) -> Float = Prim.floatMax;

  /// Returns the sine of the radian angle `x`.
  public let sin : (x : Float) -> Float = Prim.sin;

  /// Returns the cosine of the radian angle `x`.
  public let cos : (x : Float) -> Float = Prim.cos;

  /// Returns the tangent of the radian angle `x`.
  public let tan : (x : Float) -> Float = Prim.tan;

  /// Returns the arc sine of `x` in radians.
  public let arcsin : (x : Float) -> Float = Prim.arcsin;

  /// Returns the arc cosine of `x` in radians.
  public let arccos : (x : Float) -> Float = Prim.arccos;

  /// Returns the arc tangent of `x` in radians.
  public let arctan : (x : Float) -> Float = Prim.arctan;

  /// Given `(y,x)`, returns the arc tangent in radians of `y/x` based on the signs of both values to determine the correct quadrant.
  public let arctan2 : (y : Float, x : Float) -> Float = Prim.arctan2;

  /// Returns the value of `e` raised to the `x`-th power.
  public let exp : (x : Float) -> Float = Prim.exp;

  /// Returns the natural logarithm (base-`e`) of `x`.
  public let log : (x : Float) -> Float = Prim.log;

  /// Formatting. `format(fmt, x)` formats `x` to `Text` according to the
  /// formatting directive `fmt`, which can take one of the following forms:
  ///
  /// * `#fix prec` as fixed-point format with `prec` digits
  /// * `#exp prec` as exponential format with `prec` digits
  /// * `#gen prec` as generic format with `prec` digits
  /// * `#hex prec` as hexadecimal format with `prec` digits
  /// * `#exact` as exact format that can be decoded without loss.
  public func format(fmt : { #fix : Nat8; #exp : Nat8; #gen : Nat8; #hex : Nat8; #exact }, x : Float) : Text = switch fmt {
    case (#fix(prec)) { Prim.floatToFormattedText(x, prec, 0) };
    case (#exp(prec)) { Prim.floatToFormattedText(x, prec, 1) };
    case (#gen(prec)) { Prim.floatToFormattedText(x, prec, 2) };
    case (#hex(prec)) { Prim.floatToFormattedText(x, prec, 3) };
    case (#exact) { Prim.floatToFormattedText(x, 17, 2) };
  };

  /// Conversion to Text. Use `format(fmt, x)` for more detailed control.
  public let toText : Float -> Text = Prim.floatToText;

  /// Conversion to Int64 by truncating Float, equivalent to `toInt64(trunc(f))`
  public let toInt64 : Float -> Int64 = Prim.floatToInt64;

  /// Conversion from Int64.
  public let fromInt64 : Int64 -> Float = Prim.int64ToFloat;

  /// Conversion to Int.
  public let toInt : Float -> Int = Prim.floatToInt;

  /// Conversion from Int. May result in `Inf`.
  public let fromInt : Int -> Float = Prim.intToFloat;

  /// Returns `x == y`.
  public func equal(x : Float, y : Float) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Float, y : Float) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Float, y : Float) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Float, y : Float) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Float, y : Float) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Float, y : Float) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Float, y : Float) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater };
  };

  /// Returns the negation of `x`, `-x` .
  public func neq(x : Float) : Float { -x };

  /// Returns the sum of `x` and `y`, `x + y`.
  public func add(x : Float, y : Float) : Float { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  public func sub(x : Float, y : Float) : Float { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  public func mul(x : Float, y : Float) : Float { x * y };

  /// Returns the division of `x` by `y`, `x / y`.
  public func div(x : Float, y : Float) : Float { x / y };

  /// Returns the remainder of `x` divided by `y`, `x % y`.
  public func rem(x : Float, y : Float) : Float { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  public func pow(x : Float, y : Float) : Float { x ** y };

};
