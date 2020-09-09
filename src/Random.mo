

module Rand {
  let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public func byte() : async Nat8 { 
    let bytes = await raw_rand();
    return 7
  };


  public func coin() : async Bool { 
    let bytes = await raw_rand();
    return false
  };


  public func range(from : Nat, to : Nat) : async Nat { 
    let bytes = await raw_rand();
    return 9
  }
}
