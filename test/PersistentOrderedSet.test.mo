// @testmode wasi

import Set "../src/PersistentOrderedSet";
import Array "../src/Array";
import Nat "../src/Nat";
import Iter "../src/Iter";
import Debug "../src/Debug";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let entryTestable = T.natTestable;

class SetMatcher(expected : [Nat]) : M.Matcher<Set.Set<Nat>> {
  public func describeMismatch(actual : Set.Set<Nat>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(natSetOps.vals(actual))) # " should be " # debug_show (expected))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    Iter.toArray(natSetOps.vals(actual)) == expected
  }
};

let natSetOps = Set.SetOps<Nat>(Nat.compare);

func insert(s : Set.Set<Nat>, key : Nat) : Set.Set<Nat>  {
  let updatedTree = natSetOps.put(s, key);
  Set.SetDebug.checkSetInvariants(updatedTree, Nat.compare);
  updatedTree
};

func concatenateKeys(key : Nat, accum : Text) : Text {
  accum # debug_show(key)
};

func containsAll (rbSet : Set.Set<Nat>, elems : [Nat]) {
    for (elem in elems.vals()) {
        assert (natSetOps.contains(rbSet, elem))
    }
};

func clear(initialRbSet : Set.Set<Nat>) : Set.Set<Nat> {
  var rbSet = initialRbSet;
  for (elem in natSetOps.vals(initialRbSet)) {
    let newSet = natSetOps.delete(rbSet, elem);
    rbSet := newSet;
    Set.SetDebug.checkSetInvariants(rbSet, Nat.compare)
  };
  rbSet
};

func add1(x : Nat) : Nat { x + 1 };

func ifElemLessThan(threshold : Nat, f : Nat -> Nat) : Nat -> ?Nat
  = func (x) {
    if(x < threshold)
      ?f(x)
    else null
  };


/* --------------------------------------- */

var buildTestSet = func() : Set.Set<Nat> {
  natSetOps.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        natSetOps.size(buildTestSet()),
        M.equals(T.nat(0))
      ),
      test(
        "vals",
        Iter.toArray(natSetOps.vals(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, []))
      ),
      test(
        "valsRev",
        Iter.toArray(natSetOps.vals(buildTestSet())),
        M.equals  (T.array<Nat>(entryTestable, []))
      ),
      test(
        "empty from iter",
        natSetOps.fromIter(Iter.fromArray([])),
        SetMatcher([])
      ),
      test(
        "contains absent",
        natSetOps.contains(buildTestSet(), 0),
        M.equals(T.bool(false))
      ),
      test(
        "empty right fold",
        natSetOps.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold",
        natSetOps.foldLeft(buildTestSet(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "traverse empty set",
        natSetOps.map(buildTestSet(), add1),
        SetMatcher([])
      ),
      test(
        "empty map filter",
        natSetOps.mapFilter(buildTestSet(), ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "is empty",
        natSetOps.isEmpty(buildTestSet()),
        M.equals(T.bool(true))
      ),
      test(
        "max",
        natSetOps.max(buildTestSet()),
        M.equals(T.optional(entryTestable, null: ?Nat))
      ),
      test(
        "min",
        natSetOps.min(buildTestSet()),
        M.equals(T.optional(entryTestable, null: ?Nat))
      )
    ]
  )
);

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  insert(natSetOps.empty(), 0);
};

var expected = [0];

