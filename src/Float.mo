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
  ///   let result = Float.copySign(1.2, -2.3); // returns -1.2
  ///   ```
  public let copySign : (x : Float, y : Float) -> Float = Prim.floatCopySign;

  /// Returns the smaller value of `x` and `y`.
  /// 
  /// If `x` or `y` is `nan`, the result is also `nan`.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.min(1.2, -2.3); // returns -2.3
  ///   ```
  public let min : (x : Float, y : Float) -> Float = Prim.floatMin;

  /// Returns the larger value of `x` and `y`.
  /// 
  /// If `x` or `y` is `nan`, the result is also `nan`.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.max(1.2, -2.3); // returns 1.2
  ///   ```
  public let max : (x : Float, y : Float) -> Float = Prim.floatMax;

  /// Returns the sine of the radian angle `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `sin(x)` |
  /// | ------------ | --------------- |
  /// | `+inf`       | `nan`           |
  /// | `-inf`       | `nan`           |
  /// | `nan`        | `nan`           |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.sin(pi / 2); // returns 1.0
  ///   ```
  public let sin : (x : Float) -> Float = Prim.sin;

  /// Returns the cosine of the radian angle `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `cos(x)` |
  /// | ------------ | --------------- |
  /// | `+inf`       | `nan`           |
  /// | `-inf`       | `nan`           |
  /// | `nan`        | `nan`           |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.sin(Float.pi / 2); // returns 0.0
  ///   ```
  public let cos : (x : Float) -> Float = Prim.cos;

  /// Returns the tangent of the radian angle `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `tan(x)` |
  /// | ------------ | --------------- |
  /// | `+inf`       | `nan`           |
  /// | `-inf`       | `nan`           |
  /// | `nan`        | `nan`           |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.tan(Float.pi / 4); // returns 1.0
  ///   ``` 
  public let tan : (x : Float) -> Float = Prim.tan;

  /// Returns the arc sine of `x` in radians.
  ///
  /// Special cases:
  /// | Argument `x` | Result `arcsin(x)` |
  /// | ------------ | ------------------ |
  /// | `> 1.0`      | `nan`              |
  /// | `< -1.0`     | `nan`              |
  /// | `nan`        | `nan`              |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.arcsin(1.0); // returns Float.pi/2
  ///   ```
  public let arcsin : (x : Float) -> Float = Prim.arcsin;

  /// Returns the arc cosine of `x` in radians.
  ///
  /// Special cases:
  /// | Argument `x` | Result `arccos(x)` |
  /// | ------------ | ------------------ |
  /// | `> 1.0`      | `nan`              |
  /// | `< -1.0`     | `nan`              |
  /// | `nan`        | `nan`              |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.arccos(1.0); // returns 0.0
  ///   ```
  public let arccos : (x : Float) -> Float = Prim.arccos;

  /// Returns the arc tangent of `x` in radians.
  ///
  /// Special cases:
  /// | Argument `x` | Result `arctan(x)` |
  /// | ------------ | ------------------ |
  /// | `+inf`       | `pi / 2`           |
  /// | `-inf`       | `-pi / 2`          |
  /// | `nan`        | `nan`              |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.arctan(1.0); // returns Float.pi/4
  ///   ```
  public let arctan : (x : Float) -> Float = Prim.arctan;

  /// Given `(y,x)`, returns the arc tangent in radians of `y/x` based on the signs of both values to determine the correct quadrant.
  ///
  /// Special cases:
  /// | Argument `y` | Argument `x` | Result `arctan2(y, x)` |
  /// | ------------ | ------------ | ---------------------- |
  /// | `0.0`        | `0.0`        | `0.0`                  |
  /// | `-0.0`        | `0.0`       | `-0.0`                 |
  /// | `0.0`        | `-0.0`       | `pi`                   |
  /// | `-0.0`       | `-0.0`       | `-pi`                  |
  /// | `+inf`       | `+inf`       | `pi / 4`               |
  /// | `+inf`       | `-inf`       | `3 * pi / 4`           |
  /// | `-inf`       | `+inf`       | `-pi / 4`              |
  /// | `-inf`       | `-inf`       | `-3 * pi / 4`          |
  /// | `nan`        | (any)        | `nan`                  |
  /// | (any)        | `nan`        | `nan`                  |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let sqrt2over2 = Float.sqrt(2) / 2;
  ///   let result = Float.arctan2(sqrt2over2, sqrt2over2); // returns Float.pi/4
  ///   ```
  public let arctan2 : (y : Float, x : Float) -> Float = Prim.arctan2;

  /// Returns the value of `e` raised to the `x`-th power.
  ///
  /// Special cases:
  /// | Argument `x` | Result `exp(x)` |
  /// | ------------ | --------------- |
  /// | `+inf`       | `+inf`          |
  /// | `-inf`       | `0.0`           |
  /// | `nan`        | `nan`           |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.exp(1.0); // returns Float.e
  ///   ```
  public let exp : (x : Float) -> Float = Prim.exp;

  /// Returns the natural logarithm (base-`e`) of `x`.
  ///
  /// Special cases:
  /// | Argument `x` | Result `log(x)` |
  /// | ------------ | --------------- |
  /// | `0.0`        | `-inf`          |
  /// | `-0.0`       | `-inf`          |
  /// | `< 0`        | `nan`           |
  /// | `+inf`       | `+inf`          |
  /// | `nan`        | `nan`           |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.log(Float.e); // returns 1.0
  ///   ```
  public let log : (x : Float) -> Float = Prim.log;

  /// Formatting. `format(fmt, x)` formats `x` to `Text` according to the
  /// formatting directive `fmt`, which can take one of the following forms:
  ///
  /// * `#fix prec` as fixed-point format with `prec` digits
  /// * `#exp prec` as exponential format with `prec` digits
  /// * `#gen prec` as generic format with `prec` digits
  /// * `#hex prec` as hexadecimal format with `prec` digits
  /// * `#exact` as exact format that can be decoded without loss.
  ///
  /// `-0.0` is formatted with negative sign bit.
  /// Positive infinity is formatted as `inf`.
  /// Negative infinity is formatted as `-inf`.
  /// `nan` is formatted as `nan` or `-nan` depending on its sign bit.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.format(#exp 3, 123.0); // returns "1.230e+02"
  ///   ```
  public func format(fmt : { #fix : Nat8; #exp : Nat8; #gen : Nat8; #hex : Nat8; #exact }, x : Float) : Text = switch fmt {
    case (#fix(prec)) { Prim.floatToFormattedText(x, prec, 0) };
    case (#exp(prec)) { Prim.floatToFormattedText(x, prec, 1) };
    case (#gen(prec)) { Prim.floatToFormattedText(x, prec, 2) };
    case (#hex(prec)) { Prim.floatToFormattedText(x, prec, 3) };
    case (#exact) { Prim.floatToFormattedText(x, 17, 2) };
  };

  /// Conversion to Text. Use `format(fmt, x)` for more detailed control.
  ///
  /// `-0.0` is formatted with negative sign bit.
  /// Positive infinity is formatted as `inf`.
  /// Negative infinity is formatted as `-inf`.
  /// `nan` is formatted as `nan` or `-nan` depending on its sign bit.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.toText(0.12); // returns "0.120000"
  ///   ```
  public let toText : Float -> Text = Prim.floatToText;

  /// Conversion to Int64 by truncating Float, equivalent to `toInt64(trunc(f))`
  ///
  /// Traps if the floating point number is larger or smaller than the representable Int64.
  /// Also traps for `inf`, `-inf`, and `nan`.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.toInt64(-12.3); // returns -12
  ///   ```
  public let toInt64 : Float -> Int64 = Prim.floatToInt64;

  /// Conversion from Int64.
  ///
  /// Note: The floating point number may be imprecise for large or small Int64.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.fromInt64(-42); // returns -42.0
  ///   ```
  public let fromInt64 : Int64 -> Float = Prim.int64ToFloat;

  /// Conversion to Int.
  ///
  /// Traps for `inf`, `-inf`, and `nan`.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.toInt(1.2e6); // returns 1200000
  ///   ```
  public let toInt : Float -> Int = Prim.floatToInt;

  /// Conversion from Int. May result in `Inf`.
  ///
  /// Note: The floating point number may be imprecise for large or small Int values.
  /// Returns `inf` if the integer is greater than the maximum floating point number.
  /// Returns `-inf` if the integer is less than the minimum floating point number.
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.fromInt(-123); // returns -123.0
  ///   ```
  public let fromInt : Int -> Float = Prim.intToFloat;

  /// Returns `x == y`.
  ///
  /// Note: This operation is discouraged as it does not consider numerical errors, see comment above.
  ///
  /// Special cases:
  /// | Argument `x` | Argument `y` | Result `equal(x, y)` |
  /// | ------------ | ------------ | -------------------- |
  /// | `+0.0`       | `-0.0`       | `true`               |
  /// | `-0.0`       | `+0.0`       | `true`               |
  /// | `+inf`       | `+inf`       | `true`               |
  /// | `-inf`       | `-inf`       | `true`               |
  /// | `nan`        | `nan`        | `false`              |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.equal(-12.3, -1.23e1); // returns true
  ///   ```
  public func equal(x : Float, y : Float) : Bool { x == y };

  /// Returns `x != y`.
  ///
  /// Note: This operation is discouraged as it does not consider numerical errors, see comment above.
  ///
  /// Special cases:
  /// | Argument `x` | Argument `y` | Result `notEqual(x, y)` |
  /// | ------------ | ------------ | ----------------------- |
  /// | `+0.0`       | `-0.0`       | `false`                 |
  /// | `-0.0`       | `+0.0`       | `false`                 |
  /// | `+inf`       | `+inf`       | `false`                 |
  /// | `-inf`       | `-inf`       | `false`                 |
  /// | `nan`        | `nan`        | `true`                  |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.notEqual(-12.3, -1.23e1); // returns false
  ///   ```
  public func notEqual(x : Float, y : Float) : Bool { x != y };

  /// Returns `x < y`.
  ///
  /// Special cases:
  /// | Argument `x` | Argument `y` | Result `less(x, y)` |
  /// | ------------ | ------------ | ------------------- |
  /// | `+0.0`       | `-0.0`       | `false`             |
  /// | `-0.0`       | `+0.0`       | `false`             |
  /// | `nan`        | (any)        | `false`             |
  /// | (any)        | `nan`        | `false`             |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.less(Float.e, Float.pi); // returns true
  ///   ```
  public func less(x : Float, y : Float) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Special cases:
  /// | Argument `x` | Argument `y` | Result `lessOrEqual(x, y)` |
  /// | ------------ | ------------ | -------------------------- |
  /// | `+0.0`       | `-0.0`       | `true`                     |
  /// | `-0.0`       | `+0.0`       | `true`                     |
  /// | `nan`        | (any)        | `false`                    |
  /// | (any)        | `nan`        | `false`                    |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.lessOrEqual(0.123, 0.1234); // returns true
  ///   ```
  public func lessOrEqual(x : Float, y : Float) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Special cases:
  /// | Argument `x` | Argument `y` | Result `greater(x, y)` |
  /// | ------------ | ------------ | ---------------------- |
  /// | `nan`        | (any)        | `false`                |
  /// | (any)        | `nan`        | `false`                |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.greater(Float.pi, Float.e); // returns true
  ///   ```
  public func greater(x : Float, y : Float) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Special cases:
  /// | Argument `x` | Argument `y` | Result `greaterOrEqual(x, y)` |
  /// | ------------ | ------------ | ----------------------------- |
  /// | `nan`        | (any)        | `false`                       |
  /// | (any)        | `nan`        | `false`                       |
  ///
  ///   Example:
  ///   ```motoko name=initialize
  ///   let result = Float.greaterOrEqual(0.1234, 0.123); // returns true
  ///   ```
  public func greaterOrEqual(x : Float, y : Float) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  ///
  /// Note: This operation is discouraged as it does not consider numerical errors for equality, see comment above.
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
