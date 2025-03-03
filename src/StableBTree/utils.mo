import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Order "mo:base/Order";
import Int "mo:base/Int";

module {

  // For convenience: from base module
  type Buffer<T> = Buffer.Buffer<T>;
  type Order = Order.Order;
  type Result<K, V> = Result.Result<K, V>;

  /// Creates a buffer from an array
  public func toBuffer<T>(x :[T]) : Buffer<T>{
    let thisBuffer = Buffer.Buffer<T>(x.size());
    for(thisItem in x.vals()){
      thisBuffer.add(thisItem);
    };
    return thisBuffer;
  };

  /// Append two arrays using a buffer
  public func append<T>(left: [T], right: [T]) : [T] {
    let buffer = Buffer.Buffer<T>(left.size());
    for(val in left.vals()){
      buffer.add(val);
    };
    for(val in right.vals()){
      buffer.add(val);
    };
    return buffer.toArray();
  };

  /// Splits the buffers into two at the given index.
  /// The right buffer contains the element at the given index
  /// similarly to the Rust's vec::split_off method
  public func splitOff<T>(buffer: Buffer<T>, idx: Nat) : Buffer<T>{
    var tail = List.nil<T>();
    while(buffer.size() > idx){
      switch(buffer.removeLast()){
        case(null) { assert(false); };
        case(?last){
          tail := List.push<T>(last, tail);
        };
      };
    };
    toBuffer<T>(List.toArray(tail));
  };

  /// Insert an element into the buffer at given index
  public func insert<T>(buffer: Buffer<T>, idx: Nat, elem: T) {
    let tail = splitOff(buffer, idx);
    buffer.add(elem);
    buffer.append(tail);
  };

  /// Remove an element from the buffer at the given index
  /// Traps if index is out of bounds.
  public func remove<T>(buffer: Buffer<T>, idx: Nat) : T {
    let tail = splitOff(buffer, idx + 1);
    switch(buffer.removeLast()){
      case(null) { Debug.trap("Index is out of bounds."); };
      case(?elem) {
        buffer.append(tail);
        elem;
      };
    };
  };

  /// Searches the element in the ordered array.
  public func binarySearch<T>(array: [T], order: (T, T) -> Order, elem: T) : Result<Nat, Nat> {
    // Return index 0 if array is empty
    if (array.size() == 0){
      return #err(0);
    };
    // Initialize search from first to last index
    var left : Nat = 0;
    var right : Int = array.size() - 1; // Right can become less than 0, hence the integer type
    // Search the array
    while (left < right) {
      let middle = Int.abs(left + (right - left) / 2);
      switch(order(elem, array[middle])){
        // If the element is present at the middle itself
        case(#equal) { return #ok(middle); };
        // If element is greater than mid, it can only be present in left subarray
        case(#greater) { left := middle + 1; };
        // If element is smaller than mid, it can only be present in right subarray
        case(#less) { right := middle - 1; };
      };
    };
    // The search did not find a match
    switch(order(elem, array[left])){
      case(#equal) { return #ok(left); };
      case(#greater) { return #err(left + 1); };
      case(#less) { return #err(left); };
    };
  };

  /// *Copied from the motoko-base library*
  ///
  /// Defines comparison for two arrays, using `compare` to recursively compare elements in the
  /// arrays. Comparison is defined lexicographically.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func lexicographicallyCompare<X>(array1 : [X], array2 : [X], compare : (X, X) -> Order.Order) : Order.Order {
    let size1 = array1.size();
    let size2 = array2.size();
    let minSize = if (size1 < size2) { size1 } else { size2 };

    var i = 0;
    while (i < minSize) {
      switch (compare(array1[i], array2[i])) {
        case (#less) {
          return #less;
        };
        case (#greater) {
          return #greater;
        };
        case _ {};
      };
      i += 1;
    };

    if (size1 < size2) {
      #less;
    } else if (size1 == size2) {
      #equal;
    } else {
      #greater;
    };
  };

  /// *Copied from the motoko-base library*
  ///
  /// Checks if `prefix` is a prefix of `array`. Uses `equal` to
  /// compare elements.
  ///
  /// Runtime: O(size of prefix)
  ///
  /// Space: O(size of prefix)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func isPrefixOf<X>(prefix : [X], array : [X], equal : (X, X) -> Bool) : Bool {
    let sizePrefix = prefix.size();
    if (array.size() < sizePrefix) {
      return false;
    };

    var i = 0;
    while (i < sizePrefix) {
      if (not equal(array[i], prefix[i])) {
        return false;
      };

      i += 1;
    };

    return true;
  };

  /// Check if the array is sorted in increasing order.
  public func isSortedInIncreasingOrder<T>(array: [T], order: (T, T) -> Order) : Bool {
    let size_array = array.size();
    var idx : Nat = 0;
    // Iterate on the array
    while (idx + 1 < size_array){
      switch(order(array[idx], array[idx + 1])){
        case(#greater) { 
          // Previous is greater than next, wrong order
          return false;
        };
        case(_) {}; // Previous is less or equal than next, continue iterating
      };
      idx += 1;
    };
    // All elements have been checked one to one, the array is sorted.
    return true;
  };

};