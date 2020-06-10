/// Characters
import Prim "mo:prim";
module {

  /// Convert a character to a word.
  let toWord32 : Char -> Word32 = Prim.charToWord32;

  /// Convert a word to a character.
  let fromWord32 : Word32 -> Char = Prim.word32ToChar;

  /// Convert a character to text.
  let toText : Char -> Text = Prim.charToText;

  /// Is a character a digit between 0 and 9.
  public func isDigit(char : Char) : Bool {
    Prim.charToWord32(char) - Prim.charToWord32('0') <= (9 : Word32)
  };
}
