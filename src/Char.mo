/// Characters
import Prim "mo:prim";
module {

  /// Convert a character to a word.
  let toWord32 : Char -> Word32 = Prim.charToWord32;

  /// Convert a word to a character. Traps if argument not in range [0 .. 0x1FFFFF] of valid Unicode code points.
  let fromWord32 : Word32 -> Char = Prim.word32ToChar;

   /// Convert a character to text.
  let toText : Char -> Text = Prim.charToText;

  /// Is a character a digit between 0 and 9.
  public func isDigit(char : Char) : Bool {
    Prim.charToWord32(char) - Prim.charToWord32('0') <= (9 : Word32)
  };

  /// Returns `x == y`.
  public func equal(x : Char, y : Char) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Char, y : Char) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Char, y : Char) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Char, y : Char) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Char, y : Char) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Char, y : Char) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Char, y : Char) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

}
