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
import Array "Array";
import Nat "Nat";

module {
  type Order = Order.Order;

  private let UPSIZE_FACTOR = 2;
  private let DOWNSIZE_THRESHOLD = 4; // Don't downsize too early to avoid thrashing
  private let DOWNSIZE_FACTOR = 2;

  /// Create a stateful buffer class encapsulating a mutable array.
  ///
  /// The argument `initCapacity` determines its initial capacity.
  /// The underlying mutable array grows by UPSIZE_FACTOR when its current
  /// capacity is exceeded.

  // FIXME can initCapacity be an option?
  public class Buffer<X>(initCapacity : Nat) {
    var count : Nat = 0;
    var elems : [var ?X] = Prim.Array_init(initCapacity, null);

    /// Returns the current number of elements.
    public func size() : Nat = count;

    /// Adds a single element to the buffer.
    public func add(elem : X) {
      if (count == elems.size()) {
        let elemsSize = elems.size();
        resize(if (elemsSize == 0) { 1 } else { elemsSize * UPSIZE_FACTOR } );
      };
      elems[count] := ?elem;
      count += 1;
    };

    /// Removes the item that was inserted last and returns it or `null` if no
    /// elements had been added to the Buffer.
    public func removeLast() : ?X {
      if (count == 0) {
        return null;
      };

      let lastElement = elems[count - 1];
      count -= 1;

      if (count < elems.size() / DOWNSIZE_THRESHOLD) {
        resize(elems.size() / DOWNSIZE_FACTOR)
      };

      lastElement
    };

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
    public func get(i : Nat) : X {
      switch (elems[i]) {
        case (?element) element;
        case null Prim.trap("Buffer index out of bounds in get");
      }
    };

    /// Gets the `i`-th element of the buffer as an option. Returns `null` when `i >= count`. Indexing is zero-based.
    public func getOpt(i : Nat) : ?X {
      if (i < count) {
        elems[i]
      } else {
        null
      }
    };

    /// Overwrites the current value of the `i`-entry of  this buffer with `elem`. Traps if the
    /// index is out of bounds. Indexing is zero-based.
    public func put(i : Nat, elem : X) {
      if (i >= count) {
        Prim.trap "Buffer index out of bounds in put";
      };
      elems[i] := ?elem;
    };

    /// Returns the size of the underlying array
    public func capacity() : Nat = elems.size();

    // traps on OOB
    public func resize(size : Nat) {
      if (size < count) {
        Prim.trap "Size is too small to hold all elements in Buffer after resizing"
      };

      let elems2 = Prim.Array_init<?X>(size, null);

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
        // FIXME would be nice to have a tabulate for var arrays her
        resize((count + count2) * UPSIZE_FACTOR);
      };
      var i = 0;
      while (i < count2) {
        elems[count + i] := buffer2.getOpt i;
        i += 1;
      };

      count += count2;
    };

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
        while (i < count + count2) {
          if (i < index) {
            elems2[i] := elems[i];
          } else if (i >= index and i < index + count2) {
            elems2[i] := buffer2.getOpt(i - index);
          } else {
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
          if (i < count) {
            elems[i + count2] := elems[i];
          };
          elems[i] := buffer2.getOpt(i - index);

          i += 1;
        }
      };

      count += count2;
    };

    /// Resets the buffer.
    public func clear() {
      count := 0;
      resize(8); 
    };

    
    /// Returns a copy of this buffer.
    public func clone() : Buffer<X> {
      let newBuffer = Buffer<X>(elems.size());
      var i = 0;
      while (i < count) {
        newBuffer.add(get i); // FIXME Unnecesssary unwrap and rewrap
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
          pos += 1;
          elems[pos - 1]
        }
      }
    };

    // FIXME move outside of class?
    /// Creates a new array containing this buffer's elements.
    public func toArray() : [X] =
      // immutable clone of array
      Prim.Array_tabulate<X>(
        count,
        func(i : Nat) : X { get i }
      );

    // FIXME move outside of class?
    /// Creates a mutable array containing this buffer's elements.
    public func toVarArray() : [var X] {
      if (count == 0) {
        [var]
      } else {
        let newArray = Prim.Array_init<X>(count, get 0);
        var i = 0;
        while (i < count) {
          newArray[i] := get i;
          i += 1;
        };
        newArray
      }
    };
  };

  /// Creates a buffer from immutable array elements.
  public func fromArray<X>(elems : [X]) : Buffer<X> {
    let count = elems.size();
    let newBuffer = Buffer<X>(count * UPSIZE_FACTOR);

    var i = 0;
    while (i < count) {
      newBuffer.add(elems[i]);
      i += 1;
    };

    newBuffer
  };

  /// Creates a buffer from the elements of a mutable array.
  public func fromVarArray<X>(elems : [var X]) : Buffer<X> {
    let count = elems.size();
    let newBuffer = Buffer<X>(count * UPSIZE_FACTOR);

    var i = 0;
    while (i < count) {
      newBuffer.add(elems[i]);
      i += 1;
    };

    newBuffer
  };

  public func trimToSize<X>(buffer : Buffer<X>) {
    let count = buffer.size();
    if (count < buffer.capacity()) {
      buffer.resize(count);
    }
  };

  public func map<X, Y>(buffer : Buffer<X>, f : X -> Y) : Buffer<Y> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(buffer.capacity());
    
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
    let newBuffer = Buffer<Y>(count * 4);
    
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
    let newBuffer = Buffer<Y>(buffer.capacity());
    
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
    let newBuffer = Buffer<Y>(buffer.capacity());
    
    var i = 0;
    while (i < count) {
      newBuffer.add(f(i, buffer.get(i)));
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

  public func foldLeft<A, X>(buffer : Buffer<X>, base : A, combine : (A, X) -> A) : A {
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

  // stable duplicate removal
  public func removeDuplicates<X>(buffer : Buffer<X>, compare : (X, X) -> Order) {
    let count = buffer.size();
    let indices = Prim.Array_tabulate<(Nat, X)>(count, func i = (i, buffer.get(i)));
    // Sort based on element, while caring original index information
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
    sort<(Nat, X)>(uniques, func(pair1, pair2) = Nat.compare(pair1.0, pair2.0));

    buffer.clear();
    let uniqueCount = uniques.size();
    buffer.resize(uniqueCount);
    i := 0;
    while (i < uniqueCount) {
      buffer.add(uniques.get(i).1);
      i += 1;
    }
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
    let count : Int = buffer.size();
    var i = 0;
    var text = "";
    while (i < count - 1) {
      text := text # toText(buffer.get(i)) # ", ";
      i += 1;
    };
    if (count > 0) {
      text := text # toText(buffer.get(i))
    };

    "[" # text # "]"
  };

  public func equal<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let count1 = buffer1.size();
    let count2 = buffer2.size();

    if (count1 != count2) {
      return false;
    };

    var i = 0;
    while (i < count1) {
      if (not equal(buffer1.get(i), buffer2.get(i))) {
        return false;
      };
      i += 1;
    };

    true
  };

  public func compare<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, compare : (X, X) -> Order.Order) : Order.Order {
    let count1 = buffer1.size();
    let count2 = buffer2.size();
    let minCount = if (count1 < count2) { count1 } else { count2 };
    var i = 0;
    while (i < minCount) {
      switch(compare(buffer1.get(i), buffer2.get(i))) {
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

    Nat.compare(count1, count2)
  };

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

  // FIXME optimize me
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

    let buffer1 = Buffer<X>(if (index == 0) { UPSIZE_FACTOR} else { index * UPSIZE_FACTOR });
    let buffer2 = Buffer<X>(if ((count - index : Nat) == 0) { UPSIZE_FACTOR } else { (count - index) * UPSIZE_FACTOR });

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
    let newBuffer = Buffer<(X, Y)>(if (minCount == 0) { UPSIZE_FACTOR } else { minCount* UPSIZE_FACTOR });

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
    let newBuffer = Buffer<Z>(if (minCount == 0) { UPSIZE_FACTOR } else { minCount * UPSIZE_FACTOR });

    var i = 0;
    while (i < minCount) {
      let current1 = buffer1.get(i);
      let current2 = buffer2.get(i);

      newBuffer.add(zip(current1, current2));
      i += 1;
    };

    newBuffer
  };

  public func chunk<X>(buffer : Buffer<X>, size : Nat) : Buffer<Buffer<X>> {
    if (size == 0) {
      Prim.trap "Chunk size must be non-zero"
    };

    let count = buffer.size();
    let newBuffer = Buffer<Buffer<X>>(Prim.abs(Prim.floatToInt(Prim.floatCeil(Prim.intToFloat(count) / Prim.intToFloat(size)))));

    var i = 0;
    while (i < count) {
      let newInnerBuffer = Buffer<X>(size * UPSIZE_FACTOR);
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
      let baseElement = buffer.get(i);
      var j = i;
      while (j < count and equal(buffer.get(j), baseElement)) {
        newInnerBuffer.add(buffer.get(j));

        j += 1;
      };

      newBuffer.add(newInnerBuffer);

      i += newInnerBuffer.size();
    };

    newBuffer
  };

  public func prefix<X>(buffer : Buffer<X>, length : Nat) : Buffer<X> {
    if (length > buffer.size()) {
      Prim.trap "Buffer index out of bounds in prefix"
    };

    let newBuffer = Buffer<X>(if (length == 0) { UPSIZE_FACTOR } else { length * UPSIZE_FACTOR }); 

    var i = 0;
    while (i < length) {
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

  public func isInfixOf<X>(infix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let infixSize = infix.size();
    let bufferSize = buffer.size();
    if (infixSize > bufferSize) {
      return false;
    } else if (infixSize == 0) {
      return true;
    };

    switch(indexOfBuffer(buffer, infix, equal)) {
      case null false;
      case _ true;
    }
  };

  public func isStrictInfixOf<X>(infix : Buffer<X>, buffer : Buffer<X>, equal : (X, X) -> Bool) : Bool {
    let infixSize = infix.size();
    let bufferSize = buffer.size();
    if (infixSize >= bufferSize) {
      return false;
    };

    switch(indexOfBuffer(buffer, infix, equal)) {
      case null false;
      case _ true;
    }
  };

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
  // Implementation from: https://www.educative.io/answers/what-is-the-knuth-morris-pratt-algorithm
  public func indexOfBuffer<X>(buffer1 : Buffer<X>, buffer2 : Buffer<X>, equal : (X, X) -> Bool) : ?Nat {
    let count1 = buffer1.size();
    let count2 = buffer2.size();
    if (count2 > count1) {
      Prim.trap "Buffer2 length should be smaller than Buffer1 length in indexOfBuffer";
    };

    // precompute lps
    let lps = Prim.Array_init<Nat>(count2, 0);
    var i = 0;
    var j = 1;

    while (j < count2) {
      if (equal(buffer2.get(i), buffer2.get(j))) {
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
    while (i < count2 and j < count1) {
      if (equal(buffer2.get(i), buffer1.get(j)) and i == (count2 - 1 : Nat)) {
        return ?(j - i)
      } else if (equal(buffer2.get(i), buffer1.get(j))) {
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
}