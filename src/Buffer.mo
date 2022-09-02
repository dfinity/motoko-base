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
        let size =
          if (count == 0) {
            if (initCapacity > 0) { initCapacity } else { 1 }
          } else {
            2 * elems.size()
          };
        let elems2 = Prim.Array_init<X>(size, elem);
        var i = 0;
        label l loop {
          if (i >= count) break l;
          elems2[i] := elems[i];
          i += 1;
        };
        elems := elems2;
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
        count -= 1;
        ?elems[count]
      };
    };

    /// Adds all elements in buffer `b` to this buffer.
    public func append(b : Buffer<X>) {
      let countB = b.size();
      var i = 0;
      label l loop {
        if (i >= countB) {
          break l;
        };
        add(b.get(i));
        i += 1;
      };
    };

    /// Returns the current number of elements.
    public func size() : Nat = count;

    /// Resets the buffer.
    public func clear() = count := 0;

    /// Returns a copy of this buffer.
    public func clone() : Buffer<X> {
      let c = Buffer<X>(elems.size());
      var i = 0;
      label l loop {
        if (i >= count) {
          break l;
        };
        c.add(elems[i]);
        i += 1;
      };
      c
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
      if (count == 0) { [var] } else {
        let a = Prim.Array_init<X>(count, elems[0]);
        var i = 0;
        label l loop {
          if (i >= count) { 
            break l;
          };
          a[i] := elems[i];
          i += 1;
        };
        a
      }
    };

    /// Gets the `i`-th element of this buffer. Traps if  `i >= count`. Indexing is zero-based.
    public func get(i : Nat) : X {
      assert(i < count);
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

  /// Creates a buffer from immutable array elements.
  public func fromArray<X>(elems : [X]) : Buffer<X> {
    let buff = Buffer<X>(elems.size());
    for (elem in elems.vals()) {
      buff.add(elem)
    };
    buff
  };

  /// Creates a buffer from the elements of a mutable array.
  public func fromVarArray<X>(elems : [var X]) : Buffer<X> {
    let buff = Buffer<X>(elems.size());
    for (elem in elems.vals()) {
      buff.add(elem)
    };
    buff
  };

  public func map<X, Y>(buffer : Buffer<X>, f : X -> Y) : Buffer<Y> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(count);
    
    var i = 0;
    label l loop {
      if (i >= count) {
        break l;
      };
      newBuffer.put(i, f(buffer.get(i)));
      i += 1;
    };

    newBuffer
  };

  public func iterate<X>(buffer : Buffer<X>, f : X -> ()) {
    let count = buffer.size();

    var i = 0;
    label l loop {
      if (i >= count) {
        break l;
      };
      f(buffer.get(i));
      i += 1;
    };
  };

  public func filter<X>(buffer : Buffer<X>, predicate : X -> Bool) : Buffer<X> {
    let count = buffer.size();
    let newBuffer = Buffer<X>(count);
    
    var i = 0;
    label l loop {
      if (i >= count) {
        break l;
      };

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
    label l loop {
      if (i >= count) {
        break l;
      };
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
    label l loop {
      if (i >= count) {
        break l;
      };

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
    label l loop {
      if (i >= count) {
        break l;
      };
      newBuffer.put(i, f(i, buffer.get(i)));
      i += 1;
    };

    newBuffer
  };

  public func mapResult<X, Y, E>(buffer : Buffer<X>, f : X -> Result.Result<Y, E>) : Result.Result<Buffer<Y>, E> {
    let count = buffer.size();
    let newBuffer = Buffer<Y>(count);
    
    var i = 0;
    label l loop {
      if (i >= count) {
        break l;
      };

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
    label l loop {
      if (i >= count) {
        break l;
      };

      accumulation := combine(accumulation, buffer.get(i));

      i += 1;
    };

    accumulation
  };

  public func foldRight<X, A>(buffer : Buffer<X>, base : A, combine : (X, A) -> A) : A {
    let count = buffer.size();
    var accumulation = base;
    
    var i = 0;
    label l loop {
      if (i >= count) {
        break l;
      };

      accumulation := combine(buffer.get(count - i - 1), accumulation);

      i += 1;
    };

    accumulation
  };

  public func forAll<X>(buffer : Buffer<X>, predicate : X -> Bool) : Bool {
    let count = buffer.size();
    
    var i = 0;
    label l loop {
      if (i >= count) {
        break l;
      };
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
    label l loop {
      if (i >= count) {
        break l;
      };
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
    label l loop {
      if (i >= count) {
        break l;
      };
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
    label l loop {
      if (i >= count) {
        break l;
      };
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
    label l loop {
      if (i >= count) {
        break l;
      };
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
    label l loop {
      if (i >= count) {
        break l;
      };
      let current = buffer.get(i);
      if (lessThan(current, minSoFar)) {
        minSoFar := current;
      };
      i += 1;
    };

    minSoFar
  };

  public func isEmpty<X>(buffer : Buffer<X>) : Bool = buffer.size() == 0;

  // FIXME
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
    label outer loop {
      if (i >= count) {
        break outer;
      };

      let innerBuffer = buffer.get(i);
      let innerCount = innerBuffer.size();
      var j = 0;
      label inner loop {
        if (j >= innerCount) {
          break inner;
        };
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
    label outer loop {
      if (i >= count) {
        break outer;
      };

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

  // sort
  // Split
  // Zip
  // ZipWith
  // Combinations
  // Permutations (documentation should warn of any combinatorial explosions)
  // Chunks
  // Group
  // GroupBy
  // isSuffixOf
  // isInfixOf
  // isPrefixOf
  // isStrictSuffixOf
  // isStrictInfixOf
  // isStrictPrefixOf
  // takeWhile
  // dropWhile
  // Transpose
  // First
  // Last
  // Sublist/Subset
  // binarySearch?
  // toText (how does this interact with debug_show?)
  // indexOf
  // lastIndexOf
  // Zipper
 
}
