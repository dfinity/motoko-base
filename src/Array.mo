/// Provides extended utility functions on Arrays.
///
/// :::warning
///
/// If you are looking for a list that can grow and shrink in size,
/// it is recommended you use either the `Buffer` or `List` data structure for
/// those purposes.
///
/// :::
///
/// :::note Assumptions
///
/// Runtime and space complexity assumes that `generator`, `equal`, and other functions execute in `O(1)` time and space.
/// :::
///
/// Import from the base library to use this module.
///
/// ```motoko name=import
/// import Array "mo:base/Array";
/// ```
///

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
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  public func init<X>(size : Nat, initValue : X) : [var X] = Prim.Array_init<X>(size, initValue);

  /// Create an immutable array of size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// let array : [Nat] = Array.tabulate<Nat>(4, func i = i * 2);
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  public func tabulate<X>(size : Nat, generator : Nat -> X) : [X] = Prim.Array_tabulate<X>(size, generator);

  /// Create a mutable array of size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// let array : [var Nat] = Array.tabulateVar<Nat>(4, func i = i * 2);
  /// array[2] := 0;
  /// array
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  public func tabulateVar<X>(size : Nat, generator : Nat -> X) : [var X] =
    Prim.Array_tabulateVar<X>(size, generator);

  /// Transforms a mutable array into an immutable array.
  ///
  /// ```motoko include=import
  ///
  /// let varArray = [var 0, 1, 2];
  /// varArray[2] := 3;
  /// let array = Array.freeze<Nat>(varArray);
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(1)` |
  public func freeze<X>(varArray : [var X]) : [X] = Prim.Array_tabulate<X>(varArray.size(), func i = varArray[i]);

  /// Transforms an immutable array into a mutable array.
  ///
  /// ```motoko include=import
  ///
  /// let array = [0, 1, 2];
  /// let varArray = Array.thaw<Nat>(array);
  /// varArray[2] := 3;
  /// varArray
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(1)` |
  public func thaw<A>(array : [A]) : [var A] = Prim.Array_tabulateVar<A>(array.size(), func i = array[i]);

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
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size1 + size2)` | `O(size1 + size2)` |
  public func equal<X>(array1 : [X], array2 : [X], equal : (X, X) -> Bool) : Bool {
    let size1 = array1.size();
    let size2 = array2.size();
    if (size1 != size2) {
      return false
    };
    var i = 0;
    while (i < size1) {
      if (not equal(array1[i], array2[i])) {
        return false
      };
      i += 1
    };
    return true
  };

  /// Returns the first value in `array` for which `predicate` returns true.
  /// If no element satisfies the predicate, returns null.
  ///
  /// ```motoko include=import
  /// let array = [1, 9, 4, 8];
  /// Array.find<Nat>(array, func x = x > 8)
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(1)` |
  ///
  public func find<X>(array : [X], predicate : X -> Bool) : ?X {
    for (element in array.vals()) {
      if (predicate element) {
        return ?element
      }
    };
    return null
  };

  /// Create a new array by appending the values of `array1` and `array2`.
  ///
  /// :::note Efficient appending
  ///
  /// `Array.append` copies its arguments and runs in linear time.
  /// For better performance in loops, consider using `Buffer` and `Buffer.append` instead.
  ///
  /// :::
  ///
  /// ```motoko include=import
  /// let array1 = [1, 2, 3];
  /// let array2 = [4, 5, 6];
  /// Array.append<Nat>(array1, array2)
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size1 + size2)` | `O(size1 + size2)` |
  public func append<X>(array1 : [X], array2 : [X]) : [X] {
    let size1 = array1.size();
    let size2 = array2.size();
    Prim.Array_tabulate<X>(
      size1 + size2,
      func i {
        if (i < size1) {
          array1[i]
        } else {
          array2[i - size1]
        }
      }
    )
  };

  /// Sorts the elements in the array according to `compare`.
  /// Sort is deterministic and stable.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [4, 2, 6];
  /// Array.sort(array, Nat.compare).
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size * log(size))` | `O(size)` |
  public func sort<X>(array : [X], compare : (X, X) -> Order.Order) : [X] {
    let temp : [var X] = thaw(array);
    sortInPlace(temp, compare);
    freeze(temp)
  };

  /// Sorts the elements in the array, __in place__, according to `compare`.
  /// Sort is deterministic, stable, and in-place.
  ///
  /// ```motoko include=import
  /// import {compare} "mo:base/Nat";
  /// let array = [var 4, 2, 6];
  /// Array.sortInPlace(array, compare);
  /// array
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size * log(size))` | `O(size)` |
  ///
  public func sortInPlace<X>(array : [var X], compare : (X, X) -> Order.Order) {
    // Stable merge sort in a bottom-up iterative style. Same algorithm as the sort in Buffer.
    let size = array.size();
    if (size == 0) {
      return
    };
    let scratchSpace = Prim.Array_init<X>(size, array[0]);

    let sizeDec = size - 1 : Nat;
    var currSize = 1; // current size of the subarrays being merged
    // when the current size == size, the array has been merged into a single sorted array
    while (currSize < size) {
      var leftStart = 0; // selects the current left subarray being merged
      while (leftStart < sizeDec) {
        let mid : Nat = if (leftStart + currSize - 1 : Nat < sizeDec) {
          leftStart + currSize - 1
        } else { sizeDec };
        let rightEnd : Nat = if (leftStart + (2 * currSize) - 1 : Nat < sizeDec) {
          leftStart + (2 * currSize) - 1
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
              left += 1
            };
            case (#greater) {
              scratchSpace[nextSorted] := rightElement;
              right += 1
            }
          };
          nextSorted += 1
        };
        while (left < mid + 1) {
          scratchSpace[nextSorted] := array[left];
          nextSorted += 1;
          left += 1
        };
        while (right < rightEnd + 1) {
          scratchSpace[nextSorted] := array[right];
          nextSorted += 1;
          right += 1
        };

        // Copy over merged elements
        var i = leftStart;
        while (i < rightEnd + 1) {
          array[i] := scratchSpace[i];
          i += 1
        };

        leftStart += 2 * currSize
      };
      currSize *= 2
    }
  };

  /// Creates a new array by reversing the order of elements in `array`.
  ///
  /// ```motoko include=import
  /// let array = [10, 11, 12];
  /// Array.reverse(array)
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(1)` |
  public func reverse<X>(array : [X]) : [X] {
    let size = array.size();
    Prim.Array_tabulate<X>(size, func i = array[size - i - 1])
  };

  /// Creates a new array by applying `f` to each element in `array`. `f` "maps"
  /// each element it is applied to of type `X` to an element of type `Y`.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  /// let array = [0, 1, 2, 3];
  /// Array.map<Nat, Nat>(array, func x = x * 3)
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  ///
  public func map<X, Y>(array : [X], f : X -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i]));

  /// Creates a new array by applying `predicate` to every element
  /// in `array`, retaining the elements for which `predicate` returns true.
  ///
  /// ```motoko include=import
  /// let array = [4, 2, 6, 1, 5];
  /// let evenElements = Array.filter<Nat>(array, func x = x % 2 == 0);
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  public func filter<X>(array : [X], predicate : X -> Bool) : [X] {
    var count = 0;
    let keep = Prim.Array_tabulate<Bool>(
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
    Prim.Array_tabulate<X>(
      count,
      func _ {
        while (not keep[nextKeep]) {
          nextKeep += 1
        };
        nextKeep += 1;
        array[nextKeep - 1]
      }
    )
  };

  /// Creates a new array by applying `f` to each element in `array` and its index.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  /// let array = [10, 10, 10, 10];
  /// Array.mapEntries<Nat, Nat>(array, func (x, i) = i * x)
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  public func mapEntries<X, Y>(array : [X], f : (X, Nat) -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i], i));

  /// Creates a new array by applying `f` to each element in `array`,
  /// and keeping all non-null elements. The ordering is retained.
  ///
  /// ```motoko include=import
  /// import {toText} "mo:base/Nat";
  ///
  /// let array = [4, 2, 0, 1];
  /// let newArray =
  ///  Array.mapFilter<Nat, Text>( // mapping from Nat to Text values
  ///    array,
  ///    func x = if (x == 0) { null } else { ?toText(100 / x) } // can't divide by 0, so return null
  ///  );
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  ///
  public func mapFilter<X, Y>(array : [X], f : X -> ?Y) : [Y] {
    var count = 0;
    let options = Prim.Array_tabulate<?Y>(
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
    Prim.Array_tabulate<Y>(
      count,
      func _ {
        while (Option.isNull(options[nextSome])) {
          nextSome += 1
        };
        nextSome += 1;
        switch (options[nextSome - 1]) {
          case (?element) element;
          case null {
            Prim.trap "Malformed array in mapFilter"
          }
        }
      }
    )
  };

  /// Creates a new array by applying `f` to each element in `array`.
  /// If any invocation of `f` produces an `#err`, returns an `#err`. Otherwise
  /// returns an `#ok` containing the new array.
  ///
  /// ```motoko include=import
  /// let array = [4, 3, 2, 1, 0];
  /// // divide 100 by every element in the array
  /// Array.mapResult<Nat, Nat, Text>(array, func x {
  ///   if (x > 0) {
  ///     #ok(100 / x)
  ///   } else {
  ///     #err "Cannot divide by zero"
  ///   }
  /// })
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  public func mapResult<X, Y, E>(array : [X], f : X -> Result.Result<Y, E>) : Result.Result<[Y], E> {
    let size = array.size();

    var error : ?Result.Result<[Y], E> = null;
    let results = Prim.Array_tabulate<?Y>(
      size,
      func i {
        switch (f(array[i])) {
          case (#ok element) {
            ?element
          };
          case (#err e) {
            switch (error) {
              case null {
                // only take the first error
                error := ?(#err e)
              };
              case _ {}
            };
            null
          }
        }
      }
    );

    switch error {
      case null {
        // unpack the option
        #ok(
          map<?Y, Y>(
            results,
            func element {
              switch element {
                case (?element) {
                  element
                };
                case null {
                  Prim.trap "Malformed array in mapResults"
                }
              }
            }
          )
        )
      };
      case (?error) {
        error
      }
    }
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
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(size)` |
  public func chain<X, Y>(array : [X], k : X -> [Y]) : [Y] {
    var flatSize = 0;
    let arrays = Prim.Array_tabulate<[Y]>(
      array.size(),
      func i {
        let subArray = k(array[i]);
        flatSize += subArray.size();
        subArray
      }
    );

    // could replace with a call to flatten,
    // but it would require an extra pass (to compute `flatSize`)
    var outer = 0;
    var inner = 0;
    Prim.Array_tabulate<Y>(
      flatSize,
      func _ {
        while (inner == arrays[outer].size()) {
          inner := 0;
          outer += 1
        };
        let element = arrays[outer][inner];
        inner += 1;
        element
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
  ///  Array.foldLeft<Nat, Nat>(
  ///    array,
  ///    0, // start the sum at 0
  ///    func(sumSoFar, x) = sumSoFar + x // this entire function can be replaced with `add`!
  ///  );
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(1)` |
  public func foldLeft<X, A>(array : [X], base : A, combine : (A, X) -> A) : A {
    var accumulation = base;

    for (element in array.vals()) {
      accumulation := combine(accumulation, element)
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
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(size)` | `O(1)` |
  public func foldRight<X, A>(array : [X], base : A, combine : (X, A) -> A) : A {
    var accumulation = base;
    let size = array.size();

    var i = size;
    while (i > 0) {
      i -= 1;
      accumulation := combine(array[i], accumulation)
    };

    accumulation
  };

  /// Flattens the array of arrays into a single array. Retains the original
  /// ordering of the elements.
  ///
  /// ```motoko include=import
  /// let arrays = [[0, 1, 2], [2, 3], [], [4]];
  /// Array.flatten<Nat>(arrays)
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(n)` | `O(n)` |
  public func flatten<X>(arrays : [[X]]) : [X] {
    var flatSize = 0;
    for (subArray in arrays.vals()) {
      flatSize += subArray.size()
    };

    var outer = 0;
    var inner = 0;
    Prim.Array_tabulate<X>(
      flatSize,
      func _ {
        while (inner == arrays[outer].size()) {
          inner := 0;
          outer += 1
        };
        let element = arrays[outer][inner];
        inner += 1;
        element
      }
    )
  };

  /// Create an array containing a single value.
  ///
  /// ```motoko include=import
  /// Array.make(2)
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(1)` | `O(1)` |
  public func make<X>(element : X) : [X] = [element];

  /// Returns an Iterator (`Iter`) over the elements of `array`.
  /// Iterator provides a single method `next()`, which returns
  /// elements in order, or `null` when out of elements to iterate over.
  ///
  /// :::note Alternative approach
  ///
  /// Alternatively, you can use `array.size()` to achieve the same result. See the example below.
  /// :::
  ///
  /// ```motoko include=import
  /// let array = [10, 11, 12];
  /// var sum = 0;
  /// for (element in array.vals()) {
  ///  sum += element;
  /// };
  /// sum
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(1)` | `O(1)` |
  public func vals<X>(array : [X]) : I.Iter<X> = array.vals();

  /// Returns an Iterator (`Iter`) over the indices of `array`.
  /// Iterator provides a single method `next()`, which returns
  /// indices in order, or `null` when out of index to iterate over.
  ///
  /// :::note Alternative approach
  /// You can also use `array.keys()` instead of this function. See example
  /// below.
  ///
  /// :::
  ///
  /// ```motoko include=import
  /// let array = [10, 11, 12];
  /// var sum = 0;
  /// for (element in array.keys()) {
  ///  sum += element;
  /// };
  /// sum
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(1)` | `O(1)` |
  public func keys<X>(array : [X]) : I.Iter<Nat> = array.keys();

  /// Returns the size of `array`.
  ///
  /// :::note Alternative approach
  ///
  /// Alternatively, you can use `array.size()` to achieve the same result. See the example below.
  /// :::
  ///
  /// ```motoko include=import
  /// let array = [10, 11, 12];
  /// let size = Array.size(array);
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(1)` | `O(1)` |
  public func size<X>(array : [X]) : Nat = array.size();

  /// Returns a new subarray from the given array provided the start index and length of elements in the subarray.
  ///
  /// :::note Limitations
  /// Traps if the start index + length is greater than the size of the array.
  /// :::
  ///
  /// ```motoko include=import
  /// let array = [1,2,3,4,5];
  /// let subArray = Array.subArray<Nat>(array, 2, 3);
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(length)` | `O(length)` |
  public func subArray<X>(array : [X], start : Nat, length : Nat) : [X] {
    if (start + length > array.size()) { Prim.trap("Array.subArray") };
    tabulate<X>(
      length,
      func(i) {
        array[start + i]
      }
    )
  };

  /// Returns the index of the first `element` in the `array`.
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.indexOf<Char>('c', array, Char.equal) == ?0;
  /// assert Array.indexOf<Char>('f', array, Char.equal) == ?2;
  /// assert Array.indexOf<Char>('g', array, Char.equal) == null;
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(array.size())` | `O(1)` |
  public func indexOf<X>(element : X, array : [X], equal : (X, X) -> Bool) : ?Nat = nextIndexOf<X>(element, array, 0, equal);

  /// Returns the index of the next occurrence of `element` in the `array` starting from the `from` index (inclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.nextIndexOf<Char>('c', array, 0, Char.equal) == ?0;
  /// assert Array.nextIndexOf<Char>('f', array, 0, Char.equal) == ?2;
  /// assert Array.nextIndexOf<Char>('f', array, 2, Char.equal) == ?2;
  /// assert Array.nextIndexOf<Char>('f', array, 3, Char.equal) == ?3;
  /// assert Array.nextIndexOf<Char>('f', array, 4, Char.equal) == null;
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(array.size())` | `O(1)` |
  public func nextIndexOf<X>(element : X, array : [X], fromInclusive : Nat, equal : (X, X) -> Bool) : ?Nat {
    var i = fromInclusive;
    let n = array.size();
    while (i < n) {
      if (equal(array[i], element)) {
        return ?i
      } else {
        i += 1
      }
    };
    null
  };

  /// Returns the index of the last `element` in the `array`.
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.lastIndexOf<Char>('c', array, Char.equal) == ?0;
  /// assert Array.lastIndexOf<Char>('f', array, Char.equal) == ?3;
  /// assert Array.lastIndexOf<Char>('e', array, Char.equal) == ?5;
  /// assert Array.lastIndexOf<Char>('g', array, Char.equal) == null;
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(array.size())` | `O(1)` |
  public func lastIndexOf<X>(element : X, array : [X], equal : (X, X) -> Bool) : ?Nat = prevIndexOf<X>(element, array, array.size(), equal);

  /// Returns the index of the previous occurrence of `element` in the `array` starting from the `from` index (exclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.prevIndexOf<Char>('c', array, array.size(), Char.equal) == ?0;
  /// assert Array.prevIndexOf<Char>('e', array, array.size(), Char.equal) == ?5;
  /// assert Array.prevIndexOf<Char>('e', array, 5, Char.equal) == ?4;
  /// assert Array.prevIndexOf<Char>('e', array, 4, Char.equal) == null;
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(array.size())` | `O(1)` |
  public func prevIndexOf<T>(element : T, array : [T], fromExclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    var i = fromExclusive;
    while (i > 0) {
      i -= 1;
      if (equal(array[i], element)) {
        return ?i
      }
    };
    null
  };

  /// Returns an iterator over a slice of the given array.
  ///
  /// ```motoko include=import
  /// let array = [1, 2, 3, 4, 5];
  /// let s = Array.slice<Nat>(array, 3, array.size());
  /// assert s.next() == ?4;
  /// assert s.next() == ?5;
  /// assert s.next() == null;
  ///
  /// let s = Array.slice<Nat>(array, 0, 0);
  /// assert s.next() == null;
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(1)` | `O(1)` |
  public func slice<X>(array : [X], fromInclusive : Nat, toExclusive : Nat) : I.Iter<X> = object {
    var i = fromInclusive;

    public func next() : ?X {
      if (i >= toExclusive) {
        return null
      };
      let result = array[i];
      i += 1;
      return ?result
    }
  };

  /// Returns a new subarray of given length from the beginning or end of the given array.
  ///
  /// Returns the entire array if the length is greater than the size of the array.
  ///
  /// ```motoko include=import
  /// let array = [1, 2, 3, 4, 5];
  /// assert Array.take(array, 2) == [1, 2];
  /// assert Array.take(array, -2) == [4, 5];
  /// assert Array.take(array, 10) == [1, 2, 3, 4, 5];
  /// assert Array.take(array, -99) == [1, 2, 3, 4, 5];
  /// ```
  ///
  /// | Runtime   | Space     |
  /// |-----------|-----------|
  /// | `O(length)` | `O(length)` |
  public func take<T>(array : [T], length : Int) : [T] {
    let len = Prim.abs(length);
    let size = array.size();
    let resSize = if (len < size) { len } else { size };
    let start : Nat = if (length > 0) 0 else size - resSize;
    subArray(array, start, resSize)
  }
}
