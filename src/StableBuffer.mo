/// Growing buffers
///
/// This module defines buffers that grow, with a general element type.
///
/// It is like `Buffer`, except that it eschews the OO features of Motoko
/// so that the representation be used within the types of stable variables.
///

import Prim "mo:⛔";
import Array "Array";

module {

  public type Buffer<X> = {
    var count : Nat;
    var elems : [var X];
  };

  /// Create from immutable array, by copying.  See also makeFrom.
  public func make<X>(elems_ : [X]) : Buffer<X> {
    { var count = elems_.size();
      var elems = Array.thaw(elems_) }
  };

  /// Uses the mutable array as part of an initial buffer, directly.
  public func makeFrom<X>(elems : [var X]) : Buffer<X> {
    { var count = elems.size();
      var elems
    }
  };

  public func empty<X>() : Buffer<X> {
    make([])
  };


  /// Adds a single element to the buffer.
  public func add<X>(b : Buffer<X>, elem : X) {
    if (b.count == b.elems.size()) {
      let size = if (b.count == 0) { 1 } else { 2 * b.elems.size() };
      let elems2 = Prim.Array_init<X>(size, elem);
      var i = 0;
      label l loop {
        if (i >= b.count) break l;
        elems2[i] := b.elems[i];
        i += 1;
      };
      b.elems := elems2;
    };
    b.elems[b.count] := elem;
    b.count += 1;
  };

  /// Removes the item that was inserted last and returns it or `null` if no
  /// elements had been added to the Buffer.
  public func removeLast<X>(b : Buffer<X>) : ?X {
    if (b.count == 0) {
      null
    } else {
      b.count -= 1;
      ?b.elems[b.count]
    };
  };

  /// Append two buffer's content, as a third buffer result.
  public func concat<X>(b1 : Buffer<X>, b2 : Buffer<X>) : Buffer<X> {
    { var count = b1.count + b2.count ;
      var elems = Array.tabulateVar(
        // no extra slack space -- perhaps add as another parameter?
        b1.count + b2.count,
        func (i : Nat) : X { if (i < b1.count) { b1.elems[i] }
                             else { b2.elems[i - b1.count] }})
    }
  };

  /// Append elements of second buffer to end of first buffer.
  public func append<X>(b1 : Buffer<X>, b2 : Buffer<X>) {
    for (elem in b2.elems.vals()) {
      add(b1, elem)
    }
  };

  /// Returns the current number of elements.
  public func size<X>(b : Buffer<X>) : Nat =
    b.count;

  /// Resets the buffer.
  public func clear<X>(b : Buffer<X>) =
    b.count := 0;

  /// Returns a copy of this buffer.
  public func clone<X>(b : Buffer<X>) : Buffer<X> {
    { var count = b.count ;
      var elems = Array.tabulateVar(b.elems.size(), func(i : Nat) : X { b.elems[i] })
    }
  };

  /// Returns an `Iter` over the elements of this buffer.
  public func vals<X>(b : Buffer<X>) : { next : () -> ?X } = object {
    var pos = 0;
    public func next() : ?X {
      // to do -- detect if buffer has mutated; trap here if so.
      if (pos == b.count) { null } else {
        let elem = ?b.elems[pos];
        pos += 1;
        elem
      }
    }
  };

  /// Creates a new array containing this buffer's elements.
  public func toArray<X>(b : Buffer<X>) : [X] =
    // immutable clone of array
    Prim.Array_tabulate<X>(
      b.count,
      func(x : Nat) : X { b.elems[x] }
    );

  /// Creates a mutable array containing this buffer's elements.
  public func toVarArray<X>(b : Buffer<X>) : [var X] {
    if (b.count == 0) { [var] } else {
      let a = Prim.Array_init<X>(b.count, b.elems[0]);
      var i = 0;
      label l loop {
        if (i >= b.count) break l;
        a[i] := b.elems[i];
        i += 1;
      };
      a
    }
  };

  /// Gets the `i`-th element of this buffer. Traps if  `i >= count`. Indexing is zero-based.
  public func get<X>(b : Buffer<X>, i : Nat) : X {
    assert(i < b.count);
    b.elems[i]
  };

  /// Gets the `i`-th element of the buffer as an option. Returns `null` when `i >= count`. Indexing is zero-based.
  public func getOpt<X>(b : Buffer<X>, i : Nat) : ?X {
    if (i < b.count) {
      ?b.elems[i]
    }
    else {
      null
    }
  };

  /// Overwrites the current value of the `i`-entry of  this buffer with `elem`. Traps if the
  /// index is out of bounds. Indexing is zero-based.
  public func put<X>(b : Buffer<X>, i : Nat, elem : X) {
    assert(i < b.count);
    b.elems[i] := elem;
  };

}
