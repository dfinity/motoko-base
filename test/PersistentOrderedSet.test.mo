// @testmode wasi

import Set "../src/PersistentOrderedSet";
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
    Debug.print(debug_show (Iter.toArray(Set.elements(actual))) # " should be " # debug_show (expected))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    Iter.toArray(Set.elements(actual)) == expected
  }
};

let natSetOps = Set.SetOps<Nat>(Nat.compare);

func checkSet(rbSet : Set.Set<Nat>) {
  ignore blackDepth(rbSet)
};

func blackDepth(node : Set.Set<Nat>) : Nat {
  switch node {
    case (#leaf) 0;
    case (#node(color, left, (key, _), right)) {
      checkKey(left, func(x) { x < key });
      checkKey(right, func(x) { x > key });
      let leftBlacks = blackDepth(left);
      let rightBlacks = blackDepth(right);
      assert (leftBlacks == rightBlacks);
      switch color {
        case (#R) {
          assert (not isRed(left));
          assert (not isRed(right));
          leftBlacks
        };
        case (#B) {
          leftBlacks + 1
        }
      }
    }
  }
};


func isRed(node : Set.Set<Nat>) : Bool {
  switch node {
    case (#leaf) false;
    case (#node(color, _, _, _)) color == #R
  }
};

func checkKey(node : Set.Set<Nat>, isValid : Nat -> Bool) {
  switch node {
    case (#leaf) {};
    case (#node(_, _, (key, _), _)) {
      assert (isValid(key))
    }
  }
};

func insert(rbTree : Set.Set<Nat>, key : Nat) : Set.Set<Nat>  {
  let updatedTree = natSetOps.put(rbTree, key);
  checkSet(updatedTree);
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
  for (elem in Set.elements(initialRbSet)) {
    let newSet = natSetOps.delete(rbSet, elem);
    rbSet := newSet;
    checkSet(rbSet)
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
  Set.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        Set.size(buildTestSet()),
        M.equals(T.nat(0))
      ),
      test(
        "elements",
        Iter.toArray(Set.elements(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, []))
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
        Set.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold",
        Set.foldLeft(buildTestSet(), "", concatenateKeys),
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
        Set.isEmpty(buildTestSet()),
        M.equals(T.bool(true))
      ),
    ]
  )
);

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  insert(Set.empty(), 0);
};

var expected = [0];

run(
  suite(
    "single root",
    [
      test(
        "size",
        Set.size(buildTestSet()),
        M.equals(T.nat(1))
      ),
      test(
        "elements",
        Iter.toArray(Set.elements(buildTestSet())),
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
        Set.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold",
        Set.foldLeft(buildTestSet(), "", concatenateKeys),
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
        Set.isEmpty(buildTestSet()),
        M.equals(T.bool(false))
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
      Set.size(buildTestSet()),
      M.equals(T.nat(3))
    ),
    test(
      "Set match",
      buildTestSet(),
      SetMatcher(expected)
    ),
    test(
      "elements",
      Iter.toArray(Set.elements(buildTestSet())),
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
      Set.foldRight(buildTestSet(), "", concatenateKeys),
      M.equals(T.text("210"))
    ),
    test(
      "left fold",
      Set.foldLeft(buildTestSet(), "", concatenateKeys),
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
      Set.isEmpty(buildTestSet()),
      M.equals(T.bool(false))
    ),
  ];

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = Set.empty<Nat>();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 1);
  rbSet := insert(rbSet, 0);
  rbSet
};

run(suite("rebalance left, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = Set.empty<Nat>();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet
};

run(suite("rebalance left, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = Set.empty<Nat>();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 1);
  rbSet
};

run(suite("rebalance right, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var rbSet = Set.empty<Nat>();
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
          Set.size(rbSet)
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
  var rbSet = Set.empty<Nat>();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet := insert(rbSet, 2);
  rbSet
};

let buildTestSet01 = func() : Set.Set<Nat> {
  var rbSet = Set.empty<Nat>();
  rbSet := insert(rbSet, 0);
  rbSet := insert(rbSet, 1);
  rbSet
};

let buildTestSet234 = func() : Set.Set<Nat> {
  var rbSet = Set.empty<Nat>();
  rbSet := insert(rbSet, 2);
  rbSet := insert(rbSet, 3);
  rbSet := insert(rbSet, 4);
  rbSet
};

let buildTestSet345 = func() : Set.Set<Nat> {
  var rbSet = Set.empty<Nat>();
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
        natSetOps.isSubset(Set.empty<Nat>(), Set.empty<Nat>()),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of another set",
        natSetOps.isSubset(Set.empty<Nat>(), buildTestSet012()),
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
        natSetOps.equals(Set.empty<Nat>(), Set.empty<Nat>()),
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
        natSetOps.union(Set.empty<Nat>(), Set.empty<Nat>()),
        SetMatcher([])
      ),
      test(
        "union/union with empty set",
        natSetOps.union(buildTestSet012(), Set.empty<Nat>()),
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
        natSetOps.intersect(Set.empty<Nat>(), Set.empty<Nat>()),
        SetMatcher([])
      ),
      test(
        "intersect/intersect with empty set",
        natSetOps.intersect(buildTestSet012(), Set.empty<Nat>()),
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
        natSetOps.diff(Set.empty<Nat>(), Set.empty<Nat>()),
        SetMatcher([])
      ),
      test(
        "diff/diff with empty set",
        natSetOps.diff(buildTestSet012(), Set.empty<Nat>()),
        SetMatcher([0, 1, 2])
      ),
      test(
        "diff/diff with empty set 2",
        natSetOps.diff(Set.empty<Nat>(), buildTestSet012()),
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
