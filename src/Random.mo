// TODO ADD EXAMPLE!

module Rand {
  let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  /// Evenly distributes outcomes in the numeric range [0 .. 255].
  public func byte() : async Nat8 { 
    let bytes = await raw_rand();
    return 7
  };

  /// Simulates a coin toss. Both outcomes have equal probability.
  public func coin() : async Bool { 
    let bytes = await raw_rand();
    return false
  };

  /// Evenly distributes outcomes in the numeric range [from .. to].
  public func range(from : Nat, to : Nat) : async Nat { 
    let bytes = await raw_rand();
    return 9
  }

  // TODO Gaussian?
  // TODO Buffering entropy?
}
