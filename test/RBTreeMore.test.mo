// @testmode wasi

import RBTree "../src/RBTree";
import Nat "../src/Nat";
import Iter "../src/Iter";
import Debug "../src/Debug";
import Array "../src/Array";

import Deque "../src/Deque";
import Buffer "../src/Buffer";


import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

class TreeMatcher(expected : [(Nat, Nat)]) : M.Matcher<RBTree.RBTree<Nat, Nat>> {
  public func describeMismatch(actual : RBTree.RBTree<Nat, Nat>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(actual.entries())) # " should be " # debug_show (expected))
  };

  public func matches(actual : RBTree.RBTree<Nat, Nat>) : Bool {
    Iter.toArray(actual.entries()) == expected
  }
};

func checkTree(tree : RBTree.RBTree<Nat, Nat>) {
  ignore blackDepth(tree.share())
};

func blackDepth(node : RBTree.Tree<Nat, Nat>) : Nat {
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

func isRed(node : RBTree.Tree<Nat, Nat>) : Bool {
  switch node {
    case (#leaf) false;
    case (#node(color, _, _, _)) color == #R
  }
};

func checkKey(node : RBTree.Tree<Nat, Nat>, isValid : Nat -> Bool) {
  switch node {
    case (#leaf) {};
    case (#node(_, _, (key, _), _)) {
      assert (isValid(key))
    }
  }
};

func insert(tree : RBTree.RBTree<Nat, Nat>, key : Nat) {
  tree.put(key, key);
  checkTree(tree)
};

func clear(tree : RBTree.RBTree<Nat, Nat>) {
  for ((key, value) in tree.entries()) {
    // stable iteration
    assert (value == key);
    let result = tree.remove(key);
    assert (result == ?key);
    checkTree(tree)
  }
};

func expectedEntries(keys : [Nat]) : [(Nat, Nat)] {
  Array.tabulate<(Nat, Nat)>(keys.size(), func(index) { (keys[index], keys[index]) })
};

/* --------------------------------------- */

var buildTestTree = func() : RBTree.RBTree<Nat, Nat> {
  RBTree.RBTree<Nat, Nat>(Nat.compare)
};

/* --------------------------------------- */

object Random {
  var number = 4711;
  public func next() : Nat {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

func shuffle(array : [Nat]) : [Nat] {
  let extended = Array.map<Nat, (Nat, Nat)>(array, func(value) { (value, Random.next()) });
  let sorted = Array.sort<(Nat, Nat)>(
    extended,
    func(first, second) {
      Nat.compare(first.1, second.1)
    }
  );
  Array.map<(Nat, Nat), Nat>(
    sorted,
    func(value) {
      value.0
    }
  )
};

let testSize = 5000;

let testKeys = shuffle(Array.tabulate<Nat>(testSize, func(index) { index }));

buildTestTree := func() : RBTree.RBTree<Nat, Nat> {
  let tree = RBTree.RBTree<Nat, Nat>(Nat.compare);
  for (key in testKeys.vals()) {
    insert(tree, key)
  };
  tree
};

var expected = expectedEntries(Array.sort(testKeys, Nat.compare));

run(
  suite(
    "random tree",
    [
      test(
        "size",
        RBTree.size(buildTestTree().share()),
        M.equals(T.nat(testSize))
      ),
      test(
        "remove randomized (larger tree)",
        do {
          let tree = buildTestTree();
          var count = 0;
          for (key in testKeys.vals()) {
            if (Random.next() % 2 == 0) {
              let result = tree.remove(key);
              assert (result == ?key);
              checkTree(tree);
              count += 1
            }
          };
          RBTree.size(tree.share()) == +testKeys.size() - count
        },
        M.equals(T.bool(true))
      ),
      test(
        "clear",
        do {
          let tree = buildTestTree();
          clear(tree);
          tree
        },
        TreeMatcher([])
      ),
      test(
        "random insert and delete",
        do {
          var available = Deque.empty<Nat>();
          for (key in testKeys.vals()) {
            available := Deque.pushBack(available, key);
          };
          let capacity = 1000;
          let expected = Buffer.Buffer<Nat>(capacity);
          let tree = RBTree.RBTree<Nat, Nat>(Nat.compare);
          let randomSteps = 1000;
          for (step in Iter.range(0, randomSteps)) {
            if (expected.size() < 10 or Random.next() % 3 != 0) {
              let result = Deque.popFront(available);
              switch (result) {
                case null assert(false);
                case (?(key, reduced)) {
                  available := reduced;
                  tree.put(key, key);
                  expected.add(key);
                }
              }
            } else {
              let index = Random.next() % expected.size();
              let key = expected.remove(index);
              available := Deque.pushBack(available, key);
              let result = tree.remove(key);
              switch result {
                case null assert(false);
                case (?value) {
                  assert(key == value);
                }
              }
            };
            checkTree(tree);
          };
          Iter.toArray(tree.entries()) == expectedEntries(Array.sort(Buffer.toArray(expected), Nat.compare))
        },
        M.equals(T.bool(true))
      )
    ]
  )
)
