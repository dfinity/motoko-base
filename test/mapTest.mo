import { Map } "mo:base/Map";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Order "mo:base/Order";
import Hash "mo:base/Hash";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

// This seems really nice to read
// For mapping primitive types (with corresponding base library modules,
// I think this approach is very nice)
let map1 = Map<Text, Nat>(Text);

// What about mapping from a custom class C to some other type?
module Mod {
  class C() {
    public let x = 4
  };

  // Semantically, these functions shouldn't need to inspect the internal
  // state of the objects, so they don't have to be member methods
  public func compare(c1 : C, c2 : C) : Order.Order {
    Nat.compare(c1.x, c2.x)
  };
  public func hash(c : C) : Hash.Hash {
    Hash.hash(c.x)
  }
};

// Annoying that you have to wrap the utility functions (compare and hash)
// in a module
// But this also seems nice to use
let map2 = Map<C, Nat>(Mod);

// Alternatively, you can create the module here (e.g. if compare and hash are defined
// in separate places)
// But then you get an ugly initialization
let map3 = Map<C, Nat>(module { public let compare = compare; public let hash = hash });

// If modules could be considered subtypes of records, then this is possible
// map4 = Map<C, Nat>({ compare; hash })
// Which is almost as clean as passing in higher order functions separetly
// map5 = Map<C, Nat>(compare, hash);
// but map4 also allows the super clean initialization of mapping primitive types
// while map5 does not e.g. Map<Nat, Nat>(Nat.compare, Nat.hash)

let suite = Suite.suite(
  "Map",
  [
    Suite.test(
      "size empty",
      map1.size(),
      M.equals(T.nat(0))
    )
  ]
);

Suite.run(suite)
