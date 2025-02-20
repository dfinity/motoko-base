import AssocList "../src/AssocList";
import List "../src/List";
import Nat "../src/Nat";
import Debug "../src/Debug";
import Iter "../src/Iter";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

type AssocList = AssocList.AssocList<Nat, Nat>;

// Utility functions for testing
func assocListTest(array : [(Nat, Nat)]) : M.Matcher<AssocList> {
    let map = List.fromArray(array);
    let testableItem : T.TestableItem<AssocList> = {
        display = func l { debug_show l };
        equals = func(l1, l2) {
            List.equal<(Nat, Nat)>(l1, l2, func(p1, p2) = p1.0 == p2.0 and p1.1 == p2.1)
        };
        item = map
    };

    M.equals<AssocList>(testableItem)
};
func natOptAdd(v1 : ?Nat, v2 : ?Nat) : Nat {
    switch (v1, v2) {
        case (?v1, ?v2) v1 + v2;
        case (?v1, null) v1;
        case (null, ?v2) v2;
        case (null, null) Debug.trap "Unreachable in assocListTest"
    }
};

// Sample association lists for testing
let map1 = List.fromArray([(0, 10), (2, 12), (4, 14)]);
let map2 = List.fromArray([(1, 11), (2, 12)]);
let map3 = List.fromArray([(1, 11), (3, 13), (5, 15)]);

