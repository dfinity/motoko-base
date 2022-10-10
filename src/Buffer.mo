/// Class `Buffer<X>` provides a mutable list of elements of type `X`.
/// The class wraps and resizes an underyling array that holds the elements, 
/// and thus is comparable to ArrayLists or ResizingArrays in other languages.
///
/// When required, the current state of a buffer object can be converted to a fixed-size array of its elements.
/// This is recommended for example when storing a buffer to a stable variable.
///
/// WARNING: Certain operations are amortized O(1) time, such as `add`, but run
/// in worst case O(n) time. These worst case runtimes may exceed the cycles limit
/// per message if the size of the buffer is large enough. Grow these structures
/// with discretion. All amortized operations below also list the worst case runtime.
///
/// Constructor:
/// The argument `initCapacity` determines the initial capacity of the array.
/// The underlying array grows by a factor of 2 when its current capacity is 
/// exceeded. Further, when the size of the buffer shrinks to be less than 1/4th
/// of the capacity the underyling array is shrunk by a factor of 2.
///
/// Runtime: O(initCapcity)
///
/// Space: O(initCapacity)

import Prim "mo:⛔";
import Result "Result";
import Order "Order";
import Array "Array";

module {
  type Order = Order.Order;

  private let UPSIZE_FACTOR = 2;
  private let DOWNSIZE_THRESHOLD = 4; // Don't downsize too early to avoid thrashing
  private let DOWNSIZE_FACTOR = 2;

  public class Buffer<X>(initCapacity : Nat) = this {
    var count : Nat = 0;
    var elems : [var ?X] = Prim.Array_init(initCapacity, null);

    /// Returns the current number of elements in the buffer.
    ///
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func size() : Nat = count;

    /// Adds a single element to the end of the buffer, doubling 
    /// the size of the array if capacity is exceeded.
    ///
    /// Amortized Runtime: O(1), Worst Case Runtime: O(size)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size)
    public func add(elem : X) {
      if (count == elems.size()) {
        let elemsSize = elems.size();
        resize(if (elemsSize == 0) { 1 } else { elemsSize * UPSIZE_FACTOR } );
      };
      elems[count] := ?elem;
      count += 1;
    };

    /// Removes and returns the last item in the buffer or `null` if
    /// the buffer is empty.
    ///
    /// Amortized Runtime: O(1), Worst Case Runtime: O(size)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size)
    public func removeLast() : ?X {
      if (count == 0) {
        return null;
      };

      count -= 1;
      let lastElement = elems[count];
      elems[count] := null;

      if (count < elems.size() / DOWNSIZE_THRESHOLD) {
        resize(elems.size() / DOWNSIZE_FACTOR)
      };

      lastElement
    };

    /// Removes and returns the element at `index` from the buffer.
    /// All elements with index > `index` are shifted one position to the left.
    /// This may cause a downsizing of the array.
    /// 
    /// Runtime: O(size)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size)
    public func remove(index : Nat) : ?X {
      if (index >= count) {
        return null;
      };

      let element = elems[index];

      // resize down and shift over in one pass
      if ((count - 1) : Nat < elems.size() / DOWNSIZE_THRESHOLD) { 
        let elems2 = Prim.Array_init<?X>(elems.size() / DOWNSIZE_FACTOR, null);

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
        elems[count] := null;
      };

      count -= 1;
      element
    };

    /// Removes all elements from the buffer for which the predicate returns false.
    /// The predicate is given both the index of the element and the element itself.
    /// This may cause a downsizing of the array.
    ///
    /// Runtime: O(size)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size)
    public func filterEntries(predicate : (Nat, X) -> Bool) { 
      var removeCount = 0;
      let keep = 
        Prim.Array_tabulate<Bool>(
          count,
          func i {
            switch (elems[i]) {
              case (?element) {
                if (predicate(i, element)) {
                  true
                } else {
                  removeCount += 1;
                  false
                }
              };
              case null {
                Prim.trap "Malformed buffer in filter()"
              }
            }
          }
        );
      
      let elemsSize = elems.size();

      var original = elems;
      if ((count - removeCount : Nat) < elemsSize / DOWNSIZE_THRESHOLD) {
        elems := Prim.Array_init<?X>(elemsSize / DOWNSIZE_FACTOR, null);
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

    /// Gets the `i`-th element of this buffer. Traps if  `i >= count`. Indexing is zero-based.
    ///
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func get(i : Nat) : X {
      switch (elems[i]) {
        case (?element) element;
        case null Prim.trap("Buffer index out of bounds in get");
      }
    };

    /// Gets the `i`-th element of the buffer as an option. Returns `null` when `i >= count`. Indexing is zero-based.
    ///
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func getOpt(i : Nat) : ?X {
      if (i < count) {
        elems[i]
      } else {
        null
      }
    };

    /// Overwrites the current value of the `i`-entry of  this buffer with `elem`. Traps if the
    /// index is out of bounds. Indexing is zero-based.
    ///
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func put(i : Nat, elem : X) {
      if (i >= count) {
        Prim.trap "Buffer index out of bounds in put";
      };
      elems[i] := ?elem;
    };

    /// Returns the size of the underlying array.
    ///
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func capacity() : Nat = elems.size();

    /// Resizes the underyling array to `size`. Traps if `size` is less than
    /// the current size of the buffer.
    ///
    /// Runtime: O(size)
    ///
    /// Space: O(size)
    public func resize(size : Nat) {
      if (size < count) {
        Prim.trap "size must be >= current buffer size in resize"
      };

      let elems2 = Prim.Array_init<?X>(size, null);

      var i = 0;
      if (elems.size() <= size) {
        label iter for (element in elems.vals()) {
          if (i >= count) {
            break iter;
          };
          elems2[i] := element;
          i += 1;
        }
      } else {
        while (i < count) {
          elems2[i] := elems[i];
          i += 1;
        };
      };
      elems := elems2;
    };

    /// Adds all elements in buffer `b` to this buffer.
    /// 
    /// Amortized Runtime: O(size2), Worst Case Runtime: O(size1 + size2)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size1 + size2)
    public func append(buffer2 : Buffer<X>) {
      let count2 = buffer2.size();
      // Make sure you only resize once
      if (count + count2 > elems.size()) {
        // FIXME would be nice to have a tabulate for var arrays here
        resize((count + count2) * UPSIZE_FACTOR);
      };
      var i = 0;
      while (i < count2) {
        elems[count + i] := buffer2.getOpt i;
        i += 1;
      };

      count += count2;
    };

    /// Inserts `element` at `index`, shifts all elements to the right of
    /// `index` over by one index. Traps if `index` is greater than size.
    ///
    /// Runtime: O(size)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size)
    public func insert(index : Nat, element : X) {
      if (index > count) {
        Prim.trap "Buffer index out of bounds in insert"
      };
      let elemsSize = elems.size();

      if (count + 1 > elemsSize) {
        let elemsSize = elems.size();
        let elems2 = 
          Prim.Array_init<?X>(
            if (elemsSize == 0) { 1 } else { elemsSize * UPSIZE_FACTOR },
            null
          );
        var i = 0;
        while (i < count + 1) {
          if (i < index) {
            elems2[i] := elems[i];
          } else if (i == index) {
            elems2[i] := ?element;
          } else {
            elems2[i] := elems[i - 1];
          };
          
          i += 1;
        };
        elems := elems2;
      } else {
        var i : Nat = count;
        while (i > index) {
          elems[i] := elems[i - 1];
          i -= 1;
        };
        elems[index] := ?element;
      };

      count += 1;
    };

    /// Inserts `buffer2` at `index`, shifts all elements to the right of
    /// `index` over by size2. Traps if `index` is greater than size.
    ///
    /// Runtime: O(size)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size1 + size2)
    public func insertBuffer(index : Nat, buffer2 : Buffer<X>) {
      if (index > count) {
        Prim.trap "Buffer index out of bounds in insertBuffer"
      };

      let count2 = buffer2.size();
      let elemsSize = elems.size();

      // resize and insert in one go
      if (count + count2 > elemsSize) {
        let elems2 = Prim.Array_init<?X>((count + count2) * UPSIZE_FACTOR, null);
        var i = 0;
        for (element in elems.vals()) {
          if (i == index) {
            i += count2;
          };
          elems2[i] := element;
          i += 1;
        };

        i := 0;
        while (i < count2) {
          elems2[i + index] := buffer2.getOpt(i);
          i += 1;
        };
        elems := elems2;
      } 
      // just insert
      else {
        var i = index;
        while (i < index + count2) {
          if (i < count) {
            elems[i + count2] := elems[i];
          };
          elems[i] := buffer2.getOpt(i - index);

          i += 1;
        }
      };

      count += count2;
    };

    /// Resets the buffer. Capacity is set to 8.
    ///
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func clear() {
      count := 0;
      resize(8); 
    };
 
    /// Sorts the elements in the buffer according to `compare`.
    /// Sort is deterministic, stable, and in-place.
    ///
    /// Runtime: O(size * log(size))
    ///
    /// Space: O(size)
    public func sort(compare : (X, X) -> Order.Order) {
      // Stable merge sort in a bottom-up iterative style
      if (count == 0) {
        return;
      };
      let scratchSpace = Prim.Array_init<?X>(count, null);

      let countDec = count - 1 : Nat;
      var curr_size = 1;
      while (curr_size < count) {
        var left_start = 0;
        while (left_start < countDec) {
          let mid : Nat = if (left_start + curr_size - 1 : Nat < countDec) { left_start + curr_size - 1 } else { countDec };
          let right_end : Nat = if (left_start + (2 * curr_size) - 1 : Nat < countDec) { left_start + (2 * curr_size) - 1 } else { countDec };
    
          // Merge subarrays elems[left_start...mid] and elems[mid+1...right_end]
          var left = left_start;
          var right = mid + 1;
          var nextSorted = left_start;
          while (left < mid + 1 and right < right_end + 1) {
            let leftOpt = elems[left];
            let rightOpt = elems[right];
            switch (leftOpt, rightOpt) {
              case(?leftElement, ?rightElement) {
                switch(compare(leftElement, rightElement)) {
                  case (#less or #equal) {
                    scratchSpace[nextSorted] := leftOpt;
                    left += 1;
                  };
                  case (#greater) {
                    scratchSpace[nextSorted] := rightOpt;
                    right += 1;
                  }
                };
              };
              case (_, _) { // only sorting non-null items
                Prim.trap("Malformed buffer in sort")
              };
            };
            nextSorted += 1;
          };
          while (left < mid + 1) {
            scratchSpace[nextSorted] := elems[left];
            nextSorted += 1;
            left += 1;
          };
          while (right < right_end + 1) {
            scratchSpace[nextSorted] := elems[right];
            nextSorted += 1;
            right += 1;
          };

          // Copy over merged elements
          var i = left_start;
          while (i < right_end + 1) {
            elems[i] := scratchSpace[i];
            i += 1;
          };

          left_start += 2 * curr_size;
        };
        curr_size *= 2;
      }
    };

    /// Returns an Iterator (`Iter`) over the elements of this buffer.
    /// Iterator provides a single method `next()`, which returns
    /// elements in order, or `null` when out of elements to iterate over.
    /// 
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func vals() : { next : () -> ?X } = object {
      let arrayIterator = elems.vals();
      public func next() : ?X {
        switch(arrayIterator.next()) {
          case null null;
          case (?element) element;
        }
      }
    };

    // FOLLOWING METHODS ARE DEPRECATED

    /// @deprecated Use static library function instead.
    public func clone() : Buffer<X> {
      let newBuffer = Buffer<X>(elems.size());
      for (element in vals()) {
        newBuffer.add(element)
      };
      newBuffer
    };

    /// @deprecated Use static library function instead.
    public func toArray() : [X] =
      // immutable clone of array
      Prim.Array_tabulate<X>(
        count,
        func(i : Nat) : X { get i }
      );

    /// @deprecated Use static library function instead.
    public func toVarArray() : [var X] {
      if (count == 0) {
        [var]
      } else {
        let newArray = Prim.Array_init<X>(count, get 0);
        var i = 0;
        for (element in vals()) {
          newArray[i] := element;
          i += 1;
        };
        newArray
      }
    }
  };

  /// Returns a copy of `buffer`, with the same capacity.
  ///
  /// Runtime: O(size)
  /// 
  /// Space: O(size)
  public func clone<X>(buffer : Buffer<X>) : Buffer<X> {
    let newBuffer = Buffer<X>(buffer.capacity());
    for (element in buffer.vals()) {
      newBuffer.add(element)
    };
    newBuffer
  };

  /// Creates an array containing elements from `buffer`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toArray<X>(buffer : Buffer<X>) : [X] =
    // immutable clone of array
    Prim.Array_tabulate<X>(
      buffer.size(),
      func(i : Nat) : X { buffer.get(i) }
    );

  /// Creates a mutable array containing elements from `buffer`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toVarArray<X>(buffer : Buffer<X>) : [var X] {
    let count = buffer.size();
    if (count == 0) {
      [var]
    } else {
      let newArray = Prim.Array_init<X>(count, buffer.get(0));
      var i = 0;
      for (element in buffer.vals()) {
        newArray[i] := element;
        i += 1;
      };
      newArray
    }
  };

  /// Creates a buffer containing elements from `array`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromArray<X>(array : [X]) : Buffer<X> {
    let newBuffer = Buffer<X>(array.size() * UPSIZE_FACTOR);

    for (element in array.vals()) {
      newBuffer.add(element);
    };

    newBuffer
  };

  /// Creates a buffer containing elements from `array`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromVarArray<X>(array : [var X]) : Buffer<X> {
    let newBuffer = Buffer<X>(array.size() * UPSIZE_FACTOR);

    for (element in array.vals()) {
      newBuffer.add(element);
    };

    newBuffer
  };

  /// Creates a buffer containing elements from `iter`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromIter<X>(iter : { next : () -> ?X }) : Buffer<X> {
    let newBuffer = Buffer<X>(8);

    for (element in iter) {
      newBuffer.add(element);
    };

    newBuffer
  };

  /// Resizes the array underlying `buffer` such that capacity == size.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func trimToSize<X>(buffer : Buffer<X>) {
    let count = buffer.size();
    if (count < buffer.capacity()) {
      buffer.resize(count);
    }
  };

  /// Creates a new buffer by applying `f` to each element in `buffer`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func map<X, Y>(buffer : Buffer<X>, f : X -> Y) : Buffer<Y> {
    let newBuffer = Buffer<Y>(buffer.capacity());
    
    for (element in buffer.vals()) {
      newBuffer.add(f element);
    };

    newBuffer
  };

  /// Applies `f` to each element in `buffer`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func iterate<X>(buffer : Buffer<X>, f : X -> ()) {
    for (element in buffer.vals()) {
     f element
    };
  };

  /// Applies `f` to each element in `buffer` and its index.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapEntries<X, Y>(buffer : Buffer<X>, f : (Nat, X) -> Y) : Buffer<Y> {
    let newBuffer = Buffer<Y>(buffer.capacity());
    
    var i = 0;
    for (element in buffer.vals()) {
      newBuffer.add(f(i, element));
      i += 1;
    };

    newBuffer
  };

  /// Creates a new buffer by applying `f` to each element in `buffer`,
  /// and keeping all non-null elements.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapFilter<X, Y>(buffer : Buffer<X>, f : X -> ?Y) : Buffer<Y> {
    let newBuffer = Buffer<Y>(buffer.capacity());
    
    for (element in buffer.vals()) {
      switch (f element) {
        case (?element) {
          newBuffer.add(element);
        };
        case _ {};
      };
    };

    newBuffer
  };

  /// Creates a new buffer by applying `f` to each element in `buffer`.
  /// If any invocation of `f` produces an #err, returns an #err. Otherwise
  /// Returns an #ok containing the new buffer.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapResult<X, Y, E>(buffer : Buffer<X>, f : X -> Result.Result<Y, E>) : Result.Result<Buffer<Y>, E> {
    let newBuffer = Buffer<Y>(buffer.size());
    
    for (element in buffer.vals()) {
      switch(f element) {
        case (#ok result) {
          newBuffer.add(result);
        };
        case (#err e) {
          return #err e;
        }
      };
    };

    #ok newBuffer
  };

  /// Creates a new buffer by applying `k` to each element in `buffer`,
  /// and concatenating the resulting buffers in order. This operation
  /// is similar to what in other functional languages is known as monadic bind.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func chain<X, Y>(buffer : Buffer<X>, k : X -> Buffer<Y>) : Buffer<Y> {
    let newBuffer = Buffer<Y>(buffer.size() * 4);
    
    for (element in buffer.vals()) {
      newBuffer.append(k element);
    };

    newBuffer
  };

  /// Collapses the elements in `buffer` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldLeft<A, X>(buffer : Buffer<X>, base : A, combine : (A, X) -> A) : A {
    var accumulation = base;
    
    for (element in buffer.vals()) {
      accumulation := combine(accumulation, element);
    };

    accumulation
  };

  /// Collapses the elements in `buffer` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
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

  /// Returns true iff every element in `buffer` satisfies `predicate`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func forAll<X>(buffer : Buffer<X>, predicate : X -> Bool) : Bool {
    for (element in buffer.vals()) {
      if (not predicate element) {
        return false;
      };
    };

    true
  };

  /// Returns true iff some element in `buffer` satisfies `predicate`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func forSome<X>(buffer : Buffer<X>, predicate : X -> Bool) : Bool {
    for (element in buffer.vals()) {
      if (predicate element) {
        return true;
      };
    };

    false
  };

  /// Returns true iff no element in `buffer` satisfies `predicate`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func forNone<X>(buffer : Buffer<X>, predicate : X -> Bool) : Bool {
    for (element in buffer.vals()) {
      if (predicate element) {
        return false;
      };
    };

    true
  };

  /// Returns a new buffer with capacity and size 1, containing `element`.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func make<X>(element : X) : Buffer<X> {
    let newBuffer = Buffer<X>(1);
    newBuffer.add(element);
    newBuffer
  };

  /// Returns true iff `buffer` contains `element` with respect to equality
  /// defined by `equals`.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equals` runs in O(1) time and space.
  public func contains<X>(buffer : Buffer<X>, element : X, equals : (X, X) -> Bool) : Bool {
    for (current in buffer.vals()) {
      if (equals(current, element)) {
        return true;
      };
    };

    false
  };

  /// Finds the greatest element in `buffer` defined by `compare`.
  /// Traps if `buffer` is empty.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func max<X>(buffer : Buffer<X>, compare : (X, X) -> Order) : X {
    if (buffer.size() == 0) {
      Prim.trap "Cannot call max on an empty buffer"
    };

    var maxSoFar = buffer.get(0);
    for (current in buffer.vals()) {
      switch(compare(current, maxSoFar)) {
        case (#greater) {
          maxSoFar := current
        };
        case _ {};
      };
    };

    maxSoFar
  };

  /// Finds the least element in `buffer` defined by `compare`. 
  /// Traps if `buffer` is empty.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func min<X>(buffer : Buffer<X>, compare : (X, X) -> Order) : X {
    if (buffer.size() == 0) {
      Prim.trap "Cannot call min on an empty buffer"
    };

    var minSoFar = buffer.get(0);
    for (current in buffer.vals()) {
      switch(compare(current, minSoFar)) {
        case (#less) { 
          minSoFar := current
        };
        case _ {};
      };
    };

    minSoFar
  };

  /// Returns true iff the buffer is empty.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func isEmpty<X>(buffer : Buffer<X>) : Bool = buffer.size() == 0;

  /// Eliminates all duplicate elements in `buffer` as defined by `compare`.
  /// Elimination is stable with respect to the original ordering of the elements.
  ///
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  public func removeDuplicates<X>(buffer : Buffer<X>, compare : (X, X) -> Order) {
    let count = buffer.size();
    let indices = Prim.Array_tabulate<(Nat, X)>(count, func i = (i, buffer.get(i)));
    // Sort based on element, while carrying original index information
    let sorted = Array.sort<(Nat, X)>(indices, func(pair1, pair2) = compare(pair1.1, pair2.1));
    let uniques = Buffer<(Nat, X)>(count);
    var i = 0;
    while (i < count) {
      var j = i;
      // find the minimum index between duplicate elements
      var minIndex = sorted[j];
      label duplicates while (j < (count - 1 : Nat)) {
        let pair1 = sorted[j];
        let pair2 = sorted[j + 1];
        switch(compare(pair1.1, pair2.1)) {
          case (#equal) {
            if (pair2.0 < pair1.0) {
              minIndex := pair2
            };
            j += 1;
          };
          case _ { 
            break duplicates;
          }
        }
      };

      uniques.add(minIndex);
      i := j + 1;
    };

    // resort based on original ordering and place back in buffer
    uniques.sort(
      func(pair1, pair2) {
        if (pair1.0 < pair2.0) {
          #less
        } else if (pair1.0 == pair2.0) {
          #equal
        } else {
          #greater
        }
      }
    );

    buffer.clear();
    buffer.resize(uniques.size());
    for (element in uniques.vals()) {
      buffer.add(element.1);
    }
  };

  /// Hashes `buffer` using `hash` to hash the underlying elements.
  /// The deterministic hash function is a function of the elements in the Buffer, as well
  /// as their ordering.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `hash` runs in O(1) time and space.
  public func hash<X>(buffer : Buffer<X>, hash : X -> Nat32) : Nat32 {
    let count = buffer.size();
    var i = 0;
    var accHash : Nat32 = 0;

    for (element in buffer.vals()) {
      accHash := Prim.intToNat32Wrap(i) ^ accHash ^ hash(element);
      i += 1;
    };

    accHash
  };

  /// Creates a textual representation of `buffer`, using `toText` to recursively
  /// convert the elements into Text.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `toText` runs in O(1) time and space.
  public func toText<X>(buffer : Buffer<X>, toText : X -> Text) : Text {
    let count : Int = buffer.size();
    var i = 0;
    var text = "";
    while (i < count - 1) {
      text := text # toText(buffer.get(i)) # ", "; // Text implemented as rope
      i += 1;
    };
    if (count > 0) {
      text := text # toText(buffer.get(i))
    };

    "[" # text # "]"
  };

  /// Defines equality for two buffers, using `equal` to recursively compare elements in the 
  /// buffers. Returns true iff the two buffers are of the same size, and `equal`
  /// evaluates to true for every pair of elements in the two buffers of the same
  /// index.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func equal<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let count2 = buffer2.size();

    if (buffer1.size() != count2) {
      return false;
    };

    var i = 0;
    for (element1 in buffer1.vals()) {
      if (not equal(element1, buffer2.get(i))) {
        return false;
      };
      i += 1;
    };

    true
  };

  /// Defines comparison for two buffers, using `compare` to recursively compare elements in the 
  /// buffers. Comparison is defined lexicographically.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func compare<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, compare : (X, X) -> Order.Order) : Order.Order {
    let count1 = buffer1.size();
    let count2 = buffer2.size();
    var i = 0;
    if (count1 < count2) {
      for (element1 in buffer1.vals()) {
        switch(compare(element1, buffer2.get(i))) {
          case (#less) {
            return #less;
          };
          case (#greater) {
            return #greater;
          };
          case _ { }
        };
        i += 1;
      };
    } else {
      for (element2 in buffer2.vals()) {
        switch(compare(buffer1.get(i), element2)) {
          case (#less) {
            return #less;
          };
          case (#greater) {
            return #greater;
          };
          case _ { }
        };
        i += 1;
      };
    };

    if (count1 < count2) {
      #less
    } else if (count1 == count2) {
      #equal
    } else {
      #greater
    }
  };

  /// Reverses the order of elements in `buffer`.
  /// 
  /// Runtime: O(size)
  ///
  // Space: O(1)
  public func reverse<X>(buffer : Buffer<X>) {
    let count = buffer.size();
    if (count == 0) {
      return;
    };

    var i = 0;
    var temp = buffer.get(0);
    for (element in buffer.vals()) {
      if (i >= count / 2) {
        return;
      };
      temp := buffer.get(count - i - 1);
      buffer.put(count - i - 1, element);
      buffer.put(i, temp);
      i += 1;
    }
  };

  /// Flattens the buffer of buffers into a single buffer.
  ///
  /// Runtime: O(number of elements in buffer)
  ///
  /// Space: O(number of elements in buffer)
  public func flatten<X>(buffer : Buffer<Buffer<X>>) : Buffer<X> {
    let count = buffer.size();
    if (count == 0) {
      return Buffer<X>(0);
    };

    let newBuffer = 
      Buffer<X>(
        if (buffer.get(0).size() != 0) {
          buffer.get(0).size() * count * UPSIZE_FACTOR
        } else {
          count * UPSIZE_FACTOR
        }
      );
    
    for (innerBuffer in buffer.vals()) {
      for (innerElement in innerBuffer.vals()) {
        newBuffer.add(innerElement);
      };
    };

    newBuffer
  };

  /// Splits `buffer` into a pair of buffers where all elements in the left
  /// buffer satisfy `predicate` and all elements in the right buffer do not.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func partition<X>(buffer : Buffer<X>, predicate : X -> Bool) : (Buffer<X>, Buffer<X>) {
    let count = buffer.size();
    let trueBuffer = Buffer<X>(count);
    let falseBuffer = Buffer<X>(count);
    
    for (element in buffer.vals()) {
      if (predicate element) {
        trueBuffer.add(element);
      } else {
        falseBuffer.add(element);
      };
    };

    (trueBuffer, falseBuffer)
  };

  /// Merges two sorted buffers into a single sorted buffer, using `compare` to define
  /// the ordering. The final ordering is stable. Behavior is undefined if either
  /// `buffer1` or `buffer2` is not sorted.
  ///
  /// Runtime: O(size1 + size2)
  ///
  /// Space: O(size1 + size2)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func merge<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, compare : (X, X) -> Order) : Buffer<X> {
    let count1 = buffer1.size();
    let count2 = buffer2.size();

    let newBuffer = Buffer<X>((count1 + count2) * UPSIZE_FACTOR);

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

  /// Splits the buffer into two buffers at `index`, where the left buffer contains
  /// all elements with indices less than `index`, and the right buffer contains all 
  /// elements with indices greater than or equal to `index`. Traps if `index` is out
  /// of bounds.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func split<X>(buffer : Buffer<X> , index : Nat) : (Buffer<X>, Buffer<X>) {
    let count = buffer.size();

    if (index < 0 or index > count) {
      Prim.trap "Index out of bounds in split"
    };

    let buffer1 = Buffer<X>(if (index == 0) { UPSIZE_FACTOR} else { index * UPSIZE_FACTOR });
    let buffer2 = Buffer<X>(if ((count - index : Nat) == 0) { UPSIZE_FACTOR } else { (count - index) * UPSIZE_FACTOR });

    var i = 0;
    for (element in buffer.vals()) {
      if (i < index) {
        buffer1.add(element);
      } else {
        buffer2.add(element);
      };

      i += 1;
    };

    (buffer1, buffer2)
  };

  /// Combines the two buffers into a single buffer of pairs, pairing together
  /// elements with the same index. If one buffer is longer than the other, the
  /// remaining elements from the longer buffer is not included.
  ///
  /// Runtime: O(min(size1, size2))
  ///
  /// Space: O(min(size1, size2))
  public func zip<X, Y>(buffer1 : Buffer<X>, buffer2 : Buffer<Y>) : Buffer<(X, Y)> {
    // compiler should pull lamda out as a static function since it is fully closed
    zipWith<X, Y, (X, Y)>(buffer1, buffer2, func(x, y) = (x, y))
  };

  /// Combines the two buffers into a single buffer, pairing together
  /// elements with the same index and combining them using `zip`. If 
  /// one buffer is longer than the other, the remaining elements from 
  /// the longer buffer is not included.
  ///
  /// Runtime: O(min(size1, size2))
  ///
  /// Space: O(min(size1, size2))
  ///
  /// *Runtime and space assumes that `zip` runs in O(1) time and space.
  public func zipWith<X, Y, Z>(buffer1 : Buffer<X>, buffer2 : Buffer<Y>, zip : (X, Y) -> Z) : Buffer<Z> {
    let count1 = buffer1.size();
    let count2 = buffer2.size();
    var i = 0;
    if (count1 < count2) {
      let newBuffer = Buffer<Z>(if (count1 == 0) { UPSIZE_FACTOR } else { count1 * UPSIZE_FACTOR });
      for (current1 in buffer1.vals()) {
        let current2 = buffer2.get(i);
        newBuffer.add(zip(current1, current2));
        i += 1;
      };
      newBuffer
    } else {
      let newBuffer = Buffer<Z>(if (count2 == 0) { UPSIZE_FACTOR } else { count2 * UPSIZE_FACTOR });
      for (current2 in buffer2.vals()) {
        let current1 = buffer1.get(i);
        newBuffer.add(zip(current1, current2));
        i += 1;
      };
      newBuffer
    }
  };

  /// Breaks up `buffer` into buffers of size `size`. The last chunk may
  /// have less than `size` elements if the number of elements is not divisible
  /// by the chunk size.
  ///
  /// Runtime: O(number of elements in buffer)
  ///
  /// Space: O(number of elements in buffer)
  public func chunk<X>(buffer : Buffer<X>, size : Nat) : Buffer<Buffer<X>> {
    if (size == 0) {
      Prim.trap "Chunk size must be non-zero in chunk"
    };

    let newBuffer = Buffer<Buffer<X>>(Prim.abs(Prim.floatToInt(Prim.floatCeil(Prim.intToFloat(buffer.size()) / Prim.intToFloat(size)))));

    var newInnerBuffer = Buffer<X>(size * UPSIZE_FACTOR);
    var innerSize = 0;
    for (element in buffer.vals()) {
      if (innerSize == size) {
        newBuffer.add(newInnerBuffer);
        newInnerBuffer := Buffer<X>(size * UPSIZE_FACTOR);
        innerSize := 0;
      };
      newInnerBuffer.add(element);
      innerSize += 1;
    };
    if (innerSize > 0) {
      newBuffer.add(newInnerBuffer)
    };

    newBuffer
  };

  /// Groups equal and adjacent elements in the list into sub lists.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func groupBy<X>(buffer : Buffer<X>, equal : (X, X) -> Bool) : Buffer<Buffer<X>> {
    let count = buffer.size();
    let newBuffer = Buffer<Buffer<X>>(count);
    if (count == 0) {
      return newBuffer
    };

    var i = 0;
    var baseElement = buffer.get(0);
    var newInnerBuffer = Buffer<X>(count);
    for (element in buffer.vals()) {
      if (equal(baseElement, element)) {
        newInnerBuffer.add(element);
      } else {
        newBuffer.add(newInnerBuffer);
        baseElement := element;
        newInnerBuffer := Buffer<X>(count - i);
        newInnerBuffer.add(element);
      };
      i += 1;
    };
    if (newInnerBuffer.size() > 0) {
      newBuffer.add(newInnerBuffer)
    };

    newBuffer
  };

  /// Returns the prefix of `buffer` of length `length`. Traps if `length`
  /// is greater than the size of `buffer`.
  ///
  /// Runtime: O(length)
  ///
  /// Space: O(length)
  public func prefix<X>(buffer : Buffer<X>, length : Nat) : Buffer<X> {
    if (length > buffer.size()) {
      Prim.trap "Buffer index out of bounds in prefix"
    };

    let newBuffer = Buffer<X>(if (length == 0) { UPSIZE_FACTOR } else { length * UPSIZE_FACTOR }); 

    var i = 0;
    for (element in buffer.vals()) {
      if (i == length) {
        return newBuffer;
      };
      newBuffer.add(element);
      i += 1;
    };

    newBuffer
  };

  /// Checks if `prefix` is a prefix of `buffer`. Uses `equal` to
  /// compare elements.
  ///
  /// Runtime: O(size of prefix)
  ///
  /// Space: O(size of prefix)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func isPrefixOf<X>(prefix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    if (buffer.size() < prefix.size()) {
      return false;
    };

    var i = 0;
    for (prefixElement in prefix.vals()) {
      if (not equal(buffer.get(i), prefixElement)) {
        return false;
      };
      
      i += 1;
    };

    return true;
  };

  /// Checks if `prefix` is a strict prefix of `buffer`. Uses `equal` to
  /// compare elements.
  ///
  /// Runtime: O(size of prefix)
  ///
  /// Space: O(size of prefix)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func isStrictPrefixOf<X>(prefix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    if (buffer.size() <= prefix.size()) {
      return false;
    };

    var i = 0;
    for (prefixElement in prefix.vals()) {
      if (not equal(buffer.get(i), prefixElement)) {
        return false;
      };
      
      i += 1;
    };

    return true;
  };

  /// Returns the infix (sub-buffer) of `buffer` starting at index `start`
  /// of length `length`. Traps if `start` is out of bounds, or `start + length`
  /// is greater than the size of `buffer`.
  ///
  /// Runtime: O(length)
  ///
  /// Space: O(length)
  public func infix<X>(buffer : Buffer<X>, start : Nat, length : Nat) : Buffer<X> {
    let count = buffer.size();
    let end = start + length; // exclusive
    if (start >= count or end > count) {
      Prim.trap "Buffer index out of bounds in infix"
    };

    let newBuffer = Buffer<X>(if (length == 0) { UPSIZE_FACTOR } else { length * UPSIZE_FACTOR });

    var i = start;
    while (i < end) {
      newBuffer.add(buffer.get(i));

      i += 1;
    };

    newBuffer
  };

  /// Checks if `infix` is an infix of `buffer`. Uses `equal` to
  /// compare elements.
  ///
  /// Runtime: O(size of infix + size of buffer)
  ///
  /// Space: O(size of infix)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func isInfixOf<X>(infix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let infixSize = infix.size();

    switch(indexOfBuffer(infix, buffer, equal)) {
      case null infixSize == 0;
      case _ true;
    }
  };

  /// Checks if `infix` is a strict infix of `buffer`, i.e. `infix` must be
  /// strictly contained inside both the first and last indices of `buffer`.
  /// Uses `equal` to compare elements.
  ///
  /// Runtime: O(size of infix + size of buffer)
  ///
  /// Space: O(size of infix)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func isStrictInfixOf<X>(infix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let infixSize = infix.size();

    switch(indexOfBuffer(infix, buffer, equal)) {
      case (?index) {
        index != 0 and index != (buffer.size() - infixSize : Nat) // enforce strictness
      };
      case null {
        infixSize == 0 and infixSize != buffer.size()
      }
    };
  };

  /// Returns the suffix of `buffer` of length `length`. 
  /// Traps if `length`is greater than the size of `buffer`.
  ///
  /// Runtime: O(length)
  ///
  /// Space: O(length)
  public func suffix<X>(buffer : Buffer<X>, length : Nat) : Buffer<X> {
    let count = buffer.size();

    if (length > count) {
      Prim.trap "Buffer index out of bounds in suffix"
    };

    let newBuffer = Buffer<X>(length * UPSIZE_FACTOR);

    var i = count - length : Nat;
    while (i < count) {
      newBuffer.add(buffer.get(i));

      i += 1;
    };

    newBuffer
  };

  /// Checks if `suffix` is a suffix of `buffer`. Uses `equal` to compare
  /// elements.
  ///
  /// Runtime: O(length of suffix)
  ///
  /// Space: O(length of suffix)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
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

  /// Checks if `suffix` is a strict suffix of `buffer`. Uses `equal` to compare
  /// elements.
  ///
  /// Runtime: O(length of suffix)
  ///
  /// Space: O(length of suffix)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
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

  /// Creates a new buffer taking elements in order from `buffer` until predicate
  /// returns false.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func takeWhile<X>(buffer : Buffer<X>, predicate : X -> Bool) : Buffer<X> {
    let newBuffer = Buffer<X>(buffer.size());

    for (element in buffer.vals()) {
      if (not predicate element) {
        return newBuffer;
      };
      newBuffer.add(element);
    };

    newBuffer
  };
  
  /// Creates a new buffer excluding elements in order from `buffer` until predicate
  /// returns false.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func dropWhile<X>(buffer : Buffer<X>, predicate : X -> Bool) : Buffer<X> {
    let count = buffer.size();
    let newBuffer = Buffer<X>(count);

    var i = 0;
    var take = false;
    label iter for (element in buffer.vals()) {
      if (not take and not predicate element) {
        take := true;
      };
      if (take) {
        newBuffer.add(element)
      }
    };
    newBuffer
  };

  /// Returns the first element of `buffer`. Traps if `buffer` is empty.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func first<X>(buffer : Buffer<X>) : X = buffer.get(0);

  /// Returns the last element of `buffer`. Traps if `buffer` is empty.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func last<X>(buffer : Buffer<X>) : X = buffer.get(buffer.size() - 1);

  /// Finds the first index of `element` in `buffer` using equality of elements defined
  /// by `equal`. Returns null if `element` is not found.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func indexOf<X>(element : X, buffer : Buffer<X>, equal : (X, X) -> Bool) : ?Nat {
    var i = 0;
    for (current in buffer.vals()) {
      if (equal(current, element)) {
        return ?i;
      };
      i += 1;
    };

    null
  };

  /// Finds the last index of `element` in `buffer` using equality of elements defined
  /// by `equal`. Returns null if `element` is not found.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func lastIndexOf<X>(element : X, buffer : Buffer<X>, equal : (X, X) -> Bool) : ?Nat {
    var i : Int = buffer.size() - 1;
    while (i >= 0) {
      let n = Prim.abs i;
      if (equal(buffer.get(n), element)) {
        return ?n;
      };
      i -= 1;
    };

    null
  };

  /// Searches for `subBuffer` in `buffer`, and returns the starting index if it is found.
  ///
  /// Runtime: O(size of buffer + size of subBuffer)
  ///
  /// Space: O(size of subBuffer)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  // Uses the KMP substring search algorithm
  // Implementation from: https://www.educative.io/answers/what-is-the-knuth-morris-pratt-algorithm
  public func indexOfBuffer<X>(subBuffer: Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : ?Nat {
    let count = buffer.size();
    let subCount = subBuffer.size();
    if (subCount > count) {
      return null;
    };

    // precompute lps
    let lps = Prim.Array_init<Nat>(subCount, 0);
    var i = 0;
    var j = 1;

    while (j < subCount) {
      if (equal(subBuffer.get(i), subBuffer.get(j))) {
        i += 1;
        lps[j] := i;
        j += 1;
      } else if (i == 0) {
        lps[j] := 0;
        j += 1;
      } else {
        i := lps[i - 1];
      }
    };

    // start search
    i := 0;
    j := 0;
    while (i < subCount and j < count) {
      if (equal(subBuffer.get(i), buffer.get(j)) and i == (subCount - 1 : Nat)) {
        return ?(j - i)
      } else if (equal(subBuffer.get(i), buffer.get(j))) {
        i += 1;
        j += 1;
      } else {
        if (i != 0) {
          i := lps[i - 1]
        } else {
          j += 1
        }
      }
    };

    null
  };

  /// Similar to indexOf, but runs in logarithmic time. Assumes that `buffer` is sorted.
  /// Behavior is undefined if `buffer` is not sorted. Uses `compare` to
  /// perform the search. Returns an index of `element` if it is found.
  ///
  /// Runtime: O(log(size))
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func binarySearch<X>(element : X, buffer : Buffer<X>, compare : (X, X) -> Order.Order) : ?Nat {
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
}