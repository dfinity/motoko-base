import Prim "mo:prim";
import P "Prelude"

module Random {

  /// Drawing from a finite supply of entropy `Finite` provides
  /// methods to obtain random values. When the entropy is used up,
  /// `null` is returned. Otherwise the outcomes' distributions are
  /// stated for each method.
  public class Finite(entropy : Blob) {
    let it : { next : () -> ?Word8 } = entropy.bytes();

    /// Evenly distributes outcomes in the numeric range [0 .. 255].
    public func byte() : ?Nat8 {
      switch (it.next()) {
        case (?w) ?Prim.word8ToNat8 w;
        case null null
      }
    };

    /// Simulates a coin toss. Both outcomes have equal probability.
    public func coin() : ?Bool {
      switch (it.next()) {
        case (?w) ?(127 : Word8 < w);
        case null null
      }
    };

    /// Uniformly distributes outcomes in the numeric range [0 .. 2^n - 1].
    public func range(p : Nat8) : ?Nat {
      var pp = p;
      var acc : Nat = 0;
      for (i in it) {
        if (8 : Nat8 <= pp)
        { acc := acc * 256 + Prim.word8ToNat(i) }
        else if (0 : Nat8 == pp)
        { return ?acc }
        else {
          acc *= Prim.word8ToNat(1 << Prim.nat8ToWord8 pp);
          let mask : Word8 = -1 >> Prim.nat8ToWord8(8 - pp);
          return ?(acc + Prim.word8ToNat(i & mask))
        };
        pp -= 8
      };
      null
    };

    /// Counts the number of heads in `n` fair coin tosses.
    public func binomialNat8(n : Nat8) : ?Nat8 {
      var nn = n;
      var acc : Word8 = 0;
      for (i in it) {
        if (8 : Nat8 <= nn)
        { acc += Prim.popcntWord8(i) }
        else if (0 : Nat8 == nn)
        { return ?Prim.word8ToNat8 acc }
        else {
          let mask : Word8 = -1 << Prim.nat8ToWord8(8 - nn);
          let residue = Prim.popcntWord8(i & mask);
          return ?Prim.word8ToNat8(acc + residue)
        };
        nn -= 8
      };
      null
    }
  };

  let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  /// Simulates a coin toss. Both outcomes have equal probability.
  public func coin() : async Bool {
    let bytes = await raw_rand();
    let it = bytes.bytes();
    switch (it.next()) {
      case (?w) w > (127 : Word8);
      case _ P.unreachable();
    }
  };

  /// Obtains a full blob (32 bytes) worth of fresh entropy.
  public let blob : shared () -> async Blob = raw_rand;

  /// Uniformly distributes outcomes in the numeric range [0 .. 2^n - 1].
  public func range(p : Nat8) : async Nat {
    let bytes = await raw_rand();
    var pp = p;
    var acc : Nat = 0;
    label l for (i in bytes.bytes()) {
      if (8 : Nat8 <= pp)
      { acc := acc * 256 + Prim.word8ToNat(i) }
      else if (0 : Nat8 == pp)
      { break l }
      else {
        acc *= Prim.word8ToNat(1 << Prim.nat8ToWord8 pp);
        let mask : Word8 = -1 >> Prim.nat8ToWord8(8 - pp);
        return acc + Prim.word8ToNat(i & mask)
      };
      pp -= 8
    };
    acc
  };

  /// Counts the number of heads in `n` fair coin tosses.
  public func binomialNat8(n : Nat8) : async Nat8 {
    let bytes = await raw_rand();
    var nn = n;
    var acc : Word8 = 0;
    label l for (i in bytes.bytes()) {
      if (8 : Nat8 <= nn)
      { acc += Prim.popcntWord8(i) }
      else if (0 : Nat8 == nn)
      { break l }
      else {
        let mask : Word8 = -1 << Prim.nat8ToWord8(8 - nn);
        let residue = Prim.popcntWord8(i & mask);
        return Prim.word8ToNat8(acc + residue)
      };
      nn -= 8
    };
    Prim.word8ToNat8 acc
  }

  // TODO State also how much entropy is consumed (in docs).
  // TODO ADD EXAMPLE!
  // TODO Cyclic class
  // Bool iterator (derived) for coin flips
  // explain that all bets must be closed before asking for entropy (in the same round?).
}
