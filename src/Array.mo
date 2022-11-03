/// Provides extended utility functions on Arrays. Note the difference between
/// mutable and non-mutable arrays below.
///
/// WARNING: If you are looking for a list that can grow and shrink in size,
/// it is recommended you use either the Buffer class or the List class for
/// those purposes. Arrays must be created with a fixed size.
///
/// Import from the base library to use this module.
/// ```motoko name=import
/// import Array "mo:base/Array";
/// ```

import I "IterType";
import Option "Option";
import Order "Order";
import Prim "mo:⛔";
import Result "Result";

module {
  /// Create a mutable array with `size` copies of the initial value.
  ///
  /// ```motoko include=import
  /// let array = Array.init<Nat>(4, 2);
  /// ```
  ///
  /// Runtime: O(size)
  /// Space: O(size)
  public func init<X>(size : Nat,  initVal : X) : [var X] = 
    Prim.Array_init<X>(size, initVal);

  /// Create an immutable array of the size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// let array : [Nat] = Array.tabulate<Nat>(4, func i = i * 2);
  /// ```
  ///
  /// Runtime: O(size)
  /// Space: O(size)
  /// 
  /// *Runtime and space assumes that `generator` runs in O(1) time and space.
  public func tabulate<X>(size : Nat,  generator : Nat -> X) : [X] =
    Prim.Array_tabulate<X>(size, generator);

  /// Create a mutable array of the size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// let array : [var Nat] = Array.tabulateVar<Nat>(4, func i = i * 2);
  /// array[2] := 0;
  /// array
  /// ```
  ///
  /// Runtime: O(size)
  /// Space: O(size)
  /// 
  /// *Runtime and space assumes that `generator` runs in O(1) time and space.
  public func tabulateVar<X>(size : Nat,  generator : Nat -> X) : [var X] {
    // FIXME add this as a primitive in the RTS
    if (size == 0) { return [var] };
    let array = Prim.Array_init<X>(size, generator 0);
    var i = 0;
    while (i < size) {
      array[i] := generator i;
      i += 1;
    };
    array
  };


  /// Tests if two arrays contain equal values (i.e. they represent the same
  /// list of elements). Uses `equal` to compare elements in the arrays.
  ///
  /// ```motoko include=import
  /// // Use the equal function from the Nat module to compare Nats
  /// import {equal} "mo:base/Nat"; 
  ///
  /// let array1 = [0, 1, 2, 3];
  /// let array2 = [0, 1, 2, 3];
  /// Array.equal(array1, array2, equal)
  /// ```
  ///
  /// Runtime: O(size1 + size2)
  /// Space: O(1)
  /// 
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func equal<X>(array1 : [X], array2 : [X], equal : (X, X) -> Bool) : Bool {
    let size1 = array1.size();
    let size2 = array2.size();
    if (size1 != size2) {
      return false;
    };
    var i = 0;
    while (i < size1) {
      if (not equal(array1[i], array2[i])) {
        return false;
      };
      i += 1;
    };
    return true;
  };

  /// Create a new array by appending the values of the two arrays
  /// @deprecated `Array.append` copies its arguments and has linear complexity; when used in a loop, consider using a `Buffer`, and `Buffer.append`, instead.
  public func append<X>(array1 : [X], array2 : [X]) : [X] {
    let size1 = array1.size();
    let size2 = array2.size();
    Prim.Array_tabulate<X>(size1 + size2, func i {
      if (i < size1) {
        array1[i];
      } else {
        array2[i - size1];
      };
    });
  };

  // FIXME this stack overflows. Should test with new implementation of sortInPlace
  /// Sorts the elements in the array according to `compare`.
  /// Sort is deterministic and stable.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [4, 2, 6];
  /// Array.sort(array, Nat.compare)
  /// ```
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sort<X>(array : [X], compare : (X, X) -> Order.Order) : [X] {
    let temp : [var X] = thaw(array);
    sortInPlace(temp, compare);
    freeze(temp)
  };

  /// Sorts the elements in the array, __in place__, according to `compare`.
  /// Sort is deterministic, stable, and in-place.
  ///
  /// ```motoko include=import
  /// 
  /// import {compare} "mo:base/Nat";
  ///
  /// let array = [var 4, 2, 6];
  /// Array.sortInPlace(array, compare);
  /// array
  /// ```
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sortInPlace<X>(array : [var X], compare : (X, X) -> Order.Order) {
    // Stable merge sort in a bottom-up iterative style
    let size = array.size();
    if (size == 0) {
      return;
    };
    let scratchSpace = Prim.Array_init<X>(size, array[0]);

    let sizeDec = size - 1 : Nat;
    var currSize = 1; // current size of the subarrays being merged
    // when the current size == size, the array has been merged into a single sorted array
    while (currSize < size) {
      var leftStart = 0; // selects the current left subarray being merged
      while (leftStart < sizeDec) {
        let mid : Nat = if (leftStart + currSize - 1 : Nat < sizeDec) {
          leftStart + currSize - 1;
        } else { sizeDec };
        let rightEnd : Nat = if (leftStart + (2 * currSize) - 1 : Nat < sizeDec) {
          leftStart + (2 * currSize) - 1;
        } else { sizeDec };

        // Merge subarrays elements[leftStart...mid] and elements[mid+1...rightEnd]
        var left = leftStart;
        var right = mid + 1;
        var nextSorted = leftStart;
        while (left < mid + 1 and right < rightEnd + 1) {
          let leftElement = array[left];
          let rightElement = array[right];
          switch (compare(leftElement, rightElement)) {
            case (#less or #equal) {
              scratchSpace[nextSorted] := leftElement;
              left += 1;
            };
            case (#greater) {
              scratchSpace[nextSorted] := rightElement;
              right += 1;
            };
          };
          nextSorted += 1;
        };
        while (left < mid + 1) {
          scratchSpace[nextSorted] := array[left];
          nextSorted += 1;
          left += 1;
        };
        while (right < rightEnd + 1) {
          scratchSpace[nextSorted] := array[right];
          nextSorted += 1;
          right += 1;
        };

        // Copy over merged elements
        var i = leftStart;
        while (i < rightEnd + 1) {
          array[i] := scratchSpace[i];
          i += 1;
        };

        leftStart += 2 * currSize;
      };
      currSize *= 2;
    };
  };

  /// Creates a new array by applying `k` to each element in `array`,
  /// and concatenating the resulting arrays in order. This operation
  /// is similar to what in other functional languages is known as monadic bind.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [1, 2, 3, 4];
  /// Array.chain<Nat, Int>(array, func x = [x, -x])
  ///
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `k` runs in O(1) time and space.
  public func chain<X, Y>(array : [X], k : X -> [Y]) : [Y] {
    var flatSize = 0;
    let subArrays = Prim.Array_tabulate<[Y]>(array.size(), func i {
      let subArray = k(array[i]);
      flatSize += subArray.size();
      subArray
    });
    // could replace with a call to flatten,
    // but it would require an extra pass (to compute `flatSize`)
    var outer = 0;
    var inner = 0;
    Prim.Array_tabulate<Y>(flatSize, func _ {
      let subArray = subArrays[outer];
      let element = subArray[inner];
      inner += 1;
      if (inner == subArray.size()) {
        inner := 0;
        outer += 1;
      };
      element
    })
  };

  /// Creates a new array by applied `predicate` to every element
  /// in `array`, and keeping elements for which `predicate` returns true. 
  ///
  /// ```motoko include=import
  /// let array = [4, 2, 6, 1, 5];
  /// let evenElements = Array.filter<Nat>(array, func x = x % 2 == 0);
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func filter<A>(array : [A], predicate : A -> Bool) : [A] {
    var count = 0;
    let keep = 
      Prim.Array_tabulate<Bool>(
        array.size(),
        func i {
          if (predicate(array[i])) {
            count += 1;
            true
          } else {
            false
          }
        }
      );
    var nextKeep = 0;
    Prim.Array_tabulate<A>(
      count,
      func _ {
        while (not keep[nextKeep]) {
          nextKeep += 1;
        };
        nextKeep += 1;
        array[nextKeep - 1];
      }
    )
  };

  /// Creates a new array by applying `f` to each element in `array`,
  /// and keeping all non-null elements. The ordering is retained.
  ///
  /// ```motoko include=import
  /// import {toText} "mo:base/Nat";
  ///
  /// let array = [4, 2, 0, 1];
  /// let newArray = 
  ///   Array.mapFilter<Nat, Text>( // mapping from Nat to Text values
  ///     array,
  ///     func x = if (x == 0) { null } else { ?toText(100 / x) } // can't divide by 0, so return null
  ///   );
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapFilter<A, B>(array : [A], f : A -> ?B) : [B] {
    var count = 0;
    let options = 
      Prim.Array_tabulate<?B>(
        array.size(),
        func i {
          let result = f(array[i]);
          switch (result) {
            case (?element) {
              count += 1;
              result
            };
            case null {
              null
            }
          } 
        }
      );
    
    var nextSome = 0;
    Prim.Array_tabulate<B>(
      count,
      func _ {
        while (Option.isNull(options[nextSome])) {
          nextSome += 1;
        };
        nextSome += 1;
        switch(options[nextSome - 1]) {
          case(?element) element;
          case null {
            Prim.trap "Malformed array in mapFilter"
          }
        }
      }
    )
  };

  /// Collapses the elements in `array` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// ```motoko include=import
  /// import {add} "mo:base/Nat";
  ///
  /// let array = [4, 2, 0, 1];
  /// let sum = 
  ///   Array.foldLeft<Nat, Nat>(
  ///     array,
  ///     0, // start the sum at 0
  ///     func(sumSoFar, x) = sumSoFar + x // this entire function can be replaced with `add`!
  ///   );
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldLeft<X, A>(array : [X], base : A, combine : (A, X) -> A) : A {
    var accumulation = base;

    for (element in array.vals()) {
      accumulation := combine(accumulation, element);
    };

    accumulation
  };

  /// Collapses the elements in `array` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// ```motoko include=import
  /// import {toText} "mo:base/Nat";
  ///
  /// let array = [1, 9, 4, 8];
  /// let bookTitle = Array.foldRight<Nat, Text>(array, "", func(x, acc) = toText(x) # acc);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldRight<X, Y>(array : [X], base : Y, combine : (X, Y) -> Y) : Y {
    var accumulation = base;
    let size = array.size();

    var i = size;
    while (i > 0) {
      i -= 1;
      accumulation := combine(array[i], accumulation);
    };

    accumulation;
  };

  /// Returns first value in `array` for which `predicate` returns true.
  /// If no element satisfies the predicate, returns null.
  ///
  /// ```motoko include=import
  /// let array = [1, 9, 4, 8];
  /// Array.find<Nat>(array, func x = x > 8)
  /// ```
  public func find<X>(array : [X], predicate : X -> Bool) : ?X {
    for (element in array.vals()) {
      if (predicate element) {
        return ?element;
      }
    };
    return null;
  };

  /// Transform mutable array into immutable array
  public func freeze<X>(varArray : [var X]) : [X] = 
    Prim.Array_tabulate<X>(varArray.size(), func i = varArray[i]);

  /// Transform an immutable array into a mutable array.
  public func thaw<A>(array : [A]) : [var A] {
    let size = array.size();
    if (size == 0) {
      return [var];
    };
    let newArray = Prim.Array_init<A>(size, array[0]);
    var i = 0;
    while (i < size) {
      newArray[i] := array[i];
      i += 1;
    };
    newArray
  };

  // FIXME add var versions of these or not?

  /// Transform an array of arrays into a single array, with retained array-value order.
  public func flatten<X>(arrays : [[X]]) : [X] {
    var flatSize = 0;
    for (subArray in arrays.vals()) {
      flatSize += subArray.size()
    };

    var outer = 0;
    var inner = 0;
    Prim.Array_tabulate<X>(flatSize, func _ {
      let subArray = arrays[outer];
      let element = subArray[inner];
      inner += 1;
      if (inner == subArray.size()) {
        inner := 0;
        outer += 1;
      };
      element
    })
  };

  /// Transform each value using a function, with retained array-value order.
  public func map<X, Y>(array : [X], f : X -> Y) : [Y] = 
    Prim.Array_tabulate<Y>(array.size(), func i = f(array[i]));

  /// Transform each entry (index-value pair) using a function.
  public func mapEntries<X, Y>(array : [X], f : (X, Nat) -> Y) : [Y] = 
    Prim.Array_tabulate<Y>(array.size(), func i = f(array[i], i));  
  // FIXME the arguments ordering are flipped between this and the buffer class
  // probably can't avoid breaking changes at some point

  /// Maps a Result-returning function over an Array and returns either
  /// the first error or an array of successful values.
  ///
  /// ```motoko
  /// import Array "mo:base/Array";
  /// import Result "mo:base/Result";
  /// import Int "mo:base/Int";
  /// func makeNatural(x : Int) : Result.Result<Nat, Text> =
  ///   if (x >= 0) {
  ///     #ok(Int.abs(x))
  ///   } else {
  ///     #err(Int.toText(x) # " is not a natural number.")
  ///   };
  ///
  /// assert(Array.mapResult<Int, Nat, Text>([0, 1, 2], makeNatural) == #ok([0, 1, 2]));
  /// assert(Array.mapResult([-1, 0, 1], makeNatural) == #err("-1 is not a natural number."));
  /// ```
  public func mapResult<X, Y, E>(array : [X], f : X -> Result.Result<Y, E>) : Result.Result<[Y], E> {
    let size = array.size();
    var target : [var Y] = [var];
    var isInit = false;

    var error : ?Result.Result<[Y], E> = null;
    let results = Prim.Array_tabulate<?Y>(size, func i {
      switch (f(array[i])) {
        case (#ok element) {
          ?element
        };
        case (#err e) {
          switch (error) {
            case null { // only take the first error
              error := ?(#err e);
            };
            case _ { };
          };
          null
        }
      }
    });

    switch error {
      case null {
        // unpack the option
        #ok(map<?Y, Y>(results, func element {
          switch element {
            case (?element) {
              element
            };
            case null {
              Prim.trap "Malformed array in mapResults"
            };
          }
        }));
      };
      case (?error) {
        error
      };
    }
  };

  /// Make an array from a single value.
  public func make<X>(element : X) : [X] = [element];

  /// Returns `array.vals()`.
  public func vals<X>(array : [X]) : I.Iter<X> = array.vals();

  /// Returns `array.keys()`.
  public func keys<X>(array : [X]) : I.Iter<Nat> = array.keys();

  public func reverse<X>(array : [X]) : [X] {
    let size = array.size();
    Prim.Array_tabulate<X>(size, func i = array[size - i - 1]);
  };
}

