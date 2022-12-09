import AssocList "mo:base/AssocList";
import Nat "mo:base/Nat";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let suite = Suite.suite(
    "AssocList",
    [
        Suite.test(
            "find",
            AssocList.find(null, 0, Nat.equal),
            M.equals(T.optional(T.natTestable, null : ?Nat)),
        ),
    ],
);

Suite.run(suite);
