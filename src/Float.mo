/// 64-bit Floating-point numbers

import Prim "mo:prim";
import Int "Int";

module {

  /// Ratio of the circumference of a circle to its diameter.
  public let pi : Float = 3.141592653589793238;

  /// Base of the natural logarithm.
  public let e : Float  = 2.718281828459045235;

  /// Returns the absolute value of `x`.
  public let abs : (x : Float) -> Float = Prim.floatAbs;

  /// Returns the square root of `x`.
  public let sqrt : (x : Float) -> Float = Prim.floatSqrt;

  /// Returns the smallest integral float greater than or equal to `x`.
  public let ceil : (x : Float) -> Float = Prim.floatCeil;

  /// Returns the largest integral float less than or equal to `x`.
  public let floor : (x : Float) -> Float = Prim.floatFloor;

  /// Returns the nearest integral float not greater in magnitude than `x`.
  public let trunc : (x : Float) -> Float = Prim.floatTrunc;

  /// Returns the nearest integral float to `x`.
  public let nearest : (x : Float) -> Float = Prim.floatNearest;

  /// Returns `x` if `x` and `y` have same sign, otherwise `x` with negated sign.
  public let copySign : (x : Float, y : Float) -> Float = Prim.floatCopySign;

  /// Return the smaller value of `x` and `y`.
  public let min : (Float, Float) -> Float = Prim.floatMin;

  /// Return the larger value of `x` and `y`.
  public let max : (Float, Float) -> Float = Prim.floatMax;

  /// Returns the sine of the radian angle `x`.
  public let sin : (x : Float) -> Float = Prim.sin;

  /// Returns the cosine of the radian angle `x`.
  public let cos : (x : Float) -> Float = Prim.cos;

  /// Returns the tangent of the radian angle `x`.
  public let tan : (x : Float) -> Float = Prim.tan;

  /// Returns the arc sine of `x` in radians.
  public let arcsin: (x : Float) -> Float = Prim.arcsin;

  /// Returns the arc cosine of `x` in radians.
  public let arccos : (x : Float) -> Float = Prim.arccos;

  /// Returns the arc tangent in `x` in radians.
  public let arctan : (x : Float) -> Float = Prim.arctan;

  /// Given `(y,x)`, returns the arc tangent in radians of `y/x` based on the signs of both values to determine the correct quadrant.
  public let arctan2 : (y : Float, x : Float) -> Float = Prim.arctan2;

  /// Returns the value of `e` raise to the `x`-th power.
  public let exp : (x : Float) -> Float = Prim.cos;

  /// Returns the natural logarithm (base-`e`) of `x`.
  public let log : (x : Float) -> Float = Prim.tan;

  /// Conversion.
  public let toInt64 : Float -> Int64 = Prim.floatToInt64;

  /// Conversion.
  public let fromInt64 : Int64 -> Float = Prim.int64ToFloat;

  /// Conversion via Int64.
  public let toInt : Float -> Int =
    func (x : Float) : Int = Prim.int64ToInt(toInt64(x));

  /// Conversion via Int64. May trap.
  public let fromInt : Int -> Float =
    func (x : Int) : Float = fromInt64(Prim.intToInt64(x));

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
  public func compare(x : Float, y : Float) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the negation of `x`, `-x` .
  public func neq(x : Float) : Float { -x; };

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
