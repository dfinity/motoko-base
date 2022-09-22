/// Generic, extensible buffers
///
/// Generic, mutable sequences that grow to accommodate arbitrary numbers of elements.
///
/// Class `Buffer<X>` provides extensible, mutable sequences of elements of type `X`.
/// that can be efficiently produced and consumed with imperative code.
/// A buffer object can be extended by a single element or the contents of another buffer object.
///
/// When required, the current state of a buffer object can be converted to a fixed-size array of its elements.
///
/// Buffers complement Motoko's non-extensible array types
/// (arrays do not support efficient extension, because the size of an array is
/// determined at construction and cannot be changed).

import Prim "mo:⛔";
import Result "Result";
import Order "Order";

module {
  type Order = Order.Order;

  /// Create a stateful buffer class encapsulating a mutable array.
  ///
  /// The argument `initCapacity` determines its initial capacity.
  /// The underlying mutable array grows by doubling when its current
  /// capacity is exceeded.
  public class Buffer<X>(initCapacity : Nat) {
    var count : Nat = 0;
    var elems : [var X] = [var]; // initially empty; allocated upon first `add`

    /// Adds a single element to the buffer.
    public func add(elem : X) {
      if (count == elems.size()) {
        if (elems.size() == 0) {
          elems := Prim.Array_init(if (initCapacity > 0) { initCapacity } else { 1 }, elem);
          count += 1;
          return;
        } else {
          resize(elems.size() * 2);
        };
      };
      elems[count] := elem;
      count += 1;
    };

    /// Removes the item that was inserted last and returns it or `null` if no
    /// elements had been added to the Buffer.
    public func removeLast() : ?X {
      if (count == 0) {
        return null;
      };

      let lastElement = ?elems[count - 1];
      count -= 1;

      if (count < elems.size() / 4) { // avoid thrashing
        resize(elems.size() / 2) // will downsize to an array of size 2 at minimum
      };

      lastElement
    };

    public func remove(index : Nat) : ?X {
      if (index >= count) {
        return null;
      };

      let element = ?elems[index];

      // resize down and shift over in one pass
      if ((count - 1) : Nat < elems.size() / 4) { 
        let elems2 = Prim.Array_init<X>(elems.size() / 2, elems[0]);

        var i = 0;
        var j = 0;
        label l while (i < count) {
          if (i == index) {
            i += 1;
            continue l;
          };

          elems2[j] := elems[i];
          i += 1;
          j += 1;
        };
        elems := elems2;
      } else { // just shift over elements
        var i = index;
        while (i < (count - 1 : Nat)) {
          elems[i] := elems[i + 1];
          i += 1;
        };
      };

      count -= 1;
      element
    };

    public func filter(predicate : (Nat, X) -> Bool) { 
      var removeCount = 0;
      let keep = 
        Prim.Array_tabulate<Bool>(
          count,
          func i {
            if (predicate(i, elems[i])) {
              true
            } else {
              removeCount += 1;
              false
            }
          }
        );
      
      let elemsSize = elems.size();

      var original = elems;
      if ((count - removeCount : Nat) < elemsSize / 4) {
        elems := Prim.Array_init<X>(elemsSize / 2, elems[0]);
      };

      var i = 0;
      var j = 0;
      while (i < count) {
        if (keep[i]) {
          elems[j] := original[i];
          i += 1;
          j += 1;
        } else {
          i += 1;
        }
      };

      count -= removeCount;
    };

    // traps on OOB
    // traps if never added any element to buffer before
    public func resize(size : Nat) {
      if (size < count) {
        Prim.trap "Size is too small to hold all elements in Buffer after resizing"
      };
      if (elems.size() == 0) { // Do NOT let the underlying array become empty after initial Add
        Prim.trap "Must first add an element to buffer before resizing"
      };

      let elems2 = Prim.Array_init<X>(size, elems[0]);

      var i = 0;
      while (i < count) {
        elems2[i] := elems[i];
        i += 1;
      };
      elems := elems2;
    };

    /// Adds all elements in buffer `b` to this buffer.
    public func append(buffer2 : Buffer<X>) {
      let count2 = buffer2.size();
      // Make sure you only resize once
      if (count + count2 > elems.size()) {
        if (elems.size() == 0) { // Can't call resize in this case
          if (count2 == 0) {
            return;
          } else {
            elems := Prim.Array_init(count + count2, buffer2.get(0));
          }
        } else {
          resize(count + count2);
        }
      };
      var i = 0;
      while (i < count2) {
        add(buffer2.get(i));
        i += 1;
      };
    };

    public func insert(index : Nat, element : X) {
      if (index > count) {
        Prim.trap "Buffer index out of bounds in insert"
      };

      if (count + 1 > elems.size()) {
        let elems2 = Prim.Array_init<X>(count + 1, element);
        var i = 0;
        while (i < count + 1) {
          if (i < index) {
            elems2[i] := elems[i];
          } else if (i > index) {
            elems2[i] := elems[i - 1];
          };
          
          i += 1;
        };
        elems := elems2;
      }
      else {
        var i : Nat = count - 1;
        while (i > index) {
          elems[i] := elems[i - 1];
          i -= 1;
        };
        elems[index] := element;
      };

      count += 1;
    };

    public func insertBuffer(buffer2 : Buffer<X>, index : Nat) {
      let count2 = buffer2.size();
      if (index > count) {
        Prim.trap "Buffer index out of bounds in insertAt"
      };

      // resize and insert in one go
      if (count + count2 > elems.size()) {
        let elems2 =
          if (count2 == 0) {
            return;
          } else {
            Prim.Array_init<X>(count + count2, buffer2.get(0))
          };
        var i = 0;
        while (i < count + count2) {
          if (i < index) {
            elems2[i] := elems[i];
          }
          else if (i >= index and i < index + count2) {
            elems2[i] := buffer2.get(i - index);
          }
          else {
            elems2[i] := elems[i - count2];
          };

          i += 1;
        };
        elems := elems2;
      } 
      // just insert
      else {
        var i = index;
        while (i < index + count2) {
          elems[i + count2] := elems[i];
          elems[i] := buffer2.get(i - index);

          i += 1;
        }
      };

      count += count2;
    };

    /// Returns the current number of elements.
    public func size() : Nat = count;

    /// Resets the buffer.
    public func clear() {
      count := 0;
      resize(2); // Same downsize minimum as the remove methods
    };

    // FIXME move outside of class?
    /// Returns a copy of this buffer.
    public func clone() : Buffer<X> {
      let newBuffer = Buffer<X>(elems.size());
      var i = 0;
      while (i < count) {
        newBuffer.add(elems[i]);
        i += 1;
      };
      newBuffer
    };

    /// Returns an `Iter` over the elements of this buffer.
    public func vals() : { next : () -> ?X } = object {
      var pos = 0;
      public func next() : ?X {
        if (pos == count) {
          null
        } else {
          let elem = ?elems[pos];
          pos += 1;
          elem
        }
      }
    };

    // FIXME move outside of class?
    /// Creates a new array containing this buffer's elements.
    public func toArray() : [X] =
      // immutable clone of array
      Prim.Array_tabulate<X>(
        count,
        func(x : Nat) : X { elems[x] }
      );

    // FIXME move outside of class?
    /// Creates a mutable array containing this buffer's elements.
    public func toVarArray() : [var X] {
      if (count == 0) { 
        [var]
      } else {
        let newArray = Prim.Array_init<X>(count, elems[0]);
        var i = 0;
        while (i < count) {
          newArray[i] := elems[i];
          i += 1;
        };
        newArray
      }
    };

    /// Gets the `i`-th element of this buffer. Traps if  `i >= count`. Indexing is zero-based.
    public func get(i : Nat) : X {
      if (i >= count) {
        Prim.trap "Buffer index out of bounds in get";
      };
      elems[i]
    };

    /// Gets the `i`-th element of the buffer as an option. Returns `null` when `i >= count`. Indexing is zero-based.
    public func getOpt(i : Nat) : ?X {
      if (i < count) {
        ?elems[i]
      }
      else {
        null
      }
    };

    /// Overwrites the current value of the `i`-entry of  this buffer with `elem`. Traps if the
    /// index is out of bounds. Indexing is zero-based.
    public func put(i : Nat, elem : X) {
      elems[i] := elem;
    };
  };

  public func trimToSize<X>(buffer : Buffer<X>) {
    buffer.resize(if (buffer.size() == 0) { 1 } else { buffer.size() });
  };

  /// Creates a buffer from immutable array elements.
  public func fromArray<X>(elems : [X]) : Buffer<X> {
    let count = elems.size();
    let newBuffer = Buffer<X>(count);

    var i = 0;
    while (i < count) {
      newBuffer.add(elems.get(i));
      i += 1;
    };

    newBuffer
  };

  /// Creates a buffer from the elements of a mutable array.
  public func fromVarArray<X>(elems : [var X]) : Buffer<X> {
    let count = elems.size();
    let newBuffer = Buffer<X>(count);

    var i = 0;
    while (i < count) {
      newBuffer.add(elems.get(i));
      i += 1;
    };

    newBuffer
  };

  public func map<X, Y>(buffer : Buffer<X>, f : X -> Y) : Buffer<Y> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(count);
    
    var i = 0;
    while (i < count) {
      newBuffer.add(f(buffer.get(i)));
      i += 1;
    };

    newBuffer
  };

  public func iterate<X>(buffer : Buffer<X>, f : X -> ()) {
    let count = buffer.size();

    var i = 0;
    while (i < count) {
      f(buffer.get(i));
      i += 1;
    };
  };

  public func chain<X, Y>(buffer : Buffer<X>, k : X -> Buffer<Y>) : Buffer<Y> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(count);
    
    var i = 0;
    while (i < count) {
      let results = k(buffer.get(i));
      newBuffer.append(results);
      i += 1;
    };

    newBuffer
  };

  public func mapFilter<X, Y>(buffer : Buffer<X>, f : X -> ?Y) : Buffer<Y> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(count);
    
    var i = 0;
    while (i < count) {
      switch (f(buffer.get(i))) {
        case (?element) {
          newBuffer.add(element);
        };
        case _ {};
      };

      i += 1;
    };

    newBuffer
  };

  public func mapEntries<X, Y>(buffer : Buffer<X>, f : (Nat, X) -> Y) : Buffer<Y> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(count);
    
    var i = 0;
    while (i < count) {
      newBuffer.put(i, f(i, buffer.get(i)));
      i += 1;
    };

    newBuffer
  };

  public func mapResult<X, Y, E>(buffer : Buffer<X>, f : X -> Result.Result<Y, E>) : Result.Result<Buffer<Y>, E> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(count);
    
    var i = 0;
    while (i < count) {
      switch(f(buffer.get(i))) {
        case (#ok result) {
          newBuffer.add(result);
        };
        case (#err e) {
          return #err e;
        }
      };

      i += 1;
    };

    #ok newBuffer
  };

  public func foldLeft<X, A>(buffer : Buffer<X>, base : A, combine : (A, X) -> A) : A {
    let count = buffer.size();
    var accumulation = base;
    
    var i = 0;
    while (i < count) {
      accumulation := combine(accumulation, buffer.get(i));
      i += 1;
    };

    accumulation
  };

  public func foldRight<X, A>(buffer : Buffer<X>, base : A, combine : (X, A) -> A) : A {
    let count = buffer.size();
    var accumulation = base;
    
    var i = 0;
    while (i < count) {
      accumulation := combine(buffer.get(count - i - 1), accumulation);
      i += 1;
    };

    accumulation
  };

  public func forAll<X>(buffer : Buffer<X>, predicate : X -> Bool) : Bool {
    let count = buffer.size();
    
    var i = 0;
    while (i < count) {
      if (not predicate(buffer.get(i))) {
        return false;
      };
      i += 1;
    };

    true
  };

  public func forSome<X>(buffer : Buffer<X>, predicate : X -> Bool) : Bool {
    let count = buffer.size();
    
    var i = 0;
    while (i < count) {
      if (predicate(buffer.get(i))) {
        return true;
      };
      i += 1;
    };

    false
  };

  public func forNone<X>(buffer : Buffer<X>, predicate : X -> Bool) : Bool {
    let count = buffer.size();
    
    var i = 0;
    while (i < count) {
      if (predicate(buffer.get(i))) {
        return false;
      };
      i += 1;
    };

    true
  };

  public func make<X>(element : X) : Buffer<X> {
    let newBuffer = Buffer<X>(1);
    newBuffer.add(element);
    newBuffer
  };

  public func contains<X>(buffer : Buffer<X>, element : X, equals : (X, X) -> Bool) : Bool {
    let count = buffer.size();
    var i = 0;
    while (i < count) {
      if (equals(buffer.get(i), element)) {
        return true;
      };
      i += 1;
    };

    false
  };

  public func max<X>(buffer : Buffer<X>, compare : (X, X) -> Order) : X {
    let count = buffer.size();
    if (count == 0) {
      Prim.trap "Cannot call max on an empty buffer"
    };

    var i = 0;
    var maxSoFar = buffer.get(0);
    while (i < count) {
      let current = buffer.get(i);
      switch(compare(current, maxSoFar)) {
        case (#greater) {
          maxSoFar := current
        };
        case _ {};
      };
      i += 1;
    };

    maxSoFar
  };

  public func min<X>(buffer : Buffer<X>, compare : (X, X) -> Order) : X {
    let count = buffer.size();
    if (count == 0) {
      Prim.trap "Cannot call min on an empty buffer"
    };

    var i = 0;
    var minSoFar = buffer.get(0);
    while (i < count) {
      let current = buffer.get(i);
      switch(compare(current, minSoFar)) {
        case (#less) { 
          minSoFar := current
        };
        case _ {};
      };
      i += 1;
    };

    minSoFar
  };

  public func isEmpty<X>(buffer : Buffer<X>) : Bool = buffer.size() == 0;

  public func removeDuplicates<X>(buffer : Buffer<X>, compare : (X, X) -> Order) {
    sort<X>(buffer, compare);

    buffer.filter(
      func (i, current) { 
        if (i == 0) {
          return true
        };

        switch(compare(buffer.get(i - 1), current)) {
          case (#equal) false;
          case _ true;
        }
      }
    );
  };

  // Should be a function of the logical list, not the underlying array
  public func hash<X>(buffer : Buffer<X>, hash : X -> Nat32) : Nat32 {
    let count = buffer.size();
    var i = 0;
    var accHash : Nat32 = 0;

    while (i < count) {
      accHash := Prim.intToNat32Wrap(i) ^ accHash ^ hash(buffer.get(i));
      i += 1;
    };

    accHash
  };

  public func toText<X>(buffer : Buffer<X>, toText : X -> Text) : Text {
    let count = buffer.size();
    var i = 0;
    var str = "";
    while (i < (count - 1 : Nat)) {
      str := str # toText(buffer.get(i)) # ", ";
      i += 1;
    };
    if (count > 0) {
      str := str # toText(buffer.get(i))
    };

    "[" # str # "]"
  };

  public func flatten<X>(buffer : Buffer<Buffer<X>>) : Buffer<X> {
    let count = buffer.size();
    let newBuffer = Buffer<X>(count);
    
    var i = 0;
    while (i < count) {
      let innerBuffer = buffer.get(i);
      let innerCount = innerBuffer.size();
      var j = 0;
      while (j < innerCount) {
        newBuffer.add(innerBuffer.get(j));
        j += 1;
      };
      i += 1;
    };

    newBuffer
  };

  public func partition<X>(buffer : Buffer<X>, predicate : X -> Bool) : (Buffer<X>, Buffer<X>) {
    let count = buffer.size();
    let trueBuffer = Buffer<X>(count);
    let falseBuffer = Buffer<X>(count);
    
    var i = 0;
    while (i < count) {
      let element = buffer.get(i);
      if (predicate element) {
        trueBuffer.add(element);
      } else {
        falseBuffer.add(element);
      };

      i += 1;
    };

    (trueBuffer, falseBuffer)
  };

  public func merge<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, compare : (X, X) -> Order) : Buffer<X> {
    let count1 = buffer1.size();
    let count2 = buffer2.size();

    let newBuffer = Buffer<X>(count1 + count2);

    var pointer1 = 0;
    var pointer2 = 0;

    while (pointer1 < count1 and pointer2 < count2) {
      let current1 = buffer1.get(pointer1);
      let current2 = buffer2.get(pointer2);

      switch(compare(current1, current2)) {
        case (#less) {
          newBuffer.add(current1);
          pointer1 += 1;
        };
        case _ {
          newBuffer.add(current2);
          pointer2 += 1;
        }
      };
    };

    while (pointer1 < count1) {
      newBuffer.add(buffer1.get(pointer1));
      pointer1 += 1;
    };

    while (pointer2 < count2) {
      newBuffer.add(buffer2.get(pointer2));
      pointer2 += 1;
    };

    newBuffer
  };

  public func sort<X>(buffer : Buffer<X>, compare : (X, X) -> Order) {
    let count = buffer.size();
    if (count < 2) {
      return;
    };
    let aux = Prim.Array_init<X>(count, buffer.get(0));

    func merge(lo : Nat, mid : Nat, hi : Nat) {
      var i = lo;
      var j = mid + 1;
      var k = lo;
      while(k <= hi) {
        aux[k] := buffer.get(k);
        k += 1;
      };
      k := lo;
      while(k <= hi) {
        if (i > mid) {
          buffer.put(k, aux[j]);
          j += 1;
        } else if (j > hi) {
          buffer.put(k, aux[i]);
          i += 1;
        } else if (Order.isLess(compare(aux[j], aux[i]))) {
          buffer.put(k, aux[j]);
          j += 1;
        } else {
          buffer.put(k, aux[i]);
          i += 1;
        };
        k += 1;
      };
    };

    func sortHelper(lo : Nat, hi : Nat) {
      if (hi <= lo) {
        return;
      };
      let mid : Nat = lo + (hi - lo) / 2;
      sortHelper(lo, mid);
      sortHelper(mid + 1, hi);
      merge(lo, mid, hi);
    };

    sortHelper(0, count - 1);
  };

  public func split<X>(buffer : Buffer<X> , index : Nat) : (Buffer<X>, Buffer<X>) {
    let count = buffer.size();

    if (index < 0 or index > count) {
      Prim.trap "Index out of bounds in split"
    };

    let buffer1 = Buffer<X>(count);
    let buffer2 = Buffer<X>(count);

    var i = 0;
    while (i < count) {
      let element = buffer.get(i);
      if (i < index) {
        buffer1.add(element);
      } else {
        buffer2.add(element);
      };

      i += 1;
    };

    (buffer1, buffer2)
  };

  public func zip<X, Y>(buffer1 : Buffer<X>, buffer2 : Buffer<Y>) : Buffer<(X, Y)> {
    let count1 = buffer1.size();
    let count2 = buffer2.size();
    let minCount = if (count1 < count2) { count1 } else { count2 };
    let newBuffer = Buffer<(X, Y)>(minCount);

    var i = 0;
    while (i < minCount) {
      let current1 = buffer1.get(i);
      let current2 = buffer2.get(i);

      newBuffer.add((current1, current2));
      i += 1;
    };

    newBuffer
  };

  public func zipWith<X, Y, Z>(buffer1 : Buffer<X>, buffer2 : Buffer<Y>, zip : (X, Y) -> Z) : Buffer<Z> {
    let count1 = buffer1.size();
    let count2 = buffer2.size();
    let minCount = if (count1 < count2) { count1 } else { count2 };
    let newBuffer = Buffer<Z>(minCount);

    var i = 0;
    while (i < minCount) {
      let current1 = buffer1.get(i);
      let current2 = buffer2.get(i);

      newBuffer.add(zip(current1, current2));
      i += 1;
    };

    newBuffer
  };

  // Documentation should warn of combinatorial explosion
  // Combinations are lazily produced and thus vulnerable to mutations in underlying buffer
  public func combinations<X>(buffer : Buffer<X>, groupSize : Nat) : { next : () -> ?Buffer<X> } = object {
    let count = buffer.size();
    let current = Prim.Array_init<Nat>(groupSize, 0);
    var r = 0; // index for current combination
    var i = 0; // index for buffer
    
    public func next() : ?Buffer<X> {
      if (count < groupSize or (count == 0 and groupSize == 0) or r < 0) {
        return null;
      };

      while (r >= 0){
        // forward step
        if (i <= count + (r - groupSize : Nat)){
          current[r] := i;
            
          // if current array is full, add it to combinations and move to next element in buffer
          if (r == (groupSize - 1 : Nat)){
            var j = 0;
            let combination = Buffer<X>(groupSize);
            while (j < groupSize) {
              combination.add(buffer.get(current[j]));
            };
            i += 1;

            return ?combination;
          } else {
            // if current is not full yet, select next element
            i := current[r] + 1;
            r += 1;
          }				
        } else { // backward step
          r -= 1;
          if (r >= 0) {
            i := current[r] + 1;
          }
        }			
      };

      null
    };
  };
  
  public func permutations<X>(buffer : Buffer<X>) : { next : () -> ?Buffer<X> } = object {
    let count = buffer.size();
    let indices = Prim.Array_init<Nat>(count, 0);
    var increase = 0;
    var initialized = false;

    public func next() : ?Buffer<X> {
      if (increase == (count - 1 : Nat)) {
        return null;
      };

      if (not initialized) {
        var i = 0;
        while (i < count) {
          indices[i] := i;
          i += 1;
        };
        initialized := true;
      } else if (increase == 0) {
        swap(increase, increase + 1);

        increase += 1;
        while (increase < (count - 1 : Nat) and indices[increase] > indices[increase + 1]) {
          increase += 1;
        }
      } else {
        if (indices[increase + 1] > indices[0]) {
          swap(increase + 1, 0);
        } else {
          // Binary search to find the greatest value that is less than indices[increase + 1]
          var start = 0;
          var end = increase;
          var mid = (start + end) / 2;
          let target = indices[increase + 1];
          while (not (indices[mid] < target and indices[mid - 1] > target)) {
            if (indices[mid] < target) {
              end := mid - 1;
            } else {
              start := mid + 1;
            };

            mid := (start + end) / 2;
          };

          swap(increase + 1, mid);
        };

        // Reverse elements from 0 through increase
        var i = 0;
        while (i <= increase / 2) {
          swap(i, increase - i);
          i += 1;
        };

        increase := 0;
      };

      ?output()
    };

    private func output() : Buffer<X> {
      let permutation = Buffer<X>(count);
      var i = 0;
      while (i < count) {
        permutation.add(buffer.get(indices[i]));

        i += 1;
      };

      permutation
    };

    private func swap(index1 : Nat, index2 : Nat) {
      let temp = indices[index1];
      indices[index1] := indices[index2];
      indices[index2] := temp;
    }
  };

  public func chunk<X>(buffer : Buffer<X>, size : Nat) : Buffer<Buffer<X>> {
    if (size == 0) {
      Prim.trap "Chunk size must be non-zero"
    };

    let count = buffer.size();
    let newBuffer = Buffer<Buffer<X>>(Prim.abs(Prim.floatToInt(Prim.floatCeil(Prim.intToFloat(count) / Prim.intToFloat(size)))));

    var i = 0;
    while (i < count) {
      let newInnerBuffer = Buffer<X>(size);
      var j = i;

      while (j < i + size and j < count) {
        newInnerBuffer.add(buffer.get(j));

        j += 1;
      };

      newBuffer.add(newInnerBuffer);

      i += size;
    };

    newBuffer
  };

  public func groupBy<X>(buffer : Buffer<X>, equal : (X, X) -> Bool) : Buffer<Buffer<X>> {
    let count = buffer.size();
    let newBuffer = Buffer<Buffer<X>>(count);

    var i = 0;
    while (i < count) {
      let newInnerBuffer = Buffer<X>(count - i);
      var j = i + 1;
      while (j < count and equal(buffer.get(j), newInnerBuffer.get(0))) {
        newInnerBuffer.add(buffer.get(j));

        j += 1;
      };

      newBuffer.add(newInnerBuffer);

      i += newInnerBuffer.size();
    };

    newBuffer
  };

  public func prefix<X>(buffer : Buffer<X>, end : Nat) : Buffer<X> {
    if (end > buffer.size()) {
      Prim.trap "Buffer index out of bounds in prefix"
    };

    let newBuffer = Buffer<X>(end);

    var i = 0;
    while (i < end) {
      newBuffer.add(buffer.get(i));

      i += 1;
    };

    newBuffer
  };

  public func isPrefixOf<X>(prefix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let prefixCount = prefix.size();
    let bufferCount = buffer.size();
    if (bufferCount < prefixCount) {
      return false;
    };

    var i = 0;
    while (i < prefixCount) {
      if (not equal(buffer.get(i), prefix.get(i))) {
        return false;
      };
      
      i += 1;
    };

    return true;
  };

  public func isStrictPrefixOf<X>(prefix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let prefixCount = prefix.size();
    let bufferCount = buffer.size();
    if (bufferCount <= prefixCount) {
      return false;
    };

    var i = 0;
    while (i < prefixCount) {
      if (not equal(buffer.get(i), prefix.get(i))) {
        return false;
      };
      
      i += 1;
    };

    return true;
  };

  public func infix<X>(buffer : Buffer<X>, start : Nat, end : Nat) : Buffer<X> {
    let count = buffer.size();
    if (start >= count or end > count) {
      Prim.trap "Buffer index out of bounds in infix"
    };

    let newBuffer = Buffer<X>(end - start);

    var i = start;
    while (i < end) {
      newBuffer.add(buffer.get(i));

      i += 1;
    };

    newBuffer
  };

  public func isInfixOf<X>(infix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    if (infix.size() > buffer.size()) {
      Prim.trap "Infix size must be at most buffer size in isInfixOf";
    };
    switch(indexOfBuffer(buffer, infix, equal)) {
      case null false;
      case _ true;
    }
  };

  public func isStrictInfixOf<X>(infix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let infixSize = infix.size();
    let bufferSize = buffer.size();
    if (infixSize > bufferSize) {
      Prim.trap "Infix size must be at most buffer size in isStrictInfixOf";
    };

    if (infixSize == bufferSize) {
      return false;
    };

    switch(indexOfBuffer(buffer, infix, equal)) {
      case null false;
      case _ true;
    }
  };

  public func suffix<X>(buffer : Buffer<X>, start : Nat) : Buffer<X> {
    let count = buffer.size();

    if (start >= count) {
      Prim.trap "Buffer index out of bounds in suffix"
    };

    let newBuffer = Buffer<X>(count - start);

    var i = start;
    while (i < count) {
      newBuffer.add(buffer.get(i));

      i += 1;
    };

    newBuffer
  };

  public func isSuffixOf<X>(suffix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let suffixCount = suffix.size();
    let bufferCount = buffer.size();
    if (bufferCount < suffixCount) {
      return false;
    };

    var i : Int = bufferCount - 1;
    var j : Int = suffixCount - 1;
    while (i >= 0 and j >= 0) {
      if (not equal(buffer.get(Prim.abs i), suffix.get(Prim.abs j))) {
        return false;
      };
      
      i -= 1;
      j -= 1;
    };

    return true;
  };

  public func isStrictSuffixOf<X>(suffix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let suffixCount = suffix.size();
    let bufferCount = buffer.size();
    if (bufferCount <= suffixCount) {
      return false;
    };

    var i : Int = bufferCount - 1;
    var j : Int = suffixCount - 1;
    while (i >= 0 and j >= 0) {
      if (not equal(buffer.get(Prim.abs i), suffix.get(Prim.abs j))) {
        return false;
      };
      
      i -= 1;
      j -= 1;
    };

    return true;
  };

  public func takeWhile<X>(buffer : Buffer<X>, predicate : X -> Bool) : Buffer<X> {
    let count = buffer.size();
    let newBuffer = Buffer<X>(count);

    var i = 0;
    while (i < count) {
      let current = buffer.get(i);
      if (not predicate current) {
        return newBuffer;
      };

      newBuffer.add(current);
      i += 1;
    };

    newBuffer
  };
  
  public func dropWhile<X>(buffer : Buffer<X>, predicate : X -> Bool) : Buffer<X> {
    let count = buffer.size();
    let newBuffer = Buffer<X>(count);

    var i = 0;
    var take = false;
    while (i < count) {
      let current = buffer.get(i);
      if (not take and predicate current) {
        take := true;
      };

      if (take) {
        newBuffer.add(current);
      };

      i += 1;
    };

    newBuffer
  };

  public func transpose<X>(matrix : Buffer<Buffer<X>>) : Buffer<Buffer<X>> {
    // FIXME check bounds / staggered matrix
    let outerCount = matrix.size();
    let innerCount = matrix.get(0).size();

    let newMatrix = Buffer<Buffer<X>>(innerCount);
    var i = 0;
    while (i < innerCount) {
      var j = 0;
      while (j < outerCount) {
        if (i == 0) {
          newMatrix.add(Buffer<X>(outerCount));
        };
        newMatrix.get(i).put(j, matrix.get(j).get(i));

        j += 1;
      };

      i += 1;
    };

    newMatrix
  };

  // FIXME error checks should be easy to understand, and top level if necessary
  public func first<X>(buffer : Buffer<X>) : X = buffer.get(0);
  public func last<X>(buffer : Buffer<X>) : X = buffer.get(buffer.size() - 1);

  public func binarySearch<X>(buffer : Buffer<X>, element : X, compare : (X, X) -> Order.Order) : ?Nat {
    var low = 0;
    var high = buffer.size();

    while (low < high) {
      let mid = (low + high) / 2;
      let current = buffer.get(mid);
      switch (compare(element, current)) {
        case (#equal) {
          return ?mid;
        };
        case (#less) {
          high := mid;
        };
        case (#greater) {
          low := mid + 1;
        };
      }
    };

    null
  };

  public func indexOf<X>(buffer : Buffer<X>, element : X, equal : (X, X) -> Bool) : ?Nat {
    let count = buffer.size();

    var i = 0;
    while (i < count) {
      if (equal(buffer.get(i), element)) {
        return ?i;
      }
    };

    null
  };

  public func lastIndexOf<X>(buffer : Buffer<X>, element : X, equal : (X, X) -> Bool) : ?Nat {
    var i : Int = buffer.size() - 1;
    while (i >= 0) {
      let n = Prim.abs i;
      if (equal(buffer.get(n), element)) {
        return ?n;
      }
    };

    null
  };

  // Uses the KMP substring search algorithm
  public func indexOfBuffer<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, equal : (X, X) -> Bool) : ?Nat {
    let count1 = buffer1.size();
    let count2 = buffer2.size();
    // FIXME implementation below assumes count1 < count2
    if (count2 > count1) {
      Prim.trap "Buffer2 length should be smaller than Buffer1 length in indexOfBuffer";
    };

    let lps = Prim.Array_init<Nat>(count2, 0);

    // length of the previous longest prefix suffix
    var prevLength = 0;
    var i = 1;
 
    // precompute lps
    while (i < count2) {
      if (equal(buffer2.get(i), buffer2.get(prevLength))) {
        prevLength += 1;
        lps[i] := prevLength;
        i += 1;
      }
      else {
        if (prevLength != 0) {
          prevLength := lps[prevLength - 1];
        } else {
            lps[i] := prevLength;
            i += 1;
        }
      }
    };

    // start search
    i := 0;
    var j = 0;
    while ((count1 - i : Nat) >= (count2 - j : Nat)) {
      if (equal(buffer1.get(i), buffer2.get(j))) {
          i += 1;
          j += 1;
      };
      if (j == count2) {
        return ?(i - j);
      }
      else if (i < count1 and not equal(buffer2.get(j), buffer1.get(i))) {
        if (j != 0) {
            j := lps[j - 1];
        } else {
            i += 1;
        }
      }
    };

    null
  };
}