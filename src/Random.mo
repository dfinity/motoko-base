/// A module for obtaining randomness on the Internet Computer (IC).
///
/// This module provides the fundamentals for user abstractions to build on.
///
/// Dealing with randomness on a deterministic computing platform, such
/// as the IC, is intricate. Some basic rules need to be followed by the
/// user of this module to obtain (and maintain) the benefits of crypto-
/// graphic randomness:
///
/// - cryptographic entropy (randomness source) is only obtainable
///   asyncronously in discrete chunks of 256 bits (32-byte sized `Blob`s)
/// - all bets must be closed *before* entropy is being asked for in
///   order to decide them
/// - this implies that the same entropy (i.e. `Blob`) - or surplus entropy
///   not utilised yet - cannot be used for a new round of bets without
///   losing the cryptographic guarantees.
///
/// Concretely, the below class `Finite`, as well as the
/// `*From` methods risk the carrying-over of state from previous rounds.
/// These are provided for performance (and convenience) reasons, and need
/// special care when used. Similar caveats apply for user-defined (pseudo)
/// random number generators.
///
/// Usage:
/// ```motoko no-repl
/// import Random "mo:base/Random";
/// ```

import I "Iter";
import Option "Option";
import Prim "mo:⛔";

module {

  let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  /// Obtains a full blob (32 bytes) worth of fresh entropy.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let random = Random.Finite(await Random.blob());
  /// ```
  public let blob : shared () -> async Blob = raw_rand;

  /// Drawing from a finite supply of entropy, `Finite` provides
  /// methods to obtain random values. When the entropy is used up,
  /// `null` is returned. Otherwise the outcomes' distributions are
  /// stated for each method. The uniformity of outcomes is
  /// guaranteed only when the supplied entropy is originally obtained
  /// by the `blob()` call, and is never reused.
  ///
  /// Example:
  /// ```motoko no-repl
  /// import Random "mo:base/Random";
  ///
  /// let random = Random.Finite(await Random.blob());
  ///
  /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
  /// let seedRandom = Random.Finite(seed);
  /// ```
  public class Finite(entropy : Blob) {
    let it : I.Iter<Nat8> = entropy.vals();

    /// Uniformly distributes outcomes in the numeric range [0 .. 255].
    /// Consumes 1 byte of entropy.
    ///
    /// Example:
    /// ```motoko no-repl
    /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
    /// let random = Random.Finite(seed);
    /// random.byte() // => ?20
    /// ```
    public func byte() : ?Nat8 {
      it.next()
    };

    /// Bool iterator splitting up a byte of entropy into 8 bits
    let bit : I.Iter<Bool> = object {
      var mask = 0x00 : Nat8;
      var byte = 0x00 : Nat8;
      public func next() : ?Bool {
        if (0 : Nat8 == mask) {
          switch (it.next()) {
            case null { null };
            case (?w) {
              byte := w;
              mask := 0x40;
              ?(0 : Nat8 != byte & (0x80 : Nat8))
            }
          }
        } else {
          let m = mask;
          mask >>= (1 : Nat8);
          ?(0 : Nat8 != byte & m)
        }
      }
    };

    /// Simulates a coin toss. Both outcomes have equal probability.
    /// Consumes 1 bit of entropy (amortised).
    ///
    /// Example:
    /// ```motoko no-repl
    /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
    /// let random = Random.Finite(seed);
    /// random.coin() // => ?false
    /// ```
    public func coin() : ?Bool {
      bit.next()
    };

    /// Uniformly distributes outcomes in the numeric range [0 .. 2^p - 1].
    /// Consumes ⌈p/8⌉ bytes of entropy.
    ///
    /// Example:
    /// ```motoko no-repl
    /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
    /// let random = Random.Finite(seed);
    /// random.range(32) // => ?348746249
    /// ```
    public func range(p : Nat8) : ?Nat {
      var pp = p;
      var acc : Nat = 0;
      for (i in it) {
        if (8 : Nat8 <= pp) {
          acc := acc * 256 + Prim.nat8ToNat(i)
        }
        else if (0 : Nat8 == pp) {
          return ?acc
        } else {
          acc *= Prim.nat8ToNat(1 << pp);
          let mask : Nat8 = 0xff >> (8 - pp);
          return ?(acc + Prim.nat8ToNat(i & mask))
        };
        pp -= 8
      };
      if (0 : Nat8 == pp)
        ?acc
      else null
    };

    /// Counts the number of heads in `n` fair coin tosses.
    /// Consumes ⌈n/8⌉ bytes of entropy.
    ///
    /// Example:
    /// ```motoko no-repl
    /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
    /// let random = Random.Finite(seed);
    /// random.binomial(5) // => ?1
    /// ```
    public func binomial(n : Nat8) : ?Nat8 {
      var nn = n;
      var acc : Nat8 = 0;
      for (i in it) {
        if (8 : Nat8 <= nn) {
          acc +%= Prim.popcntNat8(i)
        } else if (0 : Nat8 == nn) {
          return ?acc
        } else {
          let mask : Nat8 = 0xff << (8 - nn);
          let residue = Prim.popcntNat8(i & mask);
          return ?(acc +% residue)
        };
        nn -= 8
      };
      if (0 : Nat8 == nn)
        ?acc
      else null
    }
  };

  /// Distributes outcomes in the numeric range [0 .. 255].
  /// Seed blob must contain at least a byte.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
  /// Random.byteFrom(seed) // => 20
  /// ```
  public func byteFrom(seed : Blob) : Nat8 {
    switch (seed.vals().next()) {
      case (?w) { w };
      case _ { Prim.trap "Random.byteFrom" }
    }
  };

  /// Simulates a coin toss.
  /// Seed blob must contain at least a byte.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
  /// Random.coinFrom(seed) // => false
  /// ```
  public func coinFrom(seed : Blob) : Bool {
    switch (seed.vals().next()) {
      case (?w) { w > (127 : Nat8) };
      case _ { Prim.trap "Random.coinFrom" }
    }
  };

  /// Distributes outcomes in the numeric range [0 .. 2^p - 1].
  /// Seed blob must contain at least ((p+7) / 8) bytes.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
  /// Random.rangeFrom(32, seed) // => 348746249
  /// ```
  public func rangeFrom(p : Nat8, seed : Blob) : Nat {
    rangeIter(p, seed.vals())
  };

  // internal worker method, expects iterator with sufficient supply
  func rangeIter(p : Nat8, it : I.Iter<Nat8>) : Nat {
    var pp = p;
    var acc : Nat = 0;
    for (i in it) {
      if (8 : Nat8 <= pp) {
        acc := acc * 256 + Prim.nat8ToNat(i)
      } else if (0 : Nat8 == pp) {
        return acc
      } else {
        acc *= Prim.nat8ToNat(1 << pp);
        let mask : Nat8 = 0xff >> (8 - pp);
        return acc + Prim.nat8ToNat(i & mask)
      };
      pp -= 8
    };
    if (0 : Nat8 == pp) {
      return acc
    }
    else Prim.trap("Random.rangeFrom")
  };

  /// Counts the number of heads in `n` coin tosses.
  /// Seed blob must contain at least ((n+7) / 8) bytes.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
  /// Random.binomialFrom(5, seed) // => 1
  /// ```
  public func binomialFrom(n : Nat8, seed : Blob) : Nat8 {
    binomialIter(n, seed.vals())
  };

  // internal worker method, expects iterator with sufficient supply
  func binomialIter(n : Nat8, it : I.Iter<Nat8>) : Nat8 {
    var nn = n;
    var acc : Nat8 = 0;
    for (i in it) {
      if (8 : Nat8 <= nn) {
        acc +%= Prim.popcntNat8(i)
      } else if (0 : Nat8 == nn) {
        return acc
      } else {
        let mask : Nat8 = 0xff << (8 - nn);
        let residue = Prim.popcntNat8(i & mask);
        return (acc +% residue)
      };
      nn -= 8
    };
    if (0 : Nat8 == nn) {
      return acc
    }
    else Prim.trap("Random.binomialFrom")
  }

}
