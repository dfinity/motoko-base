import Types "../../src/types";
import BTreeMap "../../src/btreemap";
import Node "../../src/node";
import Utils "../../src/utils";
import Conversion "../../src/conversion";
import TestableItems "testableItems";

import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Iter "mo:base/Iter";
import Int "mo:base/Int";

module {

  // For convenience: from base module
  type Iter<T> = Iter.Iter<T>;
  // For convenience: from types module
  type Entry = Types.Entry;
  // For convenience: from other modules
  type BTreeMap<K, V> = BTreeMap.BTreeMap<K, V>;
  type TestBuffer = TestableItems.TestBuffer;

  // A helper method to succinctly create an entry.
  func e(x: Nat8) : Entry {
    ([x], []);
  };

  let bytes_passtrough = {
    fromBytes = func(bytes: [Nat8]) : [Nat8] { bytes; };
    toBytes = func(bytes: [Nat8]) : [Nat8] { bytes; };
  };

  func insertGet(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    test.equalsOptBytes(btree.insert([1, 2, 3], [4, 5, 6]), null);
    test.equalsOptBytes(btree.get([1, 2, 3]), ?([4, 5, 6]));
  };

  func insertOverwritesPreviousValue(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    test.equalsOptBytes(btree.insert([1, 2, 3], [4, 5, 6]), null);
    test.equalsOptBytes(btree.insert([1, 2, 3], [7, 8, 9]), ?([4, 5, 6]));
    test.equalsOptBytes(btree.get([1, 2, 3]), ?([7, 8, 9]));
  };

  func insertGetMultiple(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    test.equalsOptBytes(btree.insert([1, 2, 3] , [4, 5, 6]), null);
    test.equalsOptBytes(btree.insert([4, 5] , [7, 8, 9, 10]), null);
    test.equalsOptBytes(btree.insert([], [11]), null);
    test.equalsOptBytes(btree.get([1, 2, 3]), ?([4, 5, 6]));
    test.equalsOptBytes(btree.get([4, 5]), ?([7, 8, 9, 10]));
    test.equalsOptBytes(btree.get([]), ?([11]));
  };

  func insertOverwriteMedianKeyInFullChildNode(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 17)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]

    let root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [Node.makeEntry([6], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    // The right child should now be full, with the median key being "12"
    var right_child = root.getChildren().get(1);
    test.equalsBool(right_child.isFull(), true);
    let median_index = right_child.getEntries().size() / 2;
    test.equalsBytes(right_child.getEntries().get(median_index).0, [12]);

    // Overwrite the median key.
    test.equalsOptBytes(btree.insert([12], [1, 2, 3]), ?([]));

    // The key is overwritten successfully.
    test.equalsOptBytes(btree.get([12]), ?([1, 2, 3]));

    // The child has not been split and is still full.
    right_child := root.getChildren().get(1);
    test.equalsNodeType(right_child.getNodeType(), #Leaf);
    test.equalsBool(right_child.isFull(), true);
  };

  func insertOverwriteKeyInFullRootNode(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };

    // We now have a root that is full and looks like this:
    //
    // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    var root = btree.getRootNode();
    test.equalsBool(root.isFull(), true);

    // Overwrite an element in the root. It should NOT cause the node to be split.
    test.equalsOptBytes(btree.insert([6], [4, 5, 6]), ?([]));

    root := btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Leaf);
    test.equalsOptBytes(btree.get([6]), ?([4, 5, 6]));
    test.equalsNat(root.getEntries().size(), 11);
  };

  func insertSameKeyMultiple(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    test.equalsOptBytes(btree.insert([1], [2]), null);

    for (i in Iter.range(2, 9)) {
      test.equalsOptBytes(btree.insert([1], [Nat8.fromNat(i) + 1]), ?([Nat8.fromNat(i)]));
    };
  };

  func insertSplitNode(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };

    // Should now split a node.
    test.equalsOptBytes(btree.insert([12], []), null);

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12]

    for (i in Iter.range(1, 12)) {
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([]));
    };
  };

  func overwriteTest(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    let num_elements = 255;

    // Ensure that the number of elements we insert is significantly
    // higher than `CAPACITY` so that we test interesting cases (e.g.
    // overwriting the value in an internal node).
    assert(Nat64.fromNat(num_elements) > 10 * Node.getCapacity());

    for (i in Iter.range(0, num_elements - 1)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };

    // Overwrite the values.
    for (i in Iter.range(0, num_elements - 1)) {
      // Assert we retrieved the old value correctly.
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], [1, 2, 3]), ?([]));
      // Assert we retrieved the new value correctly.
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([1, 2, 3]));
    };
  };

  func insertSplitMultipleNodes(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };
    // Should now split a node.
    test.equalsOptBytes(btree.insert([12], []), null);

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12]

    var root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([6], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    var child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(
      child_0.getEntries().toArray(),
      [
        ([1], []),
        ([2], []),
        ([3], []),
        ([4], []),
        ([5], [])
      ]
    );

    var child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(
      child_1.getEntries().toArray(),
      [
        ([7], []),
        ([8], []),
        ([9], []),
        ([10], []),
        ([11], []),
        ([12], [])
      ]
    );

    for (i in Iter.range(1, 12)) {
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([]));
    };

    // Insert more to cause more splitting.
    test.equalsOptBytes(btree.insert([13], []), null);
    test.equalsOptBytes(btree.insert([14], []), null);
    test.equalsOptBytes(btree.insert([15], []), null);
    test.equalsOptBytes(btree.insert([16], []), null);
    test.equalsOptBytes(btree.insert([17], []), null);
    // Should cause another split
    test.equalsOptBytes(btree.insert([18], []), null);

    for (i in Iter.range(1, 18)) {
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([]));
    };

    root := btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([6], []), ([12], [])]);
    test.equalsNat(root.getChildren().size(), 3);

    child_0 := root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(
      child_0.getEntries().toArray(),
      [
        ([1], []),
        ([2], []),
        ([3], []),
        ([4], []),
        ([5], [])
      ]
    );

    child_1 := root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(
      child_1.getEntries().toArray(),
      [
        ([7], []),
        ([8], []),
        ([9], []),
        ([10], []),
        ([11], []),
      ]
    );

    let child_2 = root.getChildren().get(2);
    test.equalsNodeType(child_2.getNodeType(), #Leaf);
    test.equalsEntries(
      child_2.getEntries().toArray(),
      [
        ([13], []),
        ([14], []),
        ([15], []),
        ([16], []),
        ([17], []),
        ([18], []),
      ]
    );
  };

  func removeSimple(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    test.equalsOptBytes(btree.insert([1, 2, 3], [4, 5, 6]), null);
    test.equalsOptBytes(btree.get([1, 2, 3]), ?([4, 5, 6]));
    test.equalsOptBytes(btree.remove([1, 2, 3]), ?([4, 5, 6]));
    test.equalsOptBytes(btree.get([1, 2, 3]), null);
  };

  func removeCase2aAnd2c(test: TestBuffer) {
    var btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };
    // Should now split a node.
    test.equalsOptBytes(btree.insert([0], []), null);

    // The result should look like this:
    //          [6]
    //           /   \
    // [0, 1, 2, 3, 4, 5]   [7, 8, 9, 10, 11]

    for (i in Iter.range(0, 11)) {
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([]));
    };

    // Remove node 6. Triggers case 2.a
    test.equalsOptBytes(btree.remove([6]), ?([]));

    // The result should look like this:
    //        [5]
    //         /   \
    // [0, 1, 2, 3, 4]   [7, 8, 9, 10, 11]
    var root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [e(5)]);
    test.equalsNat(root.getChildren().size(), 2);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(child_0.getEntries().toArray(), [e(0), e(1), e(2), e(3), e(4)]);

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(child_1.getEntries().toArray(), [e(7), e(8), e(9), e(10), e(11)]);

    // Remove node 5. Triggers case 2c
    test.equalsOptBytes(btree.remove([5]), ?([]));

    // The result should look like this:
    // [0, 1, 2, 3, 4, 7, 8, 9, 10, 11]
    root := btree.getRootNode();
    test.equalsEntries(
      root.getEntries().toArray(),
      [e(0), e(1), e(2), e(3), e(4), e(7), e(8), e(9), e(10), e(11)]
    );

  };

  func removeCase2b(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };
    // Should now split a node.
    test.equalsOptBytes(btree.insert([12], []), null);

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12]

    for (i in Iter.range(1, 12)) {
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([]));
    };

    // Remove node 6. Triggers case 2.b
    test.equalsOptBytes(btree.remove([6]), ?([]));

    // The result should look like this:
    //        [7]
    //         /   \
    // [1, 2, 3, 4, 5]   [8, 9, 10, 11, 12]
    var root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [e(7)]);
    test.equalsNat(root.getChildren().size(), 2);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(child_0.getEntries().toArray(), [e(1), e(2), e(3), e(4), e(5)]);

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(child_1.getEntries().toArray(), [e(8), e(9), e(10), e(11), e(12)]);

    // Remove node 7. Triggers case 2.c
    test.equalsOptBytes(btree.remove([7]), ?([]));
    // The result should look like this:
    //
    // [1, 2, 3, 4, 5, 8, 9, 10, 11, 12]
    root := btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Leaf);
    test.equalsEntries(
      root.getEntries().toArray(),
      [
        e(1),
        e(2),
        e(3),
        e(4),
        e(5),
        e(8),
        e(9),
        e(10),
        e(11),
        e(12)
      ]
    );
  };

  func removeCase3aRight(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };

    // Should now split a node.
    test.equalsOptBytes(btree.insert([12], []), null);

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12]

    // Remove node 3. Triggers case 3.a
    test.equalsOptBytes(btree.remove([3]), ?([]));

    // The result should look like this:
    //        [7]
    //         /   \
    // [1, 2, 4, 5, 6]   [8, 9, 10, 11, 12]
    let root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([7], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(child_0.getEntries().toArray(), [e(1), e(2), e(4), e(5), e(6)]);

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(child_1.getEntries().toArray(), [e(8), e(9), e(10), e(11), e(12)]);
  };

  func removeCase3aLeft(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };
    // Should now split a node.
    test.equalsOptBytes(btree.insert([0], []), null);

    // The result should look like this:
    //           [6]
    //          /   \
    // [0, 1, 2, 3, 4, 5]   [7, 8, 9, 10, 11]

    // Remove node 8. Triggers case 3.a left
    test.equalsOptBytes(btree.remove([8]), ?([]));

    // The result should look like this:
    //        [5]
    //         /   \
    // [0, 1, 2, 3, 4]   [6, 7, 9, 10, 11]
    let root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([5], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(child_0.getEntries().toArray(), [e(0), e(1), e(2), e(3), e(4)]);

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(child_1.getEntries().toArray(), [e(6), e(7), e(9), e(10), e(11)]);
  };

  func removeCase3bMergeIntoRight(test: TestBuffer) {
    var btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };
    // Should now split a node.
    test.equalsOptBytes(btree.insert([12], []), null);

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12]

    for (i in Iter.range(1, 12)) {
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([]));
    };

    // Remove node 6. Triggers case 2.b
    test.equalsOptBytes(btree.remove([6]), ?([]));
    // The result should look like this:
    //        [7]
    //         /   \
    // [1, 2, 3, 4, 5]   [8, 9, 10, 11, 12]
    var root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([7], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(child_0.getEntries().toArray(), [e(1), e(2), e(3), e(4), e(5)]);

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(child_1.getEntries().toArray(), [e(8), e(9), e(10), e(11), e(12)]);

    // Remove node 3. Triggers case 3.b
    test.equalsOptBytes(btree.remove([3]), ?([]));

    // The result should look like this:
    //
    // [1, 2, 4, 5, 7, 8, 9, 10, 11, 12]
    root := btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Leaf);
    test.equalsEntries(
      root.getEntries().toArray(),
      [
        e(1),
        e(2),
        e(4),
        e(5),
        e(7),
        e(8),
        e(9),
        e(10),
        e(11),
        e(12)
      ]
    );
  };

  func removeCase3bMergeIntoLeft(test: TestBuffer) {
    var btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 11)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };

    // Should now split a node.
    test.equalsOptBytes(btree.insert([12], []), null);

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12]

    for (i in Iter.range(1, 12)) {
      test.equalsOptBytes(btree.get([Nat8.fromNat(i)]), ?([]));
    };

    // Remove node 6. Triggers case 2.b
    test.equalsOptBytes(btree.remove([6]), ?([]));

    // The result should look like this:
    //        [7]
    //         /   \
    // [1, 2, 3, 4, 5]   [8, 9, 10, 11, 12]
    var root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([7], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(child_0.getEntries().toArray(), [e(1), e(2), e(3), e(4), e(5)]);

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(child_1.getEntries().toArray(), [e(8), e(9), e(10), e(11), e(12)]);

    // Remove node 10. Triggers case 3.b where we merge the right into the left.
    test.equalsOptBytes(btree.remove([10]), ?([]));

    // The result should look like this:
    //
    // [1, 2, 3, 4, 5, 7, 8, 9, 11, 12]
    root := btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Leaf);
    test.equalsEntries(
      root.getEntries().toArray(),
      [e(1), e(2), e(3), e(4), e(5), e(7), e(8), e(9), e(11), e(12)]
    );
  };

  func manyInsertions(test: TestBuffer) {
    var btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (j in Iter.range(0, 10)) {
      for (i in Iter.range(0, 255)) {
        let bytes = [Nat8.fromNat(i), Nat8.fromNat(j)];
        test.equalsOptBytes(btree.insert(bytes, bytes), null);
      };
    };

    for (j in Iter.range(0, 10)) {
      for (i in Iter.range(0, 255)) {
        let bytes = [Nat8.fromNat(i), Nat8.fromNat(j)];
        test.equalsOptBytes(btree.get(bytes), ?(bytes));
      };
    };

    for (j in Iter.range(0, 10)) {
      for (i in Iter.range(0, 255)) {
        let bytes = [Nat8.fromNat(i), Nat8.fromNat(j)];
        test.equalsOptBytes(btree.remove(bytes), ?(bytes));
      };
    };

    for (j in Iter.range(0, 10)) {
      for (i in Iter.range(0, 255)) {
        let bytes = [Nat8.fromNat(i), Nat8.fromNat(j)];
        test.equalsOptBytes(btree.get(bytes), null);
      };
    };
  };

  func manyInsertions2(test: TestBuffer) {
    var btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (j in Iter.revRange(10, 0)) {
      for (i in Iter.revRange(255, 0)) {
        let bytes = [Nat8.fromNat(Int.abs(i)), Nat8.fromNat(Int.abs(j))];
        test.equalsOptBytes(btree.insert(bytes, bytes), null);
      };
    };

    for (j in Iter.range(0, 10)) {
      for (i in Iter.range(0, 255)) {
        let bytes = [Nat8.fromNat(i), Nat8.fromNat(j)];
        test.equalsOptBytes(btree.get(bytes), ?(bytes));
      };
    };

    for (j in Iter.revRange(10, 0)) {
      for (i in Iter.revRange((255, 0))) {
        let bytes = [Nat8.fromNat(Int.abs(i)), Nat8.fromNat(Int.abs(j))];
        test.equalsOptBytes(btree.remove(bytes), ?(bytes));
      };
    };

    for (j in Iter.range(0, 10)) {
      for (i in Iter.range(0, 255)) {
        let bytes = [Nat8.fromNat(i), Nat8.fromNat(j)];
        test.equalsOptBytes(btree.get(bytes), null);
      };
    };
  };

  func len(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(0, 999)) {
      test.equalsOptBytes(btree.insert(Conversion.nat32ToBytes(Nat32.fromNat(i)), []) , null);
    };

    test.equalsNat64(btree.getLength(), 1000);
    test.equalsBool(btree.isEmpty(), false);

    for (i in Iter.range(0, 999)) {
      test.equalsOptBytes(btree.remove(Conversion.nat32ToBytes(Nat32.fromNat(i))), ?([]));
    };

    test.equalsNat64(btree.getLength(), 0);
    test.equalsBool(btree.isEmpty(), true);
  };

  func containsKey(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    // Insert even numbers from 0 to 1000.
    for (i in Iter.range(0, 499)) {
      test.equalsOptBytes(btree.insert(Conversion.nat32ToBytes(Nat32.fromNat(i * 2)), []), null);
    };

    // Contains key should return true on all the even numbers and false on all the odd
    // numbers.
    for (i in Iter.range(0, 499)) {
      test.equalsBool(btree.containsKey(Conversion.nat32ToBytes(Nat32.fromNat(i))), (i % 2 == 0));
    };
  };

  func rangeEmpty(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    // Test prefixes that don't exist in the map.
    test.equalsEntries(Iter.toArray(btree.range([0], null)), []);
    test.equalsEntries(Iter.toArray(btree.range([1, 2, 3, 4], null)), []);
  };

  // Tests the case where the prefix is larger than all the entries in a leaf node.
  func rangeLeafPrefixGreaterThanAllEntries(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    ignore btree.insert([0], []);

    // Test a prefix that's larger than the value in the leaf node. Should be empty.
    test.equalsEntries(Iter.toArray(btree.range([1], null)), []);
  };

  // Tests the case where the prefix is larger than all the entries in an internal node.
  func rangeInternalPrefixGreaterThanAllEntries(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    for (i in Iter.range(1, 12)) {
      test.equalsOptBytes(btree.insert([Nat8.fromNat(i)], []), null);
    };

    // The result should look like this:
    //        [6]
    //         /   \
    // [1, 2, 3, 4, 5]   [7, 8, 9, 10, 11, 12]

    // Test a prefix that's larger than the value in the internal node.
    test.equalsEntries(
      Iter.toArray(btree.range([7], null)),
      [([7], [])]
    );
  };

  func rangeVariousPrefixes(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    ignore btree.insert([0, 1], []);
    ignore btree.insert([0, 2], []);
    ignore btree.insert([0, 3], []);
    ignore btree.insert([0, 4], []);
    ignore btree.insert([1, 1], []);
    ignore btree.insert([1, 2], []);
    ignore btree.insert([1, 3], []);
    ignore btree.insert([1, 4], []);
    ignore btree.insert([2, 1], []);
    ignore btree.insert([2, 2], []);
    ignore btree.insert([2, 3], []);
    ignore btree.insert([2, 4], []);

    // The result should look like this:
    //                     [(1, 2)]
    //                     /   \
    // [(0, 1), (0, 2), (0, 3), (0, 4), (1, 1)]     [(1, 3), (1, 4), (2, 1), (2, 2), (2, 3), (2, 4)]

    let root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([1, 2], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    // Tests a prefix that's smaller than the value in the internal node.
    test.equalsEntries(
      Iter.toArray(btree.range([0], null)),
      [
        ([0, 1], []),
        ([0, 2], []),
        ([0, 3], []),
        ([0, 4], []),
      ]
    );

    // Tests a prefix that crosses several nodes.
    test.equalsEntries(
      Iter.toArray(btree.range([1], null)),
      [
        ([1, 1], []),
        ([1, 2], []),
        ([1, 3], []),
        ([1, 4], []),
      ]
    );

    // Tests a prefix that's larger than the value in the internal node.
    test.equalsEntries(
      Iter.toArray(btree.range([2], null)),
      [
        ([2, 1], []),
        ([2, 2], []),
        ([2, 3], []),
        ([2, 4], []),
      ]
    );
  };

  func rangeVariousPrefixes2(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    ignore btree.insert([0, 1], []);
    ignore btree.insert([0, 2], []);
    ignore btree.insert([0, 3], []);
    ignore btree.insert([0, 4], []);
    ignore btree.insert([1, 2], []);
    ignore btree.insert([1, 4], []);
    ignore btree.insert([1, 6], []);
    ignore btree.insert([1, 8], []);
    ignore btree.insert([1, 10], []);
    ignore btree.insert([2, 1], []);
    ignore btree.insert([2, 2], []);
    ignore btree.insert([2, 3], []);
    ignore btree.insert([2, 4], []);
    ignore btree.insert([2, 5], []);
    ignore btree.insert([2, 6], []);
    ignore btree.insert([2, 7], []);
    ignore btree.insert([2, 8], []);
    ignore btree.insert([2, 9], []);

    // The result should look like this:
    //                     [(1, 4), (2, 3)]
    //                     /    |     \
    // [(0, 1), (0, 2), (0, 3), (0, 4), (1, 2)]     |    [(2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9)]
    //                        |
    //               [(1, 6), (1, 8), (1, 10), (2, 1), (2, 2)]
    let root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(
      root.getEntries().toArray(),
      [([1, 4], []), ([2, 3], [])]
    );
    test.equalsNat(root.getChildren().size(), 3);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(
      child_0.getEntries().toArray(),
      [
        ([0, 1], []),
        ([0, 2], []),
        ([0, 3], []),
        ([0, 4], []),
        ([1, 2], []),
      ]
    );

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(
      child_1.getEntries().toArray(),
      [
        ([1, 6], []),
        ([1, 8], []),
        ([1, 10], []),
        ([2, 1], []),
        ([2, 2], []),
      ]
    );

    let child_2 = root.getChildren().get(2);
    test.equalsEntries(
      child_2.getEntries().toArray(),
      [
        ([2, 4], []),
        ([2, 5], []),
        ([2, 6], []),
        ([2, 7], []),
        ([2, 8], []),
        ([2, 9], []),
      ]
    );

    // Tests a prefix that doesn't exist, but is in the middle of the root node.
    test.equalsEntries(Iter.toArray(btree.range([1, 5], null)), []);

    // Tests a prefix that crosses several nodes.
    test.equalsEntries(
      Iter.toArray(btree.range([1], null)),
      [
        ([1, 2], []),
        ([1, 4], []),
        ([1, 6], []),
        ([1, 8], []),
        ([1, 10], []),
      ]
    );

    // Tests a prefix that starts from a leaf node, then iterates through the root and right
    // sibling.
    test.equalsEntries(
      Iter.toArray(btree.range([2], null)),
      [
        ([2, 1], []),
        ([2, 2], []),
        ([2, 3], []),
        ([2, 4], []),
        ([2, 5], []),
        ([2, 6], []),
        ([2, 7], []),
        ([2, 8], []),
        ([2, 9], []),
      ]
    );
  };

  func rangeLarge(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    // Insert 1000 elements with prefix 0 and another 1000 elements with prefix 1.
    for (prefix in Iter.range(0, 1)) {
      for (i in Iter.range(0, 999)) {
        // The key is the prefix followed by the integer's encoding.
        // The encoding is big-endian so that the byte representation of the
        // integers are sorted.
        // @todo: here it is supposed to be in big endian!
        let key = Utils.append([Nat8.fromNat(prefix)], Conversion.nat32ToBytes(Nat32.fromNat(i)));
        test.equalsOptBytes(btree.insert(key, []), null);
      };
    };

    // Getting the range with a prefix should return all 1000 elements with that prefix.
    for (prefix in Iter.range(0, 1)) {
      var i : Nat32 = 0;
      for ((key, _) in btree.range([Nat8.fromNat(prefix)], null)) {
        // @todo: here it is supposed to be in big endian!
        test.equalsBytes(key, Utils.append([Nat8.fromNat(prefix)], Conversion.nat32ToBytes(i)));
        i += 1;
      };
      test.equalsNat32(i, 1000);
    };
  };

  func rangeVariousPrefixesWithOffset(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    ignore btree.insert([0, 1], []);
    ignore btree.insert([0, 2], []);
    ignore btree.insert([0, 3], []);
    ignore btree.insert([0, 4], []);
    ignore btree.insert([1, 1], []);
    ignore btree.insert([1, 2], []);
    ignore btree.insert([1, 3], []);
    ignore btree.insert([1, 4], []);
    ignore btree.insert([2, 1], []);
    ignore btree.insert([2, 2], []);
    ignore btree.insert([2, 3], []);
    ignore btree.insert([2, 4], []);

    // The result should look like this:
    //                     [(1, 2)]
    //                     /   \
    // [(0, 1), (0, 2), (0, 3), (0, 4), (1, 1)]     [(1, 3), (1, 4), (2, 1), (2, 2), (2, 3), (2, 4)]

    let root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(root.getEntries().toArray(), [([1, 2], [])]);
    test.equalsNat(root.getChildren().size(), 2);

    // Tests a offset that's smaller than the value in the internal node.
    test.equalsEntries(
      Iter.toArray(btree.range([0], ?([0]))),
      [
        ([0, 1], []),
        ([0, 2], []),
        ([0, 3], []),
        ([0, 4], []),
      ]
    );

    // Tests a offset that has a value somewhere in the range of values of an internal node.
    test.equalsEntries(
      Iter.toArray(btree.range([1], ?([3]))),
      [([1, 3], []), ([1, 4], []),]
    );

    // Tests a offset that's larger than the value in the internal node.
    test.equalsEntries(
      Iter.toArray(btree.range([2], ?([5]))),
      [],
    );
  };

  func rangeVariousPrefixesWithOffset2(test: TestBuffer) {
    let btree = BTreeMap.BTreeMap<[Nat8], [Nat8]>(bytes_passtrough, bytes_passtrough);

    ignore btree.insert([0, 1], []);
    ignore btree.insert([0, 2], []);
    ignore btree.insert([0, 3], []);
    ignore btree.insert([0, 4], []);
    ignore btree.insert([1, 2], []);
    ignore btree.insert([1, 4], []);
    ignore btree.insert([1, 6], []);
    ignore btree.insert([1, 8], []);
    ignore btree.insert([1, 10], []);
    ignore btree.insert([2, 1], []);
    ignore btree.insert([2, 2], []);
    ignore btree.insert([2, 3], []);
    ignore btree.insert([2, 4], []);
    ignore btree.insert([2, 5], []);
    ignore btree.insert([2, 6], []);
    ignore btree.insert([2, 7], []);
    ignore btree.insert([2, 8], []);
    ignore btree.insert([2, 9], []);

    // The result should look like this:
    //                     [(1, 4), (2, 3)]
    //                     /    |     \
    // [(0, 1), (0, 2), (0, 3), (0, 4), (1, 2)]     |    [(2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9)]
    //                        |
    //               [(1, 6), (1, 8), (1, 10), (2, 1), (2, 2)]
    let root = btree.getRootNode();
    test.equalsNodeType(root.getNodeType(), #Internal);
    test.equalsEntries(
      root.getEntries().toArray(),
      [([1, 4], []), ([2, 3], [])]
    );
    test.equalsNat(root.getChildren().size(), 3);

    let child_0 = root.getChildren().get(0);
    test.equalsNodeType(child_0.getNodeType(), #Leaf);
    test.equalsEntries(
      child_0.getEntries().toArray(),
      [
        ([0, 1], []),
        ([0, 2], []),
        ([0, 3], []),
        ([0, 4], []),
        ([1, 2], []),
      ]
    );

    let child_1 = root.getChildren().get(1);
    test.equalsNodeType(child_1.getNodeType(), #Leaf);
    test.equalsEntries(
      child_1.getEntries().toArray(),
      [
        ([1, 6], []),
        ([1, 8], []),
        ([1, 10], []),
        ([2, 1], []),
        ([2, 2], []),
      ]
    );

    let child_2 = root.getChildren().get(2);
    test.equalsEntries(
      child_2.getEntries().toArray(),
      [
        ([2, 4], []),
        ([2, 5], []),
        ([2, 6], []),
        ([2, 7], []),
        ([2, 8], []),
        ([2, 9], []),
      ]
    );

    // Tests a offset that crosses several nodes.
    test.equalsEntries(
      Iter.toArray(btree.range([1], ?([4]))),
      [
        ([1, 4], []),
        ([1, 6], []),
        ([1, 8], []),
        ([1, 10], []),
      ]
    );

    // Tests a offset that starts from a leaf node, then iterates through the root and right
    // sibling.
    test.equalsEntries(
      Iter.toArray(btree.range([2], ?([2]))),
      [
        ([2, 2], []),
        ([2, 3], []),
        ([2, 4], []),
        ([2, 5], []),
        ([2, 6], []),
        ([2, 7], []),
        ([2, 8], []),
        ([2, 9], []),
      ]
    );
  };

  public func run() {
    let test = TestableItems.TestBuffer();

    insertGet(test);
    insertOverwritesPreviousValue(test);
    insertGetMultiple(test);
    insertOverwriteMedianKeyInFullChildNode(test);
    insertOverwriteKeyInFullRootNode(test);
    insertSameKeyMultiple(test);
    insertSplitNode(test);
    overwriteTest(test);
    insertSplitMultipleNodes(test);
    removeSimple(test);
    removeCase2aAnd2c(test);
    removeCase2b(test);
    removeCase3aRight(test);
    removeCase3aLeft(test);
    removeCase3bMergeIntoRight(test);
    removeCase3bMergeIntoLeft(test);
    manyInsertions(test);
    manyInsertions2(test);
    len(test);
    containsKey(test);
    rangeEmpty(test);
    rangeLeafPrefixGreaterThanAllEntries(test);
    rangeInternalPrefixGreaterThanAllEntries(test);
    rangeVariousPrefixes(test);
    rangeVariousPrefixes2(test);
    rangeLarge(test);
    rangeVariousPrefixesWithOffset(test);
    rangeVariousPrefixesWithOffset2(test);

    test.run("Test btreemap module");
  };

};