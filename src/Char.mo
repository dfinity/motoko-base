/// Characters
import Prim "mo:prim";
module {

  /// Convert a character to a word.
  public let toWord32 : Char -> Word32 = Prim.charToWord32;

  /// Convert a word to a character.
  /// Traps if `w` is not a valid Unicode scalar value.
  /// Value `w` is valid if, and only if, `w < 0xD800 or (0xE000 <= w and w <= 0x10FFFF)`.
  public let fromWord32 : (w : Word32)-> Char = Prim.word32ToChar;

  /// Convert a character to text.
  public let toText : Char -> Text = Prim.charToText;

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
  public func compare(x : Char, y : Char) : { #less; #equal; #greater } {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  // not exposed pendig multi-char implementation.
  private let toUpper : (c : Char) -> Char = Prim.charToUpper;

  // not exposed pending multi-char implementation.
  private let toLower : (c : Char) -> Char = Prim.charToLower;

  /// Returns the Unicode _White_Space_ property of `c`.
  public let isWhitespace : (c : Char) -> Bool = Prim.charIsWhitespace;

  /// Returns the Unicode _Lowercase_ property of `c`.
  public let isLowercase : (c : Char) -> Bool = Prim.charIsLowercase;

  /// Returns the Unicode _Uppercase_ property of `c`.
  public let isUppercase : (c : Char) -> Bool = Prim.charIsUppercase;

  /// Returns the Unicode _Alphabetic_ property of `c`.
  public let isAlphabetic : (c : Char) -> Bool = Prim.charIsAlphabetic;

}
