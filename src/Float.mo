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
///   ```motoko
///   0.1 + 0.1 + 0.1 == 0.3 // => false
///   ```
///
///   ```motoko
///  1e16 + 1.0 != 1e16 // => false
///   ```
///
///  (and many more cases)
///
/// Advice:
/// * Floating point number comparisons by `==` or `!=` are discouraged. Instead, it is better to compare
///   floating-point numbers with a numerical tolerance, called epsilon.
///
///   Example:
///   ```motoko
///   import Float "mo:base/Float";
///   let x = 0.1 + 0.1 + 0.1;
///   let y = 0.3;
///
///   let epsilon = 1e-6; // This depends on the application case (needs a numerical error analysis).
///   let equals = Float.abs(x - y) <= epsilon;
///   ```
///
/// * For absolute precision, it is recommened to encode the fraction number as a pair of a Nat for the base
///   and a Nat for the exponent (decimal point).
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
  /// ```
  /// abs(+inf) => +inf
  /// abs(-inf) => +inf
  /// abs(nan)  => nan
  /// abs(-0.0) => 0.0
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.abs(-1.2) // => 1.2
  /// ```
  public let abs : (x : Float) -> Float = Prim.floatAbs;

  /// Returns the square root of `x`.
  ///
  /// Special cases:
  /// ```
  /// sqrt(+inf) => +inf
  /// sqrt(-0.0) => -0.0
  /// sqrt(x)    => nan if x < 0.0
  /// sqrt(nan)  => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.sqrt(6.25) // => 2.5
  /// ```
  public let sqrt : (x : Float) -> Float = Prim.floatSqrt;

  /// Returns the smallest integral float greater than or equal to `x`.
  ///
  /// Special cases:
  /// ```
  /// ceil(+inf) => +inf
  /// ceil(-inf) => -inf
  /// ceil(nan)  => nan
  /// ceil(0.0)  => 0.0
  /// ceil(-0.0) => -0.0
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.ceil(1.2) // => 2.0
  /// ```
  public let ceil : (x : Float) -> Float = Prim.floatCeil;

  /// Returns the largest integral float less than or equal to `x`.
  ///
  /// Special cases:
  /// ```
  /// floor(+inf) => +inf
  /// floor(-inf) => -inf
  /// floor(nan)  => nan
  /// floor(0.0)  => 0.0
  /// floor(-0.0) => -0.0
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.floor(1.2) // => 1.0
  /// ```
  public let floor : (x : Float) -> Float = Prim.floatFloor;

  /// Returns the nearest integral float not greater in magnitude than `x`.
  /// This is equilvent to returning `x` with truncating its decimal places.
  ///
  /// Special cases:
  /// ```
  /// trunc(+inf) => +inf
  /// trunc(-inf) => -inf
  /// trunc(nan)  => nan
  /// trunc(0.0)  => 0.0
  /// trunc(-0.0) => -0.0
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.trunc(2.75) // => 2.0
  /// ```
  public let trunc : (x : Float) -> Float = Prim.floatTrunc;

  /// Returns the nearest integral float to `x`.
  /// A decimal place of exactly .5 is rounded up for `x > 0`
  /// and rounded down for `x < 0`
  ///
  /// Special cases:
  /// ```
  /// nearest(+inf) => +inf
  /// nearest(-inf) => -inf
  /// nearest(nan)  => nan
  /// nearest(0.0)  => 0.0
  /// nearest(-0.0) => -0.0
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.nearest(2.75) // => 3.0
  /// ```
  public let nearest : (x : Float) -> Float = Prim.floatNearest;

  /// Returns `x` if `x` and `y` have same sign, otherwise `x` with negated sign.
  ///
  /// The sign bit of zero, infinity, and `nan` is considered.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.copySign(1.2, -2.3) // => -1.2
  /// ```
  public let copySign : (x : Float, y : Float) -> Float = Prim.floatCopySign;

  /// Returns the smaller value of `x` and `y`.
  ///
  /// Special cases:
  /// ```
  /// min(nan, y) => nan for any Float y
  /// min(x, nan) => nan for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.min(1.2, -2.3) // => -2.3 (with numerical imprecision)
  /// ```
  public let min : (x : Float, y : Float) -> Float = Prim.floatMin;

  /// Returns the larger value of `x` and `y`.
  ///
  /// Special cases:
  /// ```
  /// max(nan, y) => nan for any Float y
  /// max(x, nan) => nan for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.max(1.2, -2.3) // => 1.2
  /// ```
  public let max : (x : Float, y : Float) -> Float = Prim.floatMax;

  /// Returns the sine of the radian angle `x`.
  ///
  /// Special cases:
  /// ```
  /// sin(+inf) => nan
  /// sin(-inf) => nan
  /// sin(nan) => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.sin(Float.pi / 2) // => 1.0
  /// ```
  public let sin : (x : Float) -> Float = Prim.sin;

  /// Returns the cosine of the radian angle `x`.
  ///
  /// Special cases:
  /// ```
  /// cos(+inf) => nan
  /// cos(-inf) => nan
  /// cos(nan)  => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.cos(Float.pi / 2) // => 0.0 (with numerical imprecision)
  /// ```
  public let cos : (x : Float) -> Float = Prim.cos;

  /// Returns the tangent of the radian angle `x`.
  ///
  /// Special cases:
  /// ```
  /// tan(+inf) => nan
  /// tan(-inf) => nan
  /// tan(nan)  => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.tan(Float.pi / 4) // => 1.0 (with numerical imprecision)
  /// ```
  public let tan : (x : Float) -> Float = Prim.tan;

  /// Returns the arc sine of `x` in radians.
  ///
  /// Special cases:
  /// ```
  /// arcsin(x)   => nan if x > 1.0
  /// arcsin(x)   => nan if x < -1.0
  /// arcsin(nan) => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.arcsin(1.0) // => Float.pi / 2
  /// ```
  public let arcsin : (x : Float) -> Float = Prim.arcsin;

  /// Returns the arc cosine of `x` in radians.
  ///
  /// Special cases:
  /// ```
  /// arccos(x)  => nan if x > 1.0
  /// arccos(x)  => nan if x < -1.0
  /// arcos(nan) => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.arccos(1.0) // => 0.0
  /// ```
  public let arccos : (x : Float) -> Float = Prim.arccos;

  /// Returns the arc tangent of `x` in radians.
  ///
  /// Special cases:
  /// ```
  /// arctan(+inf) => pi / 2
  /// arctan(-inf) => -pi / 2
  /// arctan(nan)  => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.arctan(1.0) // => Float.pi / 4
  /// ```
  public let arctan : (x : Float) -> Float = Prim.arctan;

  /// Given `(y,x)`, returns the arc tangent in radians of `y/x` based on the signs of both values to determine the correct quadrant.
  ///
  /// Special cases:
  /// ```
  /// arctan2(0.0, 0.0)   => 0.0
  /// arctan2(-0.0, 0.0)  => -0.0
  /// arctan2(0.0, -0.0)  => pi
  /// arctan2(-0.0, -0.0) => -pi
  /// arctan2(+inf, +inf) => pi / 4
  /// arctan2(+inf, -inf) => 3 * pi / 4
  /// arctan2(-inf, +inf) => -pi / 4
  /// arctan2(-inf, -inf) => -3 * pi / 4
  /// arctan2(nan, x)     => nan for any Float x
  /// arctan2(y, nan)     => nan for any Float y
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// let sqrt2over2 = Float.sqrt(2) / 2;
  /// Float.arctan2(sqrt2over2, sqrt2over2) // => Float.pi / 4
  /// ```
  public let arctan2 : (y : Float, x : Float) -> Float = Prim.arctan2;

  /// Returns the value of `e` raised to the `x`-th power.
  ///
  /// Special cases:
  /// ```
  /// exp(+inf) => +inf
  /// exp(-inf) => 0.0
  /// exp(nan)  => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.exp(1.0) // => Float.e
  /// ```
  public let exp : (x : Float) -> Float = Prim.exp;

  /// Returns the natural logarithm (base-`e`) of `x`.
  ///
  /// Special cases:
  /// ```
  /// log(0.0)  => -inf
  /// log(-0.0) => -inf
  /// log(x)    => nan if x < 0.0
  /// log(+inf) => +inf
  /// log(nan)  => nan
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.log(Float.e) // => 1.0
  /// ```
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
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.format(#exp 3, 123.0) // => "1.230e+02"
  /// ```
  public func format(fmt : { #fix : Nat8; #exp : Nat8; #gen : Nat8; #hex : Nat8; #exact }, x : Float) : Text = switch fmt {
    case (#fix(prec)) { Prim.floatToFormattedText(x, prec, 0) };
    case (#exp(prec)) { Prim.floatToFormattedText(x, prec, 1) };
    case (#gen(prec)) { Prim.floatToFormattedText(x, prec, 2) };
    case (#hex(prec)) { Prim.floatToFormattedText(x, prec, 3) };
    case (#exact) { Prim.floatToFormattedText(x, 17, 2) }
  };

  /// Conversion to Text. Use `format(fmt, x)` for more detailed control.
  ///
  /// `-0.0` is formatted with negative sign bit.
  /// Positive infinity is formatted as `inf`.
  /// Negative infinity is formatted as `-inf`.
  /// `nan` is formatted as `nan` or `-nan` depending on its sign bit.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.toText(0.12) // => "0.12"
  /// ```
  public let toText : Float -> Text = Prim.floatToText;

  /// Conversion to Int64 by truncating Float, equivalent to `toInt64(trunc(f))`
  ///
  /// Traps if the floating point number is larger or smaller than the representable Int64.
  /// Also traps for `inf`, `-inf`, and `nan`.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.toInt64(-12.3) // => -12
  /// ```
  public let toInt64 : Float -> Int64 = Prim.floatToInt64;

  /// Conversion from Int64.
  ///
  /// Note: The floating point number may be imprecise for large or small Int64.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.fromInt64(-42) // => -42.0
  /// ```
  public let fromInt64 : Int64 -> Float = Prim.int64ToFloat;

  /// Conversion to Int.
  ///
  /// Traps for `inf`, `-inf`, and `nan`.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.toInt(1.2e6) // => +1_200_000
  /// ```
  public let toInt : Float -> Int = Prim.floatToInt;

  /// Conversion from Int. May result in `Inf`.
  ///
  /// Note: The floating point number may be imprecise for large or small Int values.
  /// Returns `inf` if the integer is greater than the maximum floating point number.
  /// Returns `-inf` if the integer is less than the minimum floating point number.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.fromInt(-123) // => -123.0
  /// ```
  public let fromInt : Int -> Float = Prim.intToFloat;

  /// Returns `x == y`.
  ///
  /// Note: This operation is discouraged as it does not consider numerical errors, see comment above.
  ///
  /// Special cases:
  /// ```
  /// equal(+0.0, -0.0) => true
  /// equal(-0.0, +0.0) => true
  /// equal(+inf, +inf) => true
  /// equal(-inf, -inf) => true
  /// equal(nan, nan)   => false
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.equal(-12.3, -1.23e1) // => true
  /// ```
  public func equal(x : Float, y : Float) : Bool { x == y };

  /// Returns `x != y`.
  ///
  /// Note: This operation is discouraged as it does not consider numerical errors, see comment above.
  ///
  /// Special cases:
  /// ```
  /// notEqual(+0.0, -0.0) => false
  /// notEqual(-0.0, +0.0) => false
  /// notEqual(+inf, +inf) => false
  /// notEqual(-inf, -inf) => false
  /// notEqual(nan, nan)   => true
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.notEqual(-12.3, -1.23e1) // => false
  /// ```
  public func notEqual(x : Float, y : Float) : Bool { x != y };

  /// Returns `x < y`.
  ///
  /// Special cases:
  /// ```
  /// less(+0.0, -0.0) => false
  /// less(-0.0, +0.0) => false
  /// less(nan, y)     => false for any Float y
  /// less(x, nan)     => false for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.less(Float.e, Float.pi) // => true
  /// ```
  public func less(x : Float, y : Float) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Special cases:
  /// ```
  /// lessOrEqual(+0.0, -0.0) => true
  /// lessOrEqual(-0.0, +0.0) => true
  /// lessOrEqual(nan, y)     => false for any Float y
  /// lessOrEqual(x, nan)     => false for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.lessOrEqual(0.123, 0.1234) // => true
  /// ```
  public func lessOrEqual(x : Float, y : Float) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Special cases:
  /// ```
  /// greater(+0.0, -0.0) => false
  /// greater(-0.0, +0.0) => false
  /// greater(nan, y)     => false for any Float y
  /// greater(x, nan)     => false for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.greater(Float.pi, Float.e) // => true
  /// ```
  public func greater(x : Float, y : Float) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Special cases:
  /// ```
  /// greaterOrEqual(+0.0, -0.0) => true
  /// greaterOrEqual(-0.0, +0.0) => true
  /// greaterOrEqual(nan, y)     => false for any Float y
  /// greaterOrEqual(x, nan)     => false for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.greaterOrEqual(0.1234, 0.123) // => true
  /// ```
  public func greaterOrEqual(x : Float, y : Float) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  ///
  /// Note: This operation is discouraged as it does not consider numerical errors for equality, see comment above.
  ///
  /// Issue: Undefined behavior for `nan`, not defining a total number order.
  ///
  /// Special cases:
  /// ```
  /// compare(+0.0, -0.0) => #equal
  /// compare(-0.0, +0.0) => #equal
  /// compare(nan, y) is undefined for any Float y
  /// compare(x, nan) is undefined for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.compare(0.123, 0.1234) // => #less
  /// ```
  public func compare(x : Float, y : Float) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the negation of `x`, `-x` .
  ///
  /// Changes the sign bit for infinity.
  /// Issue: Inconsistent behavior for zero and `NaN`. Probably related to
  /// https://github.com/dfinity/motoko/issues/3646
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.neq(1.23) // => -1.23
  /// ```
  public func neq(x : Float) : Float { -x }; // Typo: Should be changed to `neg`

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// add(+inf, y)    => +inf if y is any Float except -inf and nan
  /// add(-inf, y)    => -inf if y is any Float except +inf and nan
  /// add(+inf, -inf) => nan
  /// add(nan, y)     => nan for any Float y
  /// ```
  /// The same cases apply commutatively, i.e. for `add(y, x)`.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.add(1.23, 0.123) // => 1.353
  /// ```
  public func add(x : Float, y : Float) : Float { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// sub(+inf, y)    => +inf if y is any Float except +inf or nan
  /// sub(-inf, y)    => -inf if y is any Float except -inf and nan
  /// sub(x, +inf)    => -inf if x is any Float except +inf and nan
  /// sub(x, -inf)    => +inf if x is any Float except -inf and nan
  /// sub(+inf, +inf) => nan
  /// sub(-inf, -inf) => nan
  /// sub(nan, y)     => nan for any Float y
  /// sub(x, nan)     => nan for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.sub(1.23, 0.123) // => 1.107
  /// ```
  public func sub(x : Float, y : Float) : Float { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// mul(+inf, y) => +inf if y > 0.0
  /// mul(-inf, y) => -inf if y > 0.0
  /// mul(+inf, y) => -inf if y < 0.0
  /// mul(-inf, y) => +inf if y < 0.0
  /// mul(+inf, 0.0) => nan
  /// mul(-inf, 0.0) => nan
  /// mul(nan, y) => nan for any Float y
  /// ```
  /// The same cases apply commutatively, i.e. for `mul(y, x)`.
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.mul(1.23, 1e2) // => 123.0
  /// ```
  public func mul(x : Float, y : Float) : Float { x * y };

  /// Returns the division of `x` by `y`, `x / y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// div(0.0, 0.0) => nan
  /// div(x, 0.0)   => +inf for x > 0.0
  /// div(x, 0.0)   => -inf for x < 0.0
  /// div(x, +inf)  => 0.0 for any x except +inf, -inf, and nan
  /// div(x, -inf)  => 0.0 for any x except +inf, -inf, and nan
  /// div(+inf, y)  => +inf if y >= 0.0
  /// div(+inf, y)  => -inf if y < 0.0
  /// div(-inf, y)  => -inf if y >= 0.0
  /// div(-inf, y)  => +inf if y < 0.0
  /// div(nan, y)   => nan for any Float y
  /// div(x, nan)   => nan for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.div(1.23, 1e2) // => 0.0123
  /// ```
  public func div(x : Float, y : Float) : Float { x / y };

  /// Returns the floating point division remainder `x % y`,
  /// which is defined as `x - trunc(x / y) * y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// rem(0.0, 0.0) => nan
  /// rem(x, y)     => +inf if sign(x) == sign(y) for any x and y not being +inf, -inf, or nan
  /// rem(x, y)     => -inf if sign(x) != sign(y) for any x and y not being +inf, -inf, or nan
  /// rem(x, +inf)  => x for any x except +inf, -inf, and nan
  /// rem(x, -inf)  => x for any x except +inf, -inf, and nan
  /// rem(+inf, y)  => nan for any Float y
  /// rem(-inf, y)  => nan for any Float y
  /// rem(nan, y)   => nan for any Float y
  /// rem(x, nan)   => nan for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.rem(7.2, 2.3) // => 0.3 (with numerical imprecision)
  /// ```
  public func rem(x : Float, y : Float) : Float { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Note: Numerical errors may occur, see comment above.
  ///
  /// Special cases:
  /// ```
  /// pow(+inf, y)    => +inf for any y > 0.0 including +inf
  /// pow(+inf, 0.0)  => 1.0
  /// pow(+inf, y)    => 0.0 for any y < 0.0 including -inf
  /// pow(x, +inf)    => +inf if x > 0.0 or x < 0.0
  /// pow(0.0, +inf)  => 0.0
  /// pow(x, -inf)    => 0.0 if x > 0.0 or x < 0.0
  /// pow(0.0, -inf)  => +inf
  /// pow(x, y)       => nan if x < 0.0 and y is a non-integral Float
  /// pow(-inf, y)    => +inf if y > 0.0 and y is a non-integral or an even integral Float
  /// pow(-inf, y)    => -inf if y > 0.0 and y is an odd integral Float
  /// pow(-inf, 0.0)  => 1.0
  /// pow(-inf, y)    => 0.0 if y < 0.0
  /// pow(-inf, +inf) => +inf
  /// pow(-inf, -inf) => 1.0
  /// pow(nan, y)     => nan if y != 0.0
  /// pow(nan, 0.0)   => 1.0
  /// pow(x, nan)     => nan for any Float x
  /// ```
  ///
  /// Example:
  /// ```motoko
  /// import Float "mo:base/Float";
  ///
  /// Float.pow(2.5, 2.0) // => 6.25
  /// ```
  public func pow(x : Float, y : Float) : Float { x ** y };

}
