// @testmode wasi

import Set "../src/OrderedSet";
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
    Debug.print(debug_show (Iter.toArray(natSet.vals(actual))) # " should be " # debug_show (expected))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    Iter.toArray(natSet.vals(actual)) == expected
  }
};

let natSet = Set.Make<Nat>(Nat.compare);

func insert(s : Set.Set<Nat>, key : Nat) : Set.Set<Nat>  {
  let updatedTree = natSet.put(s, key);
  Set.SetDebug.checkSetInvariants(updatedTree, Nat.compare);
  updatedTree
};

func concatenateKeys(key : Nat, accum : Text) : Text {
  accum # debug_show(key)
};

func containsAll (rbSet : Set.Set<Nat>, elems : [Nat]) {
    for (elem in elems.vals()) {
        assert (natSet.contains(rbSet, elem))
    }
};

func clear(initialRbSet : Set.Set<Nat>) : Set.Set<Nat> {
  var rbSet = initialRbSet;
  for (elem in natSet.vals(initialRbSet)) {
    let newSet = natSet.delete(rbSet, elem);
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
  natSet.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        natSet.size(buildTestSet()),
        M.equals(T.nat(0))
      ),
      test(
        "vals",
        Iter.toArray(natSet.vals(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, []))
      ),
      test(
        "valsRev",
        Iter.toArray(natSet.vals(buildTestSet())),
        M.equals  (T.array<Nat>(entryTestable, []))
      ),
      test(
        "empty from iter",
        natSet.fromIter(Iter.fromArray([])),
        SetMatcher([])
      ),
      test(
        "contains absent",
        natSet.contains(buildTestSet(), 0),
        M.equals(T.bool(false))
      ),
      test(
        "empty right fold",
        natSet.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold",
        natSet.foldLeft(buildTestSet(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "traverse empty set",
        natSet.map(buildTestSet(), add1),
        SetMatcher([])
      ),
      test(
        "empty map filter",
        natSet.mapFilter(buildTestSet(), ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "is empty",
        natSet.isEmpty(buildTestSet()),
        M.equals(T.bool(true))
      ),
      test(
        "max",
        natSet.max(buildTestSet()),
        M.equals(T.optional(entryTestable, null: ?Nat))
      ),
      test(
        "min",
        natSet.min(buildTestSet()),
        M.equals(T.optional(entryTestable, null: ?Nat))
      )
    ]
  )
);

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  insert(natSet.empty(), 0);
};

var expected = [0];

