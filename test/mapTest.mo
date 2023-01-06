import { Map } "mo:base/Map";
import Nat "mo:base/Nat";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let map = Map<Nat, Text>(Nat);

let suite = Suite.suite(
  "Map",
  [
    Suite.test(
      "size empty",
      map.size(),
      M.equals(T.nat(0))
    )
  ]
);

Suite.run(suite)