let suite = Suite.suite(
    "AssocList",
    [
        Suite.test(
            "find",
            AssocList.find(map1, 0, Nat.equal),
            M.equals(T.optional(T.natTestable, ?10 : ?Nat))
        ),
        Suite.test(
            "find empty",
            AssocList.find(List.nil(), 0, Nat.equal),
            M.equals(T.optional(T.natTestable, null : ?Nat))
        ),
        Suite.test(
            "replace",
            AssocList.replace(map1, 4, Nat.equal, ?24).0,
            assocListTest([(4, 24), (0, 10), (2, 12) ])
        ),
        Suite.test(
            "replace empty",
            AssocList.replace(List.nil(), 4, Nat.equal, ?24).0,
            assocListTest([(4, 24)])
        ),
        Suite.test(
            "replace new entry",
            AssocList.replace(map1, 1, Nat.equal, ?11).0,
            assocListTest([(1, 11), (0, 10), (2, 12), (4, 14)])
        ),
        Suite.test(
            "diff no overlap",
            AssocList.diff(map1, map3, Nat.equal),
            assocListTest([(0, 10), (2, 12), (4, 14)])
        ),
        Suite.test(
            "diff empty first",
            AssocList.diff(List.nil(), map3, Nat.equal),
            assocListTest([])
        ),
        Suite.test(
            "diff empty second",
            AssocList.diff(map1, List.nil(), Nat.equal),
            assocListTest([(0, 10), (2, 12), (4, 14)])
        ),
        Suite.test(
            "diff both empty",
            AssocList.diff(List.nil(), List.nil(), Nat.equal),
            assocListTest([])
        ),
        Suite.test(
            "mapAppend",
            AssocList.mapAppend<Nat, Nat, Nat, Nat>(
                map1,
                map2,
                natOptAdd
            ),
            assocListTest([(0, 10), (2, 12), (4, 14), (1, 11), (2, 12)])
        ),
        Suite.test(
            "mapAppend no overlap",
            AssocList.mapAppend<Nat, Nat, Nat, Nat>(
                map1,
                map3,
                natOptAdd
            ),
            assocListTest([(0, 10), (2, 12), (4, 14), (1, 11), (3, 13), (5, 15)])
        ),
        Suite.test(
            "mapAppend first empty",
            AssocList.mapAppend<Nat, Nat, Nat, Nat>(
                List.nil(),
                map3,
                natOptAdd
            ),
            assocListTest([(1, 11), (3, 13), (5, 15)])
        ),
        Suite.test(
            "mapAppend second empty",
            AssocList.mapAppend<Nat, Nat, Nat, Nat>(
                map3,
                List.nil(),
                natOptAdd
            ),
            assocListTest([(1, 11), (3, 13), (5, 15)])
        ),
        Suite.test(
            "mapAppend both empty",
            AssocList.mapAppend<Nat, Nat, Nat, Nat>(
                List.nil(),
                List.nil(),
                natOptAdd
            ),
            assocListTest([])
        ),
        // FIXME disjDisjoint is equivalent to mapAppend
        Suite.test(
            "disj",
            AssocList.disj<Nat, Nat, Nat, Nat>(
                map1,
                map2,
                Nat.equal,
                natOptAdd
            ),
            assocListTest([(0, 10), (4, 14), (1, 11), (2, 24)])
        ),
        Suite.test(
            "disj no overlap",
            AssocList.disj<Nat, Nat, Nat, Nat>(
                map1,
                map3,
                Nat.equal,
                natOptAdd
            ),
            assocListTest([(0, 10), (2, 12), (4, 14), (1, 11), (3, 13), (5, 15)])
        ),
        Suite.test(
            "disj first empty",
            AssocList.disj<Nat, Nat, Nat, Nat>(
                List.nil(),
                map3,
                Nat.equal,
                natOptAdd
            ),
            assocListTest([(1, 11), (3, 13), (5, 15)])
        ),
        Suite.test(
            "disj second empty",
            AssocList.disj<Nat, Nat, Nat, Nat>(
                map1,
                List.nil(),
                Nat.equal,
                natOptAdd
            ),
            assocListTest([(0, 10), (2, 12), (4, 14)])
        ),
        Suite.test(
            "disj both empty",
            AssocList.disj<Nat, Nat, Nat, Nat>(
                List.nil(),
                List.nil(),
                Nat.equal,
                natOptAdd
            ),
            assocListTest([])
        ),
        Suite.test(
            "join",
            AssocList.join<Nat, Nat, Nat, Nat>(
                map1,
                map2,
                Nat.equal,
                Nat.add
            ),
            assocListTest([(2, 24)])
        ),
        Suite.test(
            "join no overlap",
            AssocList.join<Nat, Nat, Nat, Nat>(
                map1,
                map3,
                Nat.equal,
                Nat.add
            ),
            assocListTest([])
        ),
        Suite.test(
            "join first empty",
            AssocList.join<Nat, Nat, Nat, Nat>(
                List.nil(),
                map3,
                Nat.equal,
                Nat.add
            ),
            assocListTest([])
        ),
        Suite.test(
            "join second empty",
            AssocList.join<Nat, Nat, Nat, Nat>(
                map1,
                List.nil(),
                Nat.equal,
                Nat.add
            ),
            assocListTest([])
        ),
        Suite.test(
            "join both empty",
            AssocList.join<Nat, Nat, Nat, Nat>(
                List.nil(),
                List.nil(),
                Nat.equal,
                Nat.add
            ),
            assocListTest([])
        ),
        Suite.test(
            "fold",
            AssocList.fold<Nat, Nat, Nat>(
                map1,
                0,
                func(k, v, acc) = k * v + acc
            ),
            M.equals(T.nat((0 * 10) + (2 * 12) + (4 * 14)))
        ),
        Suite.test(
            "fold empty",
            AssocList.fold<Nat, Nat, Nat>(
                List.nil(),
                0,
                func(k, v, acc) = k * v + acc
            ),
            M.equals(T.nat(0))
        ),
        Suite.test(
            "keys",
            Iter.toArray(AssocList.keys(map1)),
            M.equals(T.array<Nat>(T.natTestable, [0, 2, 4]))
        ),
        Suite.test(
            "vals",
            Iter.toArray(AssocList.vals(map1)),
            M.equals(T.array<Nat>(T.natTestable, [10, 12, 14]))
        )
    ]
);

// FIXME formatter enforcing 4 space indentation
Suite.run(suite)