run(
  suite(
    "single root",
    [
      test(
        "size",
        natSet.size(buildTestSet()),
        M.equals(T.nat(1))
      ),
      test(
        "vals",
        Iter.toArray(natSet.vals(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "valsRev",
        Iter.toArray(natSet.valsRev(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "from iter",
        natSet.fromIter(Iter.fromArray(expected)),
        SetMatcher(expected)
      ),
      test(
        "contains",
        natSet.contains(buildTestSet(), 0),
        M.equals(T.bool(true))
      ),
      test(
        "delete",
        natSet.delete(buildTestSet(), 0),
        SetMatcher([])
      ),
      test(
        "right fold",
        natSet.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold",
        natSet.foldLeft(buildTestSet(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "traverse set",
        natSet.map(buildTestSet(), add1),
        SetMatcher([1])
      ),
      test(
        "map filter/filter all",
        natSet.mapFilter(buildTestSet(), ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "map filter/no filer",
        natSet.mapFilter(buildTestSet(), ifElemLessThan(1, add1)),
        SetMatcher([1])
      ),
      test(
        "is empty",
        natSet.isEmpty(buildTestSet()),
        M.equals(T.bool(false))
      ),
      test(
        "max",
        natSet.max(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "min",
        natSet.min(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "all",
        natSet.all(buildTestSet(), func (k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "some",
        natSet.some(buildTestSet(), func (k) = (k == 0)),
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
      natSet.size(buildTestSet()),
      M.equals(T.nat(3))
    ),
    test(
      "Set match",
      buildTestSet(),
      SetMatcher(expected)
    ),
    test(
      "vals",
      Iter.toArray(natSet.vals(buildTestSet())),
      M.equals(T.array<Nat>(entryTestable, expected))
    ),
    test(
      "valsRev",
      Array.reverse(Iter.toArray(natSet.valsRev(buildTestSet()))),
      M.equals(T.array<Nat>(entryTestable, expected))
    ),
    test(
      "from iter",
      natSet.fromIter(Iter.fromArray(expected)),
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
      natSet.foldRight(buildTestSet(), "", concatenateKeys),
      M.equals(T.text("210"))
    ),
    test(
      "left fold",
      natSet.foldLeft(buildTestSet(), "", concatenateKeys),
      M.equals(T.text("012"))
    ),
    test(
      "traverse set",
      natSet.map(buildTestSet(), add1),
      SetMatcher([1, 2, 3])
    ),
    test(
      "traverse set/reshape",
      natSet.map(buildTestSet(), func (x : Nat) : Nat {5}),
      SetMatcher([5])
    ),
    test(
      "map filter/filter all",
      natSet.mapFilter(buildTestSet(), ifElemLessThan(0, add1)),
      SetMatcher([])
    ),
    test(
      "map filter/filter one",
      natSet.mapFilter(buildTestSet(), ifElemLessThan(1, add1)),
      SetMatcher([1])
    ),
    test(
      "map filter/no filer",
      natSet.mapFilter(buildTestSet(), ifElemLessThan(3, add1)),
      SetMatcher([1, 2, 3])
    ),
    test(
      "is empty",
      natSet.isEmpty(buildTestSet()),
      M.equals(T.bool(false))
    ),
    test(
      "max",
      natSet.max(buildTestSet()),
      M.equals(T.optional(entryTestable, ?2))
    ),
    test(
      "min",
      natSet.min(buildTestSet()),
      M.equals(T.optional(entryTestable, ?0))
    ),
    test(
      "all true",
      natSet.all(buildTestSet(), func (k) = (k >= 0)),
      M.equals(T.bool(true))
    ),
    test(
      "all false",
      natSet.all(buildTestSet(), func (k) = (k > 0)),
      M.equals(T.bool(false))
    ),
    test(
      "some true",
      natSet.some(buildTestSet(), func (k) = (k >= 2)),
      M.equals(T.bool(true))
    ),
    test(
      "some false",
      natSet.some(buildTestSet(), func (k) = (k > 2)),
      M.equals(T.bool(false))
    ),
  ];

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 1);
  rbSet := insert(rbSet, 0);
  rbSet
};

run(suite("rebalance left, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet
};

run(suite("rebalance left, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 1);
  rbSet
};

run(suite("rebalance right, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
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
          assert (natSet.contains(rbSet, 1));
          rbSet := natSet.put(rbSet, 1);
          natSet.size(rbSet)
        },
        M.equals(T.nat(3))
      ),
      test(
        "repeated delete",
        do {
          var rbSet = buildTestSet();
          rbSet := natSet.delete(rbSet, 1);
          natSet.delete(rbSet, 1)
        },
        SetMatcher([0, 2])
      )
    ]
  )
);

/* --------------------------------------- */

let buildTestSet012 = func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet := insert(rbSet, 2);
  rbSet
};

let buildTestSet01 = func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet
};

let buildTestSet234 = func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 3);
  rbSet := insert(rbSet, 4);
  rbSet
};

let buildTestSet345 = func() : Set.Set<Nat> {
  var rbSet = natSet.empty();
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
        natSet.isSubset(buildTestSet012(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of itself",
        natSet.isSubset(natSet.empty(), natSet.empty()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of another set",
        natSet.isSubset(natSet.empty(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/subset",
        natSet.isSubset(buildTestSet01(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/not subset",
        natSet.isSubset(buildTestSet012(), buildTestSet01()),
        M.equals(T.bool(false))
      ),
      test(
        "equals/empty set",
        natSet.equals(natSet.empty(), natSet.empty()),
        M.equals(T.bool(true))
      ),
      test(
        "equals/equals",
        natSet.equals(buildTestSet012(), buildTestSet012()),
        M.equals(T.bool(true))
      ),
      test(
        "equals/not equals",
        natSet.equals(buildTestSet012(), buildTestSet01()),
        M.equals(T.bool(false))
      ),
      test(
        "union/empty set",
        natSet.union(natSet.empty(), natSet.empty()),
        SetMatcher([])
      ),
      test(
        "union/union with empty set",
        natSet.union(buildTestSet012(), natSet.empty()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with itself",
        natSet.union(buildTestSet012(), buildTestSet012()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with subset",
        natSet.union(buildTestSet012(), buildTestSet01()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union expand",
        natSet.union(buildTestSet012(), buildTestSet234()),
        SetMatcher([0, 1, 2, 3, 4])
      ),
      test(
        "intersect/empty set",
        natSet.intersect(natSet.empty(), natSet.empty()),
        SetMatcher([])
      ),
      test(
        "intersect/intersect with empty set",
        natSet.intersect(buildTestSet012(), natSet.empty()),
        SetMatcher([])
      ),
      test(
        "intersect/intersect with itself",
        natSet.intersect(buildTestSet012(), buildTestSet012()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "intersect/intersect with subset",
        natSet.intersect(buildTestSet012(), buildTestSet01()),
        SetMatcher([0, 1])
      ),
      test(
        "intersect/intersect",
        natSet.intersect(buildTestSet012(), buildTestSet234()),
        SetMatcher([2])
      ),
      test(
        "intersect/no intersection",
        natSet.intersect(buildTestSet012(), buildTestSet345()),
        SetMatcher([])
      ),
      test(
        "diff/empty set",
        natSet.diff(natSet.empty(), natSet.empty()),
        SetMatcher([])
      ),
      test(
        "diff/diff with empty set",
        natSet.diff(buildTestSet012(), natSet.empty()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "diff/diff with empty set 2",
        natSet.diff(natSet.empty(), buildTestSet012()),
        SetMatcher([])
      ),
      test(
        "diff/diff with subset",
        natSet.diff(buildTestSet012(), buildTestSet01()),
        SetMatcher([2])
      ),
      test(
        "diff/diff with subset 2",
        natSet.diff(buildTestSet01(), buildTestSet012()),
        SetMatcher([])
      ),
      test(
        "diff/diff",
        natSet.diff(buildTestSet012(), buildTestSet234()),
        SetMatcher([0, 1])
      ),
      test(
        "diff/diff no intersection",
        natSet.diff(buildTestSet012(), buildTestSet345()),
        SetMatcher([0, 1, 2])
      ),
    ]
  )
);
