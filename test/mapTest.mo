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
  public class C() {
    public let x = 4
  };
  public func compare(c1 : C, c2 : C) : Order.Order {
    Nat.compare(c1.x, c2.x)
  };
  public func hash(c : C) : Hash.Hash {
    Hash.hash(c.x)
  }
};

let map2 = Map<Mod.C, Nat>(Mod);

class D() {
  public let x = 4
};

func compare2(d1 : D, d2 : D) : Order.Order {
  Nat.compare(d1.x, d2.x)
};
func hash2(d : D) : Hash.Hash {
  Hash.hash(d.x)
};

let map3 = Map<D, Nat>(
  module {
    public let compare : (D, D) -> Order.Order = compare2;
    public let hash : D -> Hash.Hash = hash2
  }
);
// map4 = Map<Mod.C, Nat>({ compare; hash })
// map5 = Map<Mod.C, Nat>(compare, hash);

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
