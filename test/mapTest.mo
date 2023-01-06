import { Map } "mo:base/Map";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Order "mo:base/Order";
import Hash "mo:base/Hash";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let map1 = Map<Text, Nat>(Text);

module Mod {
  class C() {
    public let x = 4
  };

  public func compare(c1 : C, c2 : C) : Order.Order {
    Nat.compare(c1.x, c2.x)
  };
  public func hash(c : C) : Hash.Hash {
    Hash.hash(c.x)
  }
};

let map2 = Map<C, Nat>(Mod);
let map3 = Map<C, Nat>(module { public let compare = compare; public let hash = hash });
// map4 = Map<C, Nat>({ compare; hash })
// map5 = Map<C, Nat>(compare, hash);

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
