/**
[#mod-Hash]
= `Hash` -- Hash values
*/

import Prim "mo:prim";
import Iter "Iter";

module {
  /**
  Hash values represent a string of _hash bits_, packed into a `Word32`.
  */
  public type Hash = Word32;

  /**
  The hash length, always 31.
  */
  public let length : Nat = 31; // Why not 32?

  public let hashOfInt : Int -> Hash = func(i) {
    let j = Prim.intToWord32(i);
    hashWord8s(
      [j & (255 << 0),
       j & (255 << 8),
       j & (255 << 16),
       j & (255 << 24)
      ]);
  };

  /**
  WARNING: This only hashes the lowest 32 bits of the `Int`
  */
  public let hashOfIntAcc : (Hash, Int) -> Hash = func(h1, i) {
    let j = Prim.intToWord32(i);
    hashWord8s(
      [h1,
       j & (255 << 0),
       j & (255 << 8),
       j & (255 << 16),
       j & (255 << 24)
      ]);
  };

  /**
  WARNING: This only hashes the lowest 32 bits of the `Int`
  */
  public let hashOfText : Text -> Hash = func(t) {
    var x = 0 : Word32;
    for (c in t.chars()) {
      x := x ^ Prim.charToWord32(c);
    };
    return x
  };

  /**
  Project a given bit from the bit vector.
  */
  public let getHashBit : (Hash, Nat) -> Bool = func(h, pos) {
    assert (pos <= length);
    (h & (Prim.natToWord32(1) << Prim.natToWord32(pos))) != Prim.natToWord32(0)
  };

  /**
  Test if two hashes are equal
  */
  public let hashEq : (Hash, Hash) -> Bool = func(ha, hb) {
    ha == hb
  };

  public let bitsPrintRev : Hash -> () = func(bits) {
    for (j in Iter.range(0, length - 1)) {
      if (getHashBit(bits, j)) {
        Prim.debugPrint "1"
      } else {
        Prim.debugPrint "0"
      }
    }
  };

  public let hashPrintRev : Hash -> () = func(bits) {
    for (j in Iter.revRange(length - 1, 0)) {
      if (getHashBit(bits, Prim.abs(j))) {
        Prim.debugPrint "1"
      } else {
        Prim.debugPrint "0"
      }
    }
  };

  /**
  Jenkin's one at a time:
  https://en.wikipedia.org/wiki/Jenkins_hash_function#one_at_a_time

  The input type should actually be `[Word8]`.
  Note: Be sure to explode each `Word8` of a `Word32` into its own `Word32`, and to shift into lower 8 bits.
  // should this really be public?
  */
  public let hashWord8s : [Hash] -> Hash = func(key) {
    var hash = Prim.natToWord32(0);
    for (wordOfKey in key.vals()) {
      hash := hash + wordOfKey;
      hash := hash + hash << 10;
      hash := hash ^ (hash >> 6);
    };
    hash := hash + hash << 3;
    hash := hash ^ (hash >> 11);
    hash := hash + hash << 15;
    return hash;
  };

}
