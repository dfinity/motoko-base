/// 64-bit binary unsigned integers with modular arithmetic
///
/// Most operations are available as built-in operators (e.g. `1 + 1`).
import Nat "Nat";
import Int "Int";
import Prim "mo:prim";

module {

  /// Conversion.
  public let toNat : Word64 -> Nat = Prim.word64ToNat;

  /// Conversion. Wraps around.
  public let fromNat : Nat -> Word64  = Prim.natToWord64;

  /// Conversion. Returns `x mod 2^64`.
  public let toInt: (x : Word64) -> Int = Prim.word64ToInt;

  /// Conversion. Returns `x mod 2^64`.
  public let fromInt : (x : Int) -> Word64  = Prim.intToWord64;

  /// Returns the Text representation of `x`.
  public func toText(x : Word64) : Text {
    Nat.toText(toNat(x))
  };

  /// Returns the minimum of `x` and `y`.
  public func min(x : Word64, y : Word64) : Word64 {
    if (x < y) x else y
  };

  /// Returns the maximum of `x` and `y`.
  public func max( x : Word64, y : Word64) : Word64 {
    if (x < y) y else x
  };

  /// Returns `x == y`.
  public func equal(x : Word64, y : Word64) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Word64, y : Word64) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Word64, y : Word64) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Word64, y : Word64) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Word64, y : Word64) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Word64, y : Word64) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Word64, y : Word64) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns the sum of `x` and `y`, `(x + y) mod 2^64`.
  public func add(x : Word64, y : Word64) : Word64 { x + y };

  /// Returns the difference of `x` and `y`, `(2^64 + x - y) mod 2^64`.
  public func sub(x : Word64, y : Word64) : Word64 { x - y };

  /// Returns the product of `x` and `y`, `(x * y) mod 2^64`.
  public func mul(x : Word64, y : Word64) : Word64 { x * y };

  /// Returns the truncated quotient of `x and y`, `floor (x / y)`.
  /// Traps when `y` is 0.
  public func div(x : Word64, y : Word64) : Word64 { x / y };

  /// Returns the remainder of the division of 'x' by `y`, `x - y * floor ( x / y)`.
  /// Traps when `y` is 0.
  public func rem(x : Word64, y : Word64) : Word64 { x % y };

  /// Returns `x` to the power of `y`, `(x ** y) mod 2^64`.
  public func pow(x : Word64, y : Word64) : Word64 { x ** y };

  /// Returns the bitwise negation of `x`, `^x`.
  public func bitnot(x : Word64, y : Word64) : Word64 { ^x };

  /// Returns the bitwise and of `x` and `y`, `x & y`.
  public func bitand(x : Word64, y : Word64) : Word64 { x & y };

  /// Returns the bitwise or of `x` and `y`, `x \| y`.
  public func bitor(x : Word64, y : Word64) : Word64 { x | y };

  /// Returns the bitwise exclusive or of `x` and `y`, `x ^ y`.
  public func bitxor(x : Word64, y : Word64) : Word64 { x ^ y };

  /// Returns the bitwise shift left of `x` by `y`, `x << y`.
  public func bitshiftLeft(x : Word64, y : Word64) : Word64 { x << y };

  /// Returns the bitwise shift right of `x` by `y`, `x >> y`.
  public func bitshiftRight(x : Word64, y : Word64) : Word64 { x >> y };

  /// Returns the signed shift right of `x` by `y`, `x +>> y`.
  public func bitshiftRightSigned(x : Word64, y : Word64) : Word64 { x +>> y };

  /// Returns the bitwise rotate left of `x` by `y`, `x <<> y`.
  public func bitrotLeft(x : Word64, y : Word64) : Word64 { x <<> y };

  /// Returns the bitwise rotate right of `x` by `y`, `x <>> y`.
  public func bitrotRight(x : Word64, y : Word64) : Word64 { x <>> y };

  /// Returns the count of non-zero bits in `x`.
  public let popcnt : (x : Word64) -> Word64 = Prim.popcntWord64;

  /// Returns the count of leading zero bits in `x`.
  public let clz : (x : Word64) -> Word64 = Prim.clzWord64;

  /// Returns the count of trailing zero bits in `x`.
  public let ctz : (x : Word64) -> Word64 = Prim.ctzWord64;

  /// Returns the result of testing bit `y` in `x`, `(x & 2^y) == 2^y`.
  public let btst : (x : Word64, y: Word64) -> Bool = Prim.btstWord64;

}
