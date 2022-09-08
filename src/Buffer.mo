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
import Array "Array";
import Int "Int";

module {

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
        null
      } else {
        let lastElement = ?elems[count - 1];
        count -= 1;

        if (count < elems.size() / 4) { // avoid thrashing
          resize(elems.size() / 2) // will downsize to an array of size 2 at minimum
        };

        lastElement
      };
    };

    // traps on OOB
    // traps if never added any element to buffer before
    public func resize(size : Nat) {
      if (size < count) {
        // FIXME is it okay to use Prim.trap? Maybe use assert?
        Prim.trap "Size is too small to hold all elements in Buffer after resizing";
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

    /// Returns the current number of elements.
    public func size() : Nat = count;

    /// Resets the buffer.
    public func clear() {
      count := 0;
      resize(2); // Same downsize minimum as the remove methods
    };

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

    /// Creates a new array containing this buffer's elements.
    public func toArray() : [X] =
      // immutable clone of array
      Prim.Array_tabulate<X>(
        count,
        func(x : Nat) : X { elems[x] }
      );

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

    public func sort(lessThan : (X, X) -> Bool) {
      Array.sortInPlace(elems, lessThan)
    }
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

  public func filter<X>(buffer : Buffer<X>, predicate : X -> Bool) : Buffer<X> {
    let count = buffer.size();
    let newBuffer = Buffer<X>(count);
    
    var i = 0;
    while (i < count) {
      let element = buffer.get(i);
      if (predicate element) {
        newBuffer.add(element);
      };

      i += 1;
    };

    newBuffer
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

  // FIXME traps on empty buffers
  public func max<X>(buffer : Buffer<X>, lessThan : (X, X) -> Bool) : X {
    let count = buffer.size();
    var i = 0;
    var maxSoFar = buffer.get(0);
    while (i < count) {
      let current = buffer.get(i);
      if (lessThan(maxSoFar, current)) {
        maxSoFar := current;
      };
      i += 1;
    };

    maxSoFar
  };

  // FIXME traps on empty buffers
  public func min<X>(buffer : Buffer<X>, lessThan : (X, X) -> Bool) : X {
    let count = buffer.size();
    var i = 0;
    var minSoFar = buffer.get(0);
    while (i < count) {
      let current = buffer.get(i);
      if (lessThan(current, minSoFar)) {
        minSoFar := current;
      };
      i += 1;
    };

    minSoFar
  };

  public func isEmpty<X>(buffer : Buffer<X>) : Bool = buffer.size() == 0;

  // FIXME can't return element X because it has to be shared from async
  // public func randomIndex<X>(buffer : Buffer<X>) : async Nat {
  //   let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;
  //   let count = buffer.size();

  //   var rand = 0;

  //   while (rand < count) { // make sure the size of randomness is large enough to span the whole set
  //     let bytes = await raw_rand();
  //     for (byte in bytes.vals()) {
  //         rand := (rand << 8) + byte;
  //     };
  //   };

  //   rand % count
  // };

  // public func hash<X>(buffer : Buffer<X>) : Nat32 {

  // };

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

  public func merge<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, lessThan : (X, X) -> Bool) : Buffer<X> {
    let count1 = buffer1.size();
    let count2 = buffer2.size();

    let newBuffer = Buffer<X>(count1 + count2);

    var pointer1 = 0;
    var pointer2 = 0;

    while (pointer1 < count1 and pointer2 < count2) {
      let current1 = buffer1.get(pointer1);
      let current2 = buffer2.get(pointer2);

      if (lessThan(current1, current2)) {
        newBuffer.add(current1);
        pointer1 += 1;
      } else {
        newBuffer.add(current2);
        pointer2 += 1;
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

  // FIXME traps on OOB
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
    let newBuffer = Buffer<(X, Y)>(minCount); // FIXME construct buffers with add leeway?

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

  // Combinations
  // Permutations (documentation should warn of any combinatorial explosions)

  // FIXME what is the "canonical" sequence structure? Should this return type be [Buffer<X>], List<Buffer<X>>, etc.?
  // Maybe it should be Array because it has the least overhead by being a primitive type
  public func chunk<X>(buffer : Buffer<X>, size : Nat) : Buffer<Buffer<X>> {
    if (size == 0) {
      Prim.trap "Chunk size must be non-zero"
    };

    let count = buffer.size();
    let newBuffer = Buffer<Buffer<X>>(count); // FIXME precalculate outer buffer size

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
      let newInnerBuffer = make<X>(buffer.get(i)); // FIXME leeway
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

  // isInfixOf
  // isStrictInfixOf

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
      if (not equal(buffer.get(Int.abs i), suffix.get(Int.abs j))) {
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
      if (not equal(buffer.get(Int.abs i), suffix.get(Int.abs j))) {
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

  // FIXME
  // public func transpose<X>(matrix : Buffer<Buffer<X>>) : Buffer<Buffer<X>> {

  //   var i = 0;
  //   while (i < matrix.size()) {
  //     var j = 0;
  //     while (j < matrix.get(i).size()) {

  //     }
  //   }
  // };

  // FIXME should this be a class method? seems pretty primitive
  // This is trivial in buffer, but less so in tree structures for example
  // Implement this for consitency of API
  // TRAP on empty or not?
  public func first<X>(buffer : Buffer<X>) : X = buffer.get(0);
  public func last<X>(buffer : Buffer<X>) : X = buffer.get(buffer.size() - 1);

  // binarySearch?
  // toText (how does this interact with debug_show?)

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
      let n = Int.abs i;
      if (equal(buffer.get(n), element)) {
        return ?n;
      }
    };

    null
  };

  // Zipper
}