run(
  suite(
    "single root",
    [
      test(
        "size",
        natSetOps.size(buildTestSet()),
        M.equals(T.nat(1))
      ),
      test(
        "vals",
        Iter.toArray(natSetOps.vals(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "valsRev",
        Iter.toArray(natSetOps.valsRev(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "from iter",
        natSetOps.fromIter(Iter.fromArray(expected)),
        SetMatcher(expected)
      ),
      test(
        "contains",
        natSetOps.contains(buildTestSet(), 0),
        M.equals(T.bool(true))
      ),
      test(
        "delete",
        natSetOps.delete(buildTestSet(), 0),
        SetMatcher([])
      ),
      test(
        "right fold",
        natSetOps.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold",
        natSetOps.foldLeft(buildTestSet(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "traverse set",
        natSetOps.map(buildTestSet(), add1),
        SetMatcher([1])
      ),
      test(
        "map filter/filter all",
        natSetOps.mapFilter(buildTestSet(), ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "map filter/no filer",
        natSetOps.mapFilter(buildTestSet(), ifElemLessThan(1, add1)),
        SetMatcher([1])
      ),
      test(
        "is empty",
        natSetOps.isEmpty(buildTestSet()),
        M.equals(T.bool(false))
      ),
      test(
        "max",
        natSetOps.max(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "min",
        natSetOps.min(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "all",
        natSetOps.all(buildTestSet(), func (k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "some",
        natSetOps.some(buildTestSet(), func (k) = (k == 0)),
        M.equals(T.bool(true))
      ),
    ]
  )
);

/* --------------------------------------- */

expected := [0, 1, 2];

func rebalanceTests(buildTestSet : () -> Set.Set<Nat>) : [Suite.Suite] =
  [
    test(
      "size",
      natSetOps.size(buildTestSet()),
      M.equals(T.nat(3))
    ),
    test(
      "Set match",
      buildTestSet(),
      SetMatcher(expected)
    ),
    test(
      "vals",
      Iter.toArray(natSetOps.vals(buildTestSet())),
      M.equals(T.array<Nat>(entryTestable, expected))
    ),
    test(
      "valsRev",
      Array.reverse(Iter.toArray(natSetOps.valsRev(buildTestSet()))),
      M.equals(T.array<Nat>(entryTestable, expected))
    ),
    test(
      "from iter",
      natSetOps.fromIter(Iter.fromArray(expected)),
      SetMatcher(expected)
    ),
    test(
      "contains all",
      do {
        let rbSet = buildTestSet();
        containsAll(rbSet, [0, 1, 2]);
        rbSet
      },
      SetMatcher(expected)
    ),
    test(
      "clear",
      clear(buildTestSet()),
      SetMatcher([])
    ),
    test(
      "right fold",
      natSetOps.foldRight(buildTestSet(), "", concatenateKeys),
      M.equals(T.text("210"))
    ),
    test(
      "left fold",
      natSetOps.foldLeft(buildTestSet(), "", concatenateKeys),
      M.equals(T.text("012"))
    ),
    test(
      "traverse set",
      natSetOps.map(buildTestSet(), add1),
      SetMatcher([1, 2, 3])
    ),
    test(
      "traverse set/reshape",
      natSetOps.map(buildTestSet(), func (x : Nat) : Nat {5}),
      SetMatcher([5])
    ),
    test(
      "map filter/filter all",
      natSetOps.mapFilter(buildTestSet(), ifElemLessThan(0, add1)),
      SetMatcher([])
    ),
    test(
      "map filter/filter one",
      natSetOps.mapFilter(buildTestSet(), ifElemLessThan(1, add1)),
      SetMatcher([1])
    ),
    test(
      "map filter/no filer",
      natSetOps.mapFilter(buildTestSet(), ifElemLessThan(3, add1)),
      SetMatcher([1, 2, 3])
    ),
    test(
      "is empty",
      natSetOps.isEmpty(buildTestSet()),
      M.equals(T.bool(false))
    ),
    test(
      "max",
      natSetOps.max(buildTestSet()),
      M.equals(T.optional(entryTestable, ?2))
    ),
    test(
      "min",
      natSetOps.min(buildTestSet()),
      M.equals(T.optional(entryTestable, ?0))
    ),
    test(
      "all true",
      natSetOps.all(buildTestSet(), func (k) = (k >= 0)),
      M.equals(T.bool(true))
    ),
    test(
      "all false",
      natSetOps.all(buildTestSet(), func (k) = (k > 0)),
      M.equals(T.bool(false))
    ),
    test(
      "some true",
      natSetOps.some(buildTestSet(), func (k) = (k >= 2)),
      M.equals(T.bool(true))
    ),
    test(
      "some false",
      natSetOps.some(buildTestSet(), func (k) = (k > 2)),
      M.equals(T.bool(false))
    ),
  ];

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 1);
  rbSet := insert(rbSet, 0);
  rbSet
};

run(suite("rebalance left, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet
};

run(suite("rebalance left, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 1);
  rbSet
};

run(suite("rebalance right, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet := insert(rbSet, 2);
  rbSet
};

run(suite("rebalance right, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

run(
  suite(
    "repeated operations",
    [
      test(
        "repeated insert",
        do {
          var rbSet = buildTestSet();
          assert (natSetOps.contains(rbSet, 1));
          rbSet := natSetOps.put(rbSet, 1);
          natSetOps.size(rbSet)
        },
        M.equals(T.nat(3))
      ),
      test(
        "repeated delete",
        do {
          var rbSet = buildTestSet();
          rbSet := natSetOps.delete(rbSet, 1);
          natSetOps.delete(rbSet, 1)
        },
        SetMatcher([0, 2])
      )
    ]
  )
);

/* --------------------------------------- */

let buildTestSet012 = func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet := insert(rbSet, 2);
  rbSet
};

let buildTestSet01 = func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet
};

let buildTestSet234 = func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 3);
  rbSet := insert(rbSet, 4);
  rbSet
};

let buildTestSet345 = func() : Set.Set<Nat> {
  var rbSet = natSetOps.empty();
  rbSet := insert(rbSet, 5);
  rbSet := insert(rbSet, 3);
  rbSet := insert(rbSet, 4);
  rbSet
};

run(
  suite(
    "set operations",
    [
      test(
        "subset/subset of itself",
        natSetOps.isSubset(buildTestSet012(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of itself",
        natSetOps.isSubset(natSetOps.empty(), natSetOps.empty()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of another set",
        natSetOps.isSubset(natSetOps.empty(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/subset",
        natSetOps.isSubset(buildTestSet01(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/not subset",
        natSetOps.isSubset(buildTestSet012(), buildTestSet01()),
        M.equals(T.bool(false))
      ),
      test(
        "equals/empty set",
        natSetOps.equals(natSetOps.empty(), natSetOps.empty()),
        M.equals(T.bool(true))
      ),
      test(
        "equals/equals",
        natSetOps.equals(buildTestSet012(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "equals/not equals",
        natSetOps.equals(buildTestSet012(), buildTestSet01()),
        M.equals(T.bool(false))
      ),
      test(
        "union/empty set",
        natSetOps.union(natSetOps.empty(), natSetOps.empty()),
        SetMatcher([])
      ),
      test(
        "union/union with empty set",
        natSetOps.union(buildTestSet012(), natSetOps.empty()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with itself",
        natSetOps.union(buildTestSet012(), buildTestSet012()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with subset",
        natSetOps.union(buildTestSet012(), buildTestSet01()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union expand",
        natSetOps.union(buildTestSet012(), buildTestSet234()),
        SetMatcher([0, 1, 2, 3, 4])
      ),
      test(
        "intersect/empty set",
        natSetOps.intersect(natSetOps.empty(), natSetOps.empty()),
        SetMatcher([])
      ),
      test(
        "intersect/intersect with empty set",
        natSetOps.intersect(buildTestSet012(), natSetOps.empty()),
        SetMatcher([])
      ),
      test(
        "intersect/intersect with itself",
        natSetOps.intersect(buildTestSet012(), buildTestSet012()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "intersect/intersect with subset",
        natSetOps.intersect(buildTestSet012(), buildTestSet01()),
        SetMatcher([0, 1])
      ),
      test(
        "intersect/intersect",
        natSetOps.intersect(buildTestSet012(), buildTestSet234()),
        SetMatcher([2])
      ),
      test(
        "intersect/no intersection",
        natSetOps.intersect(buildTestSet012(), buildTestSet345()),
        SetMatcher([])
      ),
      test(
        "diff/empty set",
        natSetOps.diff(natSetOps.empty(), natSetOps.empty()),
        SetMatcher([])
      ),
      test(
        "diff/diff with empty set",
        natSetOps.diff(buildTestSet012(), natSetOps.empty()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "diff/diff with empty set 2",
        natSetOps.diff(natSetOps.empty(), buildTestSet012()),
        SetMatcher([])
      ),
      test(
        "diff/diff with subset",
        natSetOps.diff(buildTestSet012(), buildTestSet01()),
        SetMatcher([2])
      ),
      test(
        "diff/diff with subset 2",
        natSetOps.diff(buildTestSet01(), buildTestSet012()),
        SetMatcher([])
      ),
      test(
        "diff/diff",
        natSetOps.diff(buildTestSet012(), buildTestSet234()),
        SetMatcher([0, 1])
      ),
      test(
        "diff/diff no intersection",
        natSetOps.diff(buildTestSet012(), buildTestSet345()),
        SetMatcher([0, 1, 2])
      ),
    ]
  )
);
