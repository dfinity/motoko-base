import RBTree "mo:base/RBTree";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Array "mo:base/Array";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

class TreeMatcher(expected : [(Nat, Text)]) : M.Matcher<RBTree.RBTree<Nat, Text>> {
  public func describeMismatch(actual : RBTree.RBTree<Nat, Text>, description : M.Description) {
    Debug.print(debug_show (Iter.toArray(actual.entries())) # " should be " # debug_show (expected))
  };

  public func matches(actual : RBTree.RBTree<Nat, Text>) : Bool {
    Iter.toArray(actual.entries()) == expected
  }
};

func checkTree(tree : RBTree.RBTree<Nat, Text>) {
  ignore blackDepth(tree.share())
};

func blackDepth(node : RBTree.Tree<Nat, Text>) : Nat {
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

func isRed(node : RBTree.Tree<Nat, Text>) : Bool {
  switch node {
    case (#leaf) false;
    case (#node(color, _, _, _)) color == #R
  }
};

func checkKey(node : RBTree.Tree<Nat, Text>, isValid : Nat -> Bool) {
  switch node {
    case (#leaf) {};
    case (#node(_, _, (key, _), _)) {
      assert (isValid(key))
    }
  }
};

func insert(tree : RBTree.RBTree<Nat, Text>, key : Nat) {
  tree.put(key, debug_show (key));
  checkTree(tree)
};

func remove(tree : RBTree.RBTree<Nat, Text>, key : Nat) {
  let value = tree.remove(key);
  assert (value == ?debug_show (key));
  checkTree(tree)
};

func getAll(tree : RBTree.RBTree<Nat, Text>, keys : [Nat]) {
  for (key in keys.vals()) {
    let value = tree.get(key);
    assert (value == ?debug_show (key))
  }
};

func clear(tree : RBTree.RBTree<Nat, Text>) {
  for ((key, value) in tree.entries()) {
    // stable iteration
    assert (value == debug_show (key));
    let result = tree.remove(key);
    assert (result == ?debug_show (key));
    checkTree(tree)
  }
};

func expectedEntries(keys : [Nat]) : [(Nat, Text)] {
  Array.tabulate<(Nat, Text)>(keys.size(), func(index) { (keys[index], debug_show (keys[index])) })
};

/* --------------------------------------- */

var buildTestTree = func() : RBTree.RBTree<Nat, Text> {
  RBTree.RBTree<Nat, Text>(Nat.compare)
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        RBTree.size(buildTestTree().share()),
        M.equals(T.nat(0))
      ),
      test(
        "iterate forward",
        Iter.toArray(buildTestTree().entries()),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "iterate backward",
        Iter.toArray(buildTestTree().entriesRev()),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "get absent",
        buildTestTree().get(0),
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "remove absent",
        buildTestTree().remove(0),
        M.equals(T.optional(T.textTestable, null : ?Text))
      )
    ]
  )
);

/* --------------------------------------- */

buildTestTree := func() : RBTree.RBTree<Nat, Text> {
  let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  insert(tree, 0);
  tree
};

var expected = expectedEntries([0]);

run(
  suite(
    "single root",
    [
      test(
        "size",
        RBTree.size(buildTestTree().share()),
        M.equals(T.nat(1))
      ),
      test(
        "iterate forward",
        Iter.toArray(buildTestTree().entries()),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "iterate backward",
        Iter.toArray(buildTestTree().entriesRev()),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "get",
        buildTestTree().get(0),
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "replace function result",
        buildTestTree().replace(0, "TEST"),
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "replace tree result",
        do {
          let tree = buildTestTree();
          ignore tree.replace(0, "TEST");
          tree
        },
        TreeMatcher([(0, "TEST")])
      ),
      test(
        "remove function result",
        buildTestTree().remove(0),
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "remove tree result",
        do {
          let tree = buildTestTree();
          ignore tree.remove(0);
          tree
        },
        TreeMatcher([])
      )
    ]
  )
);

/* --------------------------------------- */

buildTestTree := func() : RBTree.RBTree<Nat, Text> {
  let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  insert(tree, 2);
  insert(tree, 1);
  insert(tree, 0);
  tree
};

expected := expectedEntries([0, 1, 2]);

run(
  suite(
    "rebalance left, left",
    [
      test(
        "tree match",
        buildTestTree(),
        TreeMatcher(expected)
      ),
      test(
        "get all",
        do {
          let tree = buildTestTree();
          getAll(tree, [0, 1, 2]);
          tree
        },
        TreeMatcher(expected)
      ),
      test(
        "clear",
        do {
          let tree = buildTestTree();
          clear(tree);
          tree
        },
        TreeMatcher([])
      )
    ]
  )
);

/* --------------------------------------- */

buildTestTree := func() : RBTree.RBTree<Nat, Text> {
  let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  insert(tree, 2);
  insert(tree, 0);
  insert(tree, 1);
  tree
};

run(
  suite(
    "rebalance left, right",
    [
      test(
        "tree match",
        buildTestTree(),
        TreeMatcher(expected)
      ),
      test(
        "get all",
        do {
          let tree = buildTestTree();
          getAll(tree, [0, 1, 2]);
          tree
        },
        TreeMatcher(expected)
      ),
      test(
        "clear",
        do {
          let tree = buildTestTree();
          clear(tree);
          tree
        },
        TreeMatcher([])
      )
    ]
  )
);

/* --------------------------------------- */

buildTestTree := func() : RBTree.RBTree<Nat, Text> {
  let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  insert(tree, 0);
  insert(tree, 2);
  insert(tree, 1);
  tree
};

run(
  suite(
    "rebalance right, left",
    [
      test(
        "tree match",
        buildTestTree(),
        TreeMatcher(expected)
      ),
      test(
        "get all",
        do {
          let tree = buildTestTree();
          getAll(tree, [0, 1, 2]);
          tree
        },
        TreeMatcher(expected)
      ),
      test(
        "clear",
        do {
          let tree = buildTestTree();
          clear(tree);
          tree
        },
        TreeMatcher([])
      )
    ]
  )
);

/* --------------------------------------- */

buildTestTree := func() : RBTree.RBTree<Nat, Text> {
  let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  insert(tree, 0);
  insert(tree, 1);
  insert(tree, 2);
  tree
};

run(
  suite(
    "rebalance right, right",
    [
      test(
        "tree match",
        buildTestTree(),
        TreeMatcher(expected)
      ),
      test(
        "get all",
        do {
          let tree = buildTestTree();
          getAll(tree, [0, 1, 2]);
          tree
        },
        TreeMatcher(expected)
      ),
      test(
        "clear",
        do {
          let tree = buildTestTree();
          clear(tree);
          tree
        },
        TreeMatcher([])
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "repeated operations",
    [
      test(
        "repeated insert",
        do {
          let tree = buildTestTree();
          assert (tree.get(1) == ?"1");
          tree.put(1, "TEST-1");
          tree.get(1)
        },
        M.equals(T.optional(T.textTestable, ?"TEST-1"))
      ),
      test(
        "repeated replace",
        do {
          let tree = buildTestTree();
          let firstResult = tree.replace(1, "TEST-1");
          assert (firstResult == ?"1");
          let secondResult = tree.replace(1, "1");
          assert (secondResult == ?"TEST-1");
          tree
        },
        TreeMatcher(expected)
      ),
      test(
        "repeated remove",
        do {
          let tree = buildTestTree();
          let result = tree.remove(1);
          assert (result == ?"1");
          tree.remove(1)
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "repeated delete",
        do {
          let tree = buildTestTree();
          tree.delete(1);
          tree.delete(1);
          tree
        },
        TreeMatcher(expectedEntries([0, 2]))
      )
    ]
  )
);

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

let testSize = 1000;

let testKeys = shuffle(Array.tabulate<Nat>(testSize, func(index) { index }));

buildTestTree := func() : RBTree.RBTree<Nat, Text> {
  let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  for (key in testKeys.vals()) {
    insert(tree, key)
  };
  tree
};

expected := expectedEntries(Array.sort(testKeys, Nat.compare));

run(
  suite(
    "Random tree",
    [
      test(
        "size",
        RBTree.size(buildTestTree().share()),
        M.equals(T.nat(testSize))
      ),
      test(
        "iterate forward",
        Iter.toArray(buildTestTree().entries()),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "iterate backward",
        Iter.toArray(buildTestTree().entriesRev()),
        M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(expected)))
      ),
      test(
        "low-level iterate forward",
        Iter.toArray(RBTree.iter(buildTestTree().share(), #fwd)),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "low-level iterate backward",
        Iter.toArray(RBTree.iter(buildTestTree().share(), #bwd)),
        M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(expected)))
      ),
      test(
        "get all",
        do {
          let tree = buildTestTree();
          getAll(tree, [0, 1, 2]);
          tree
        },
        TreeMatcher(expected)
      ),
      test(
        "replace all",
        do {
          let tree = buildTestTree();
          for (key in testKeys.vals()) {
            let value = tree.replace(key, "TEST-" # debug_show (key));
            assert (value == ?debug_show (key));
            checkTree(tree)
          };
          tree
        },
        TreeMatcher(Array.map<Nat, (Nat, Text)>(Array.sort(testKeys, Nat.compare), func(key) { (key, "TEST-" # debug_show (key)) }))
      ),
      test(
        "remove randomized",
        do {
          let tree = buildTestTree();
          var count = 0;
          for (key in testKeys.vals()) {
            if (Random.next() % 2 == 0) {
              let result = tree.remove(key);
              assert (result == ?debug_show (key));
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
      )
    ]
  )
)
