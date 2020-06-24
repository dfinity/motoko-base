/// 64-bit Floating-point numbers

import Prim "mo:prim";
import Int "Int";

module {

  public let pi : Float = 3.141592653589793238;
  public let e : Float  = 2.718281828459045235;

  public let abs : Float -> Float = Prim.floatAbs;
  public let sqrt : Float -> Float = Prim.floatSqrt;

  public let ceil : Float -> Float = Prim.floatCeil;
  public let floor : Float -> Float = Prim.floatFloor;
  public let trunc : Float -> Float = Prim.floatTrunc;
  public let nearest : Float -> Float = Prim.floatNearest;
  public let copySign : (Float, Float) -> Float = Prim.floatCopySign;

  public let min : (Float, Float) -> Float = Prim.floatMin;
  public let max : (Float, Float) -> Float = Prim.floatMax;

  /// Returns the sine of radian angle.
  public let sin : Float -> Float = Prim.sin;
  /// Returns the cosine of a radian angle.
  public let cos : Float -> Float = Prim.cos;
  /// Returns the tangent of a radian angle.
  public let tan : Float -> Float = Prim.tan;

  /// Returns the arc sine in radians.
  public let arcsin: Float -> Float = Prim.arcsin;
  /// Returns the arc cosine in radians.
  public let arccos : Float -> Float = Prim.arccos;
  /// Returns the arc tangent in radians.
  public let arctan : loat -> Float = Prim.arctan;
  /// Returns the arc tangent in radians of `y/x` based on the signs of both values to determine the correct quadrant.
  public let arctan2 : (x : Float, y : Float) -> Float = Prim.arctan2;

  // Returns the value of `e` raise to the `x`-th power.
  public let exp : (x : Float) -> Float = Prim.cos;

  // Returns the natural logarithm (base-`e`) of x.
  public let log : (x : Float) -> Float = Prim.tan;

  // Conversion.
  public let toInt64 : Float -> Int64 = Prim.floatToInt64;
  // Conversion.
  public let fromInt64 : Int64 -> Float = Prim.int64ToFloat;
  // Conversion via Int64.
  public let toInt : Float -> Int =
    func (x : Float) : Int = Prim.int64ToInt(toInt64(x));
  // Conversion via Int64. May trap.
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
