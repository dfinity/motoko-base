/// A module containing a BTree specific binary search helper function

import O "mo:base/Order";


module {
  public type SearchResult = {
    #keyFound: Nat;
    #notFound: Nat;
  };
  
  /// Searches an array for a specific key, returning the index it occurs at if #keyFound, or the child/insert index it may occur at 
  /// if #notFound. This is used when determining if a key exists in an internal or leaf node, where a key should be inserted in a
  /// leaf node, or which child of an internal node a key could be in.
  ///
  /// Note: This function expects a mutable, nullable, array of keys in sorted order, where all nulls appear at the end of the array.
  /// This function may trap if a null value appears before any values. It also expects a maxIndex, which is the right-most index (bound) 
  /// from which to begin the binary search (the left most bound is expected to be 0)
  ///
  /// Parameters:
  ///
  /// * array - the sorted array that the binary search is performed upon
  /// * compare - the comparator used to perform the search
  /// * searchKey - the key being compared against in the search
  /// * maxIndex - the right-most index (bound) from which to begin the search 
  public func binarySearchNode<K, V>(array: [var ?(K, V)], compare: (K, K) -> O.Order, searchKey: K, maxIndex: Nat): SearchResult {
    // TODO: get rid of this check?
    // Trap if array is size 0 (should not happen) 
    if (array.size() == 0){
      assert false;
    };

    // if all elements in the array are null (i.e. first element is null), return #notFound(0)
    if (maxIndex == 0) {
      return #notFound(0)
    };

    // Initialize search from first to last index
    var left : Nat = 0;
    var right = maxIndex; // maxIndex does not necessarily mean array.size() - 1
    // Search the array
    while (left < right) {
      let middle = (left + right) / 2;
      switch(array[middle]) {
        case null { assert false; };
        case (?(key, _)) {
          switch(compare(searchKey, key)){
            // If the element is present at the middle itself
            case(#equal) { return #keyFound(middle); };
            // If element is greater than mid, it can only be present in left subarray
            case(#greater) { left := middle + 1; };
            // If element is smaller than mid, it can only be present in right subarray
            case(#less) { 
              right := if (middle == 0) { 0 } else { middle - 1 }; 
            };
          };
        }
      }
    };

    if (left == array.size()) {
      return #notFound(left);
    };

    // left == right
    switch(array[left]) {
      // inserting at end of array
      case null { #notFound(left) };
      case (?(key, _)) {
        switch(compare(searchKey, key)){
          // if left is the key
          case(#equal) { #keyFound(left); };
          // if the key is not found, return notFound and the insert location
          case(#greater) { #notFound(left + 1); };
          case(#less) { #notFound(left); };
        };
      }
    }
  };
}