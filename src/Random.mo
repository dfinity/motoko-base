import Prim "mo:prim";
import P "Prelude"

module Rand {
  let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;
  let it : [var {next : () -> ?Word8}] = [var { next = func () : ?Word8 = null }];

  /// Evenly distributes outcomes in the numeric range [0 .. 255].
  public func byte() : async Nat8 { 
    let bytes = await raw_rand();
    it[0] := bytes.bytes();

    switch (it[0].next()) {
      case (?w) Prim.word8ToNat8 w;
      case _ P.unreachable();
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

  /// Evenly distributes outcomes in the numeric range [from .. to].
  public func range(from : Nat, to : Nat) : async Nat { 
    let bytes = await raw_rand();
    return 9
  }

  // TODO Gaussian? n-times coin toss, use popCount
  // TODO Buffering entropy?
  // TODO State also how much entropy is consumed.
  // TODO ADD EXAMPLE!
}
