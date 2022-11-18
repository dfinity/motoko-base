/// The BTree module collection of functions and types

import Types "./Types";
import BS "./BinarySearch";
import AU "./ArrayUtil";

import Int "mo:base/Int";
import O "mo:base/Order";

import Array "mo:base/Array";
import Nat "mo:base/Nat";

import Option "mo:base/Option";


module {
  public type BTree<K, V> = Types.BTree<K, V>;
  public type Node<K, V> = Types.Node<K, V>;
  public type Internal<K, V> = Types.Internal<K, V>;
  public type Leaf<K, V> = Types.Leaf<K, V>;
  public type Data<K, V> = Types.Data<K, V>;

  // TODO - enforce BTrees to have order of at least 4
  public func init<K, V>(order: Nat): BTree<K, V> = {
    var root = #leaf({
      data = {
        kvs = Array.tabulateVar<?(K, V)>(order - 1, func(i) { null });
        var count = 0;
      };
    }); 
    order;
  };

  
  /// Allows one to quickly create a BTree using an array of key value pairs
  public func createBTreeWithKVPairs<K, V>(order: Nat, compare: (K, K) -> O.Order, kvPairs: [(K, V)]): BTree<K, V> {
    let t = init<K, V>(order);
    let _ = Array.map<(K, V), ?V>(kvPairs, func(pair) {
      insert<K, V>(t, compare, pair.0, pair.1)
    });
    t;
  };


  /// Retrieves the value corresponding to the key of BTree if it exists
  public func get<K, V>(tree: BTree<K, V>, compare: (K, K) -> O.Order, key: K): ?V {
    switch(tree.root) {
      case (#internal(internalNode)) { getFromInternal(internalNode, compare, key) };
      case (#leaf(leafNode)) { getFromLeaf(leafNode, compare, key) }
    }
  };


  /// Inserts an element into a BTree
  public func insert<K, V>(tree: BTree<K, V>, compare: (K, K) -> O.Order, key: K, value: V): ?V {
    switch(tree.root) {
      case (#leaf(leafNode)) {
        switch(leafInsertHelper<K, V>(leafNode, tree.order, compare, key, value)) {
          case (#insert(ov)) { ov };
          case (#promote({ kv; leftChild; rightChild; })) {
            tree.root := #internal({
              data = {
                kvs = Array.tabulateVar<?(K, V)>(tree.order - 1, func(i) {
                  if (i == 0) { ?kv }
                  else { null }
                });
                var count = 1;
              };
              children = Array.tabulateVar<?(Node<K, V>)>(tree.order, func(i) {
                if (i == 0) { ?leftChild }
                else if (i == 1) { ?rightChild }
                else { null }
              });
            });

            null
          }
        };
      };
      case (#internal(internalNode)) {
        switch(internalInsertHelper<K, V>(internalNode, tree.order, compare, key, value)) {
          case (#insert(ov)) { ov };
          case (#promote({ kv; leftChild; rightChild; })) {
            tree.root := #internal({
              data = {
                kvs = Array.tabulateVar<?(K, V)>(tree.order - 1, func(i) {
                  if (i == 0) { ?kv }
                  else { null }
                }); 
                var count = 1;
              };
              children = Array.tabulateVar<?(Node<K, V>)>(tree.order, func(i) {
                if (i == 0) { ?leftChild }
                else if (i == 1) { ?rightChild }
                else { null }
              });
            });

            null
            
          }
        };
      }
    }
  };


  // get helper if internal node
  func getFromInternal<K, V>(internalNode: Internal<K, V>, compare: (K, K) -> O.Order, key: K): ?V { 
    switch(getKeyIndex<K, V>(internalNode.data, compare, key)) {
      case (#keyFound(index)) { getExistingValueFromIndex(internalNode.data, index) };
      case (#notFound(index)) {
        switch(internalNode.children[index]) {
          // expects the child to be there, otherwise there's a bug in binary search or the tree is invalid
          case null { assert false; null };
          case (?#leaf(leafNode)) { getFromLeaf(leafNode, compare, key)};
          case (?#internal(internalNode)) { getFromInternal(internalNode, compare, key)}
        }
      }
    }
  };

  // get function helper if leaf node
  func getFromLeaf<K, V>(leafNode: Leaf<K, V>, compare: (K, K) -> O.Order, key: K): ?V { 
    switch(getKeyIndex<K, V>(leafNode.data, compare, key)) {
      case (#keyFound(index)) { getExistingValueFromIndex(leafNode.data, index) };
      case _ null;
    }
  };

  // get function helper that retrieves an existing value in the case that the key is found
  func getExistingValueFromIndex<K, V>(data: Data<K, V>, index: Nat): ?V {
    switch(data.kvs[index]) {
      case null { null };
      case (?ov) { ?ov.1 }
    }
  };


  // This type is used to signal to the parent calling context what happened in the level below
  type IntermediateInsertResult<K, V> = {
    // element was inserted or replaced, returning the old value (?value or null)
    #insert: ?V;
    // child was full when inserting, so returns the promoted kv pair and the split left and right child 
    #promote: {
      kv: (K, V);
      leftChild: Node<K, V>;
      rightChild: Node<K, V>;
    };
  };


  // Helper for inserting into a leaf node
  func leafInsertHelper<K, V>(leafNode: Leaf<K, V>, order: Nat, compare: (K, K) -> O.Order, key: K, value: V): (IntermediateInsertResult<K, V>) {
    // Perform binary search to see if the element exists in the node
    switch(getKeyIndex<K, V>(leafNode.data, compare, key)) {
      case (#keyFound(insertIndex)) {
        let previous = leafNode.data.kvs[insertIndex];
        leafNode.data.kvs[insertIndex] := ?(key, value);
        switch(previous) {
          case (?ov) { #insert(?ov.1) };
          case null { assert false; #insert(null) }; // the binary search already found an element, so this case should never happen
        }
      };
      case (#notFound(insertIndex)) {
        // Note: BTree will always have an order >= 4, so this will never have negative Nat overflow
        let maxKeys: Nat = order - 1;
        // If the leaf is full, insert, split the node, and promote the middle element
        if (leafNode.data.count >= maxKeys) {
          let (leftKVs, promotedParentElement, rightKVs) = AU.insertOneAtIndexAndSplitArray(
            leafNode.data.kvs,
            (key, value),
            insertIndex
          );

          let leftCount = order / 2;
          let rightCount: Nat = if (order % 2 == 0) { leftCount - 1 } else { leftCount };

          (
            #promote({
              kv = promotedParentElement;
              leftChild = createLeaf<K, V>(leftKVs, leftCount);
              rightChild = createLeaf<K, V>(rightKVs, rightCount);
            })
          )
        } 
        // Otherwise, insert at the specified index (shifting elements over if necessary) 
        else {
          insertAtIndexOfNonFullNodeData<K, V>(leafNode.data, (key, value), insertIndex);
          #insert(null);
        };
      }
    }
  };


  // Helper for inserting into an internal node
  func internalInsertHelper<K, V>(internalNode: Internal<K, V>, order: Nat, compare: (K, K) -> O.Order, key: K, value: V): IntermediateInsertResult<K, V> {
    switch(getKeyIndex<K, V>(internalNode.data, compare, key)) {
      case (#keyFound(insertIndex)) {
        let previous = internalNode.data.kvs[insertIndex];
        internalNode.data.kvs[insertIndex] := ?(key, value);
        switch(previous) {
          case (?ov) { #insert(?ov.1) };
          case null { assert false; #insert(null) }; // the binary search already found an element, so this case should never happen
        }
      };
      case (#notFound(insertIndex)) {
        let insertResult = switch(internalNode.children[insertIndex]) {
          case null { assert false; #insert(null) };
          case (?#leaf(leafNode)) { leafInsertHelper(leafNode, order, compare, key, value) };
          case (?#internal(internalChildNode)) { internalInsertHelper(internalChildNode, order, compare, key, value) };
        };

        switch(insertResult) {
          case (#insert(ov)) { #insert(ov) };
          case (#promote({ kv; leftChild; rightChild; })) {
            // Note: BTree will always have an order >= 4, so this will never have negative Nat overflow
            let maxKeys: Nat = order - 1;
            // if current internal node is full, need to split the internal node
            if (internalNode.data.count >= maxKeys) {
              // insert and split internal kvs, determine new promotion target kv
              let (leftKVs, promotedParentElement, rightKVs) = AU.insertOneAtIndexAndSplitArray(
                internalNode.data.kvs,
                (kv),
                insertIndex
              );

              // calculate the element count in the left KVs and the element count in the right KVs
              let leftCount = order / 2;
              let rightCount: Nat = if (order % 2 == 0) { leftCount - 1 } else { leftCount };

              // split internal children
              let (leftChildren, rightChildren) = splitChildrenInTwoWithRebalances<K, V>(
                internalNode.children,
                insertIndex,
                leftChild,
                rightChild
              );

              // send the kv to be promoted, as well as the internal children left and right split 
              #promote({
                kv = promotedParentElement;
                leftChild = #internal({
                  data = { kvs = leftKVs; var count = leftCount; };
                  children = leftChildren;
                });
                rightChild = #internal({
                  data = { kvs = rightKVs; var count = rightCount; };
                  children = rightChildren;
                })
              });
            }
            else {
              // insert the new kvs into the internal node
              insertAtIndexOfNonFullNodeData(internalNode.data, kv, insertIndex);
              // split and re-insert the single child that needs rebalancing
              insertRebalancedChild(internalNode.children, insertIndex, leftChild, rightChild);
              #insert(null);
            }
          }
        };
      }
    };
  };


  func createLeaf<K, V>(kvs: [var ?(K, V)], count: Nat): Node<K, V> {
    #leaf({
      data = {
        kvs;
        var count;
      }
    })
  };

  
  /// Inserts element at the given index into a non-full leaf node
  func insertAtIndexOfNonFullNodeData<K, V>(data: Data<K, V>, kvPair: (K, V), insertIndex: Nat): () {
    let currentLastElementIndex = if (data.count == 0) { 0 } else { Int.abs(data.count - 1) };
    AU.insertAtPosition<(K, V)>(data.kvs, ?kvPair, insertIndex, currentLastElementIndex);

    // increment the count of data in this node since just inserted an element
    data.count += 1;
  };


  func getKeyIndex<K, V>(data: Data<K, V>, compare: (K, K) -> O.Order, key: K): BS.SearchResult {
    BS.binarySearchNode<K, V>(data.kvs, compare, key, data.count);
  };


  // Inserts two rebalanced (split) child halves into a non-full array of children. 
  func insertRebalancedChild<K, V>(children: [var ?Node<K, V>], rebalancedChildIndex: Nat, leftChildInsert: Node<K, V>, rightChildInsert: Node<K, V>): () {
    // Note: BTree will always have an order >= 4, so this will never have negative Nat overflow
    var j: Nat = children.size() - 2;

    // This is just a sanity check to ensure the children aren't already full (should split promote otherwise)
    // TODO: Remove this check once confident
    if (Option.isSome(children[j+1])) { assert false }; 

    // Iterate backwards over the array and shift each element over to the right by one until the rebalancedChildIndex is hit
    while (j > rebalancedChildIndex) {
      children[j + 1] := children[j];
      j -= 1;
    };

    // Insert both the left and right rebalanced children (replacing the pre-split child)
    children[j] := ?leftChildInsert;
    children[j+1] := ?rightChildInsert;
  };


  // Used when splitting the children of an internal node
  //
  // Takes in the rebalanced child index, as well as both halves of the rebalanced child and splits the children, inserting the left and right child halves appropriately
  //
  // For more context, see the documentation for the splitArrayAndInsertTwo method in ArrayUtils.mo
  func splitChildrenInTwoWithRebalances<K, V>(children: [var ?Node<K, V>], rebalancedChildIndex: Nat, leftChildInsert: Node<K, V>, rightChildInsert: Node<K, V>): ([var ?Node<K, V>], [var ?Node<K, V>]) {
    AU.splitArrayAndInsertTwo<Node<K, V>>(children, rebalancedChildIndex, leftChildInsert, rightChildInsert);
  };


  /// Opinionated version of generating a textual representation of a BTree. Primarily to be used
  /// for testing and debugging
  public func toText<K, V>(t: BTree<K, V>, keyToText: K -> Text, valueToText: V -> Text): Text {
    var textOutput = "BTree={";
    textOutput #= "root=" # rootToText<K, V>(t.root, keyToText, valueToText) # "; ";
    textOutput #= "order=" # Nat.toText(t.order) # "; ";
    textOutput # "}";
  };


  /// Determines if two BTrees are equivalent
  public func equals<K, V>(
    t1: BTree<K, V>,
    t2: BTree<K, V>,
    keyEquals: (K, K) -> Bool,
    valueEquals: (V, V) -> Bool
  ): Bool {
    if (t1.order != t2.order) return false;

    nodeEquals(t1.root, t2.root, keyEquals, valueEquals);
  };


  func rootToText<K, V>(node: Node<K, V>, keyToText: K -> Text, valueToText: V -> Text): Text {
    var rootText = "{";
    switch(node) {
      case (#leaf(leafNode)) { rootText #= "#leaf=" # leafToText(leafNode, keyToText, valueToText) };
      case (#internal(internalNode)) {
        rootText #= "#internal=" # internalToText(internalNode, keyToText, valueToText) 
      };
    }; 

    rootText;
  };

  func leafToText<K, V>(leaf: Leaf<K, V>, keyToText: K -> Text, valueToText: V -> Text): Text {
    var leafText = "{data=";
    leafText #= dataToText(leaf.data, keyToText, valueToText); 
    leafText # "}";
  };

  func internalToText<K, V>(internal: Internal<K, V>, keyToText: K -> Text, valueToText: V -> Text): Text {
    var internalText = "{";
    internalText #= "data=" # dataToText(internal.data, keyToText, valueToText) # "; ";
    internalText #= "children=[";

    var i = 0;
    while (i < internal.children.size()) {
      switch(internal.children[i]) {
        case null { internalText #= "null" };
        case (?(#leaf(leafNode))) { internalText #= "#leaf=" # leafToText(leafNode, keyToText, valueToText) };
        case (?(#internal(internalNode))) {
          internalText #= "#internal=" # internalToText(internalNode, keyToText, valueToText)
        };
      };
      internalText #= ", ";
      i += 1;
    };

    internalText # "]}";
  };

  func dataToText<K, V>(data: Data<K, V>, keyToText: K -> Text, valueToText: V -> Text): Text {
    var dataText = "{kvs=[";
    var i = 0;
    while (i < data.kvs.size()) {
      switch(data.kvs[i]) {
        case null { dataText #= "null, " };
        case (?(k, v)) {
          dataText #= "(key={" # keyToText(k) # "}, value={" # valueToText(v) # "}), "
        }
      };

      i += 1;
    };

    dataText #= "]; count=" # Nat.toText(data.count) # ";}";
    dataText;
  };

  
  func nodeEquals<K, V>(
    n1: Node<K, V>,
    n2: Node<K, V>,
    keyEquals: (K, K) -> Bool,
    valueEquals: (V, V) -> Bool
  ): Bool {
    switch(n1, n2) {
      case (#leaf(l1), #leaf(l2)) { 
        dataEquals(l1.data, l2.data, keyEquals, valueEquals);
      };
      case (#internal(i1), #internal(i2)) {
        dataEquals(i1.data, i2.data, keyEquals, valueEquals)
        and
        childrenEquals(i1.children, i2.children, keyEquals, valueEquals)
      };
      case _ { false };
    };
  };

  func childrenEquals<K, V>(
    c1: [var ?Node<K, V>],
    c2: [var ?Node<K, V>],
    keyEquals: (K, K) -> Bool,
    valueEquals: (V, V) -> Bool
  ): Bool {
    if (c1.size() != c2.size()) { return false };

    var i = 0;
    while (i < c1.size()) {
      switch(c1[i], c2[i]) {
        case (null, null) {};
        case (?n1, ?n2) { 
          if (not nodeEquals(n1, n2, keyEquals, valueEquals)) {
            return false;
          }
        };
        case _ { return false }
      };

      i += 1;
    };

    true
  };

  func dataEquals<K, V>(
    d1: Data<K, V>,
    d2: Data<K, V>,
    keyEquals: (K, K) -> Bool,
    valueEquals: (V, V) -> Bool
  ): Bool {
    if (d1.count != d2.count) { return false };
    if (d1.kvs.size() != d2.kvs.size()) { return false };

    var i = 0;
    while(i < d1.kvs.size()) {
      switch(d1.kvs[i], d2.kvs[i]) {
        case (null, null) {};
        case (?(k1, v1), ?(k2, v2)) {
          if (
            (not keyEquals(k1, k2))
            or
            (not valueEquals(v1, v2))
          ) { return false };
        };
        case _ { return false };
      };

      i += 1;
    };

    true;
  };

}