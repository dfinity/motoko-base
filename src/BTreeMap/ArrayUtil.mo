/// A collection of Array utility functions **specific** to the BTree implementation

import Array "mo:base/Array";


module {
  /// Inserts an element into a mutable array at a specific index, shifting all other elements over
  ///
  /// Parameters:
  ///
  /// array - the array being inserted into
  /// insertElement - the element being inserted
  /// insertIndex - the index at which the element will be inserted
  /// currentLastElementIndex - the index of last **non-null** element in the array (used to start shifting elements over)
  ///
  /// Note: This assumes that there are nulls at the end of the array and that the array is not full.
  /// If the array is already full, this function will overflow the array size when attempting to
  /// insert and will cause the cansiter to trap
  public func insertAtPosition<T>(array: [var ?T], insertElement: ?T, insertIndex: Nat, currentLastElementIndex: Nat): () {
    // if inserting at the end of the array, don't need to do any shifting and can just insert and return
    if (insertIndex == currentLastElementIndex + 1) {
      array[insertIndex] := insertElement;
      return;
    };

    // otherwise, need to shift all of the elements at the end of the array over one by one until
    // the insert index is hit.
    var j = currentLastElementIndex;
    label l loop {
      array[j+1] := array[j];
      if (j == insertIndex) {
        array[j] := insertElement;
        break l;
      };

      j -= 1;
    };
  };


  
  /// Splits the array into two halves as if the insert has occured, omitting the middle element and returning it so that it can
  /// be promoted to the parent internal node. This is used when inserting an element into an array of key-value data pairs that 
  /// is already full.
  ///
  /// Note: Use only when inserting an element into a FULL array & promoting the resulting midpoint element.
  /// This is NOT the same as just splitting this array!
  ///
  /// Parameters:
  ///
  /// array - the array being split
  /// insertElement - the element being inserted
  /// insertIndex - the position/index that the insertElement should be inserted
  public func insertOneAtIndexAndSplitArray<T>(array: [var ?T], insertElement: T, insertIndex: Nat): ([var ?T], T, [var ?T]) {
    // split at the BTree order / 2
    let splitIndex = (array.size() + 1) / 2;
    // this function assumes the the splitIndex is in the middle of the kvs array - trap otherwise
    if (splitIndex > array.size()) { assert false; };

    let leftSplit = 
      if (insertIndex < splitIndex) {
        Array.tabulateVar<?T>(array.size(), func(i) {
          // if below the split index
          if (i < splitIndex) { 
            // if below the insert index, copy over
            if (i < insertIndex) { array[i] }
            // if less than the insert index, copy over the previous element (since the inserted element has taken up 1 extra slot)
            else if (i > insertIndex) { array[i-1] }
            // if equal to the insert index add the element to be inserted to the left split
            else { ?insertElement }
          }
          else { null }
        });
      } 
      // index >= splitIndex
      else {
        Array.tabulateVar<?T>(array.size(), func(i) {
          // right biased splitting
          if (i < splitIndex) { array[i] } 
          else { null }
        });
      };

    let (rightSplit, middleElement): ([var ?T], ?T) = 
      // if insert > split index, inserted element will be inserted into the right split
      if (insertIndex > splitIndex) {
        let right = Array.tabulateVar<?T>(array.size(), func(i) {
          let adjIndex = i + splitIndex + 1; // + 1 accounts for the fact that the split element was part of the original array
          if (adjIndex <= array.size()) {
            if (adjIndex < insertIndex) { array[adjIndex] }
            else if (adjIndex > insertIndex) { array[adjIndex-1] }
            else { ?insertElement }
          } 
          else { null }
        });
        (right, array[splitIndex]);
      } 
      // if inserted element was placed in the left split
      else if (insertIndex < splitIndex) {
        let right = Array.tabulateVar<?T>(array.size(), func(i) {
          let adjIndex = i + splitIndex;
          if (adjIndex < array.size()) { array[adjIndex] } 
          else { null }
        });
        (right, array[splitIndex-1]);
      } 
      // insertIndex == splitIndex
      else {
        let right = Array.tabulateVar<?T>(array.size(), func(i) {
          let adjIndex = i + splitIndex;
          if (adjIndex < array.size()) { array[adjIndex] } 
          else { null }
        });
        (right, ?insertElement);
      };

    switch(middleElement) {
      case null { assert false; loop {} }; // Trap, as this should never happen
      case (?el) { (leftSplit, el, rightSplit) }
    }
  };


  
  /// Context of use: This function is used after inserting a child node into the full child of an internal node that is also full. 
  /// From the insertion, the full child is rebalanced and split, and then since the internal node is full, when replacing the two
  /// halves of that rebalanced child into the internal node's children this causes a second split. This function takes in the 
  /// internal node's children, and the "rebalanced" split child nodes, as well as the index at which the "rebalanced" left and right 
  /// child will be inserted and replaces the original child with those two halves
  ///
  /// Note: Use when inserting two successive elements into a FULL array and splitting that array.
  /// This is NOT the same as just splitting this array!
  ///
  /// Assumptions: this function also assumes that the children array is full (no nulls)
  ///
  /// Parameters:
  /// 
  /// children - the internal node's children array being split
  /// rebalancedChildIndex - the index used to mark where the rebalanced left and right children will be inserted
  /// leftChildInsert - the rebalanced left child being inserted
  /// rightChildInsert - the rebalanced right child being inserted
  public func splitArrayAndInsertTwo<T>(children: [var ?T], rebalancedChildIndex: Nat, leftChildInsert: T, rightChildInsert: T): ([var ?T], [var ?T]) {
    let splitIndex = children.size() / 2;

    let leftRebalancedChildren = Array.tabulateVar<?T>(children.size(), func(i) {
      // only insert elements up to the split index and fill the rest of the children with nulls
      if (i <= splitIndex) { 
        if (i < rebalancedChildIndex) { children[i] }
        // insert the left and right rebalanced child halves if the rebalancedChildIndex comes before the splitIndex
        else if (i == rebalancedChildIndex) { ?leftChildInsert }
        else if (i == rebalancedChildIndex + 1) { ?rightChildInsert }
        else { children[i-1] } // i > rebalancedChildIndex
      } else { null }
    });

    let rightRebalanceChildren: [var ?T] = 
      // Case 1: if both left and right rebalanced halves were inserted into the left child can just go from the split index onwards
      if (rebalancedChildIndex + 1 <= splitIndex) {
        Array.tabulateVar<?T>(children.size(), func(i) {
          let adjIndex = i + splitIndex;
          if (adjIndex < children.size()) { children[adjIndex] }
          else { null }
        })
      } 
      // Case 2: if both left and right rebalanced halves will be inserted into the right child
      else if (rebalancedChildIndex > splitIndex) {
        var rebalanceOffset = 0;
        Array.tabulateVar<?T>(children.size(), func(i) {
          let adjIndex = i + splitIndex + 1;
          if (adjIndex == rebalancedChildIndex) { ?leftChildInsert }
          else if (adjIndex == rebalancedChildIndex + 1) { 
            rebalanceOffset := 1; // after inserting both rebalanced children, any elements coming after are from the previous index 
            ?rightChildInsert;
          } else if (adjIndex <= children.size()) { children[adjIndex - rebalanceOffset] }
          else { null }
        })
      }  
      // Case 3: if left rebalanced half was in left child, and right rebalanced half will be in right child
      // rebalancedChildIndex == splitIndex
      else { 
        Array.tabulateVar<?T>(children.size(), func(i) {
          // first element is the right rebalanced half
          if (i == 0) { ?rightChildInsert }
          else {
            let adjIndex = i + splitIndex;
            if (adjIndex < children.size()) { children[adjIndex] }
            else { null }
          }
        })
      };

    (leftRebalancedChildren, rightRebalanceChildren)
  };

}