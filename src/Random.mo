import Prim "mo:prim";
import P "Prelude"

module Random {
  let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;
  let it : [var {next : () -> ?Word8}] = [var { next = func () : ?Word8 = null }];

  /// Evenly distributes outcomes in the numeric range [0 .. 255].
  public func byte() : async Nat8 {
    switch (it[0].next()) {
      case (?w) Prim.word8ToNat8 w;
      case null {
        let bytes = await raw_rand();
        it[0] := bytes.bytes();
        switch (it[0].next()) {
          case null { P.unreachable() };
          case (?w) Prim.word8ToNat8 w
        }
      }
    }
  };

  /// Simulates a coin toss. Both outcomes have equal probability.
  public func coin() : async Bool {
    let bytes = await raw_rand();
    let it = bytes.bytes();
    switch (it.next()) {
      case (?w) w > (127 : Word8);
      case _ P.unreachable();
    }
  };

  /// Uniformly distributes outcomes in the numeric range [0 .. 2^n - 1].
  public func range(p : Nat8) : async Nat {
    let bytes = await raw_rand();
    return 9 // FIXME
  };

  /// Obtains a full blob (32 bytes) worth of entropy.
  public func blob() : async Blob {
    let bytes = await raw_rand();
    return bytes
  };

  public func binomialNat8(n : Nat8) : async Nat8 {
    let bytes = await raw_rand();
    var nn = n;
    var result : Word8 = 0;
    for (i in bytes.bytes()) {
        result += if (nn >= (8 : Nat8))
        { Prim.popcntWord8(i) }
        else { Prim.popcntWord8(i & (-1 << Prim.nat8ToWord8 (8 - nn))) };
        nn -= 8;
    };
    Prim.word8ToNat8 result
  }

  // TODO Buffering entropy?
  // TODO State also how much entropy is consumed (in docs).
  // TODO ADD EXAMPLE!
}
