/// Floating-point numbers

import Prim "mo:prim";
import Int "Int";

module {
  public let pi : Float = 3.141592653589793238;
  public let e : Float  = 2.718281828459045235;

  public let abs : Float -> Float = Prim.floatAbs;  
  public let sqrt : Float -> Float = Prim.floatSqrt;
  public let pow : (Float, Float) -> Float =
    func (x : Float, y : Float) : Float = x ** y;

  public let ceil : Float -> Float = Prim.floatCeil;
  public let floor : Float -> Float = Prim.floatFloor;
  public let trunc : Float -> Float = Prim.floatTrunc;
  public let nearest : Float -> Float = Prim.floatNearest;

  public let min : (Float, Float) -> Float = Prim.floatMin;
  public let max : (Float, Float) -> Float = Prim.floatMax;

  public let sin : Float -> Float = Prim.sin;
  public let cos : Float -> Float = Prim.cos;

  public let toInt64 : Float -> Int64 = Prim.floatToInt64;
  public let fromInt64 : Int64 -> Float = Prim.int64ToFloat;
  public let toInt : Float -> Int =
    func (x : Float) : Int = Int.fromInt64(toInt64(x));
  public let fromInt : Int -> Float =
    func (x : Int) : Float = fromInt64(Int.toInt64(x));  

};
