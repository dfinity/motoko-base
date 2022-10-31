/// Functions on Arrays

import I "IterType";
import Option "Option";
import Order "Order";
import Prim "mo:⛔";
import Result "Result";

module {
  /// Test if two arrays contain equal values
  public func equal<A>(a : [A], b : [A], eq : (A, A) -> Bool) : Bool {
    if (a.size() != b.size()) {
      return false;
    };
    var i = 0;
    while (i < a.size()) {
      if (not eq(a[i], b[i])) {
        return false;
      };
      i += 1;
    };
    return true;
  };

  /// Append the values of two input arrays
  /// @deprecated `Array.append` copies its arguments and has linear complexity; when used in a loop, consider using a `Buffer`, and `Buffer.append`, instead.
  public func append<A>(xs : [A], ys : [A]) : [A] {
    switch(xs.size(), ys.size()) {
      case (0, 0) { []; };
      case (0, _) { ys; };
      case (_, 0) { xs; };
      case (xsSize, ysSize) {
        Prim.Array_tabulate<A>(xsSize + ysSize, func (i : Nat) : A {
          if (i < xsSize) {
            xs[i];
          } else {
            ys[i - xsSize];
          };
        });
      };
    };
  };

  /// Sorts the given array, in ascending order, according to the `compare` function.
  /// This is a _stable_ sort.
  ///
  /// ```motoko
  /// import Array "mo:base/Array";
  /// import Nat "mo:base/Nat";
  /// let xs = [4, 2, 6];
  /// assert(Array.sort(xs, Nat.compare) == [2, 4, 6])
  /// ```
  public func sort<A>(xs : [A], compare : (A, A) -> Order.Order) : [A] {
    let tmp : [var A] = thaw(xs);
    sortInPlace(tmp, compare);
    freeze(tmp)
  };

  /// Sorts the given array, in ascending order, in place, according to the `compare` function.
  /// This is a _stable_ sort.
  ///
  /// ```motoko
  /// import Array "mo:base/Array";
  /// import Nat "mo:base/Nat";
  /// let xs : [var Nat] = [var 4, 2, 6, 1, 5];
  /// Array.sortInPlace(xs, Nat.compare);
  /// assert(Array.freeze(xs) == [1, 2, 4, 5, 6])
  /// ```
  public func sortInPlace<X>(xs : [var X], compare : (X, X) -> Order.Order) {
    // Stable merge sort in a bottom-up iterative style
    let size = xs.size();
    if (size == 0) {
      return;
    };
    let scratchSpace = Prim.Array_init<X>(size, null);

    let sizeDec = size - 1 : Nat;
    var currSize = 1; // current size of the subarrays being merged
    // when the current size == size, the array has been merged into a single sorted array
    while (currSize < _size) {
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
          let leftOpt = elements[left];
          let rightOpt = elements[right];
          switch (leftOpt, rightOpt) {
            case (?leftElement, ?rightElement) {
              switch (compare(leftElement, rightElement)) {
                case (#less or #equal) {
                  scratchSpace[nextSorted] := leftOpt;
                  left += 1;
                };
                case (#greater) {
                  scratchSpace[nextSorted] := rightOpt;
                  right += 1;
                };
              };
            };
            case (_, _) {
              // only sorting non-null items
              Prim.trap "Malformed buffer in sort";
            };
          };
          nextSorted += 1;
        };
        while (left < mid + 1) {
          scratchSpace[nextSorted] := elements[left];
          nextSorted += 1;
          left += 1;
        };
        while (right < rightEnd + 1) {
          scratchSpace[nextSorted] := elements[right];
          nextSorted += 1;
          right += 1;
        };

        // Copy over merged elements
        var i = leftStart;
        while (i < rightEnd + 1) {
          elements[i] := scratchSpace[i];
          i += 1;
        };

        leftStart += 2 * currSize;
      };
      currSize *= 2;
    };
  };

  /// Transform each array value into zero or more output values, appended in order
  public func chain<A, B>(xs : [A], f : A -> [B]) : [B] {
    var ys : [B] = [];
    for (i in xs.keys()) {
      ys := append<B>(ys, f(xs[i]));
    };
    ys;
  };
  /// Output array contains each array-value if and only if the predicate is true; ordering retained.
  public func filter<A>(xs : [A], f : A -> Bool) : [A] {
    var count = 0;
    let keep = 
      Prim.Array_tabulate<Bool>(
        xs.size(),
        func i {
          if (f(xs[i])) {
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
        xs[nextKeep - 1];
      }
    )
  };

  /// Output array contains each transformed optional value; ordering retained.
  public func mapFilter<A, B>(xs : [A], f : A -> ?B) : [B] {
    var count = 0;
    let options = 
      Prim.Array_tabulate<?B>(
        xs.size(),
        func i {
          let result = f(xs[i]);
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

  /// Aggregate and transform values into a single output value, by increasing indices.
  public func foldLeft<A, B>(xs : [A], initial : B, f : (B, A) -> B) : B {
    var acc = initial;
    let size = xs.size();
    var i = 0;
    while (i < size) {
      acc := f(acc, xs[i]);
      i += 1;
    };
    acc;
  };
  /// Aggregate and transform values into a single output value, by decreasing indices.
  public func foldRight<A, B>(xs : [A], initial : B, f : (A, B) -> B) : B {
    var acc = initial;
    let size = xs.size();
    var i = size;
    while (i > 0) {
      i -= 1;
      acc := f(xs[i], acc);
    };
    acc;
  };
  /// Returns optional first value for which predicate is true
  public func find<A>(xs : [A], f : A -> Bool) : ?A {
    for (x in xs.vals()) {
      if (f(x)) {
        return ?x;
      }
    };
    return null;
  };
  /// Transform mutable array into immutable array
  public func freeze<A>(xs : [var A]) : [A] {
    Prim.Array_tabulate<A>(xs.size(), func (i : Nat) : A {
      xs[i];
    });
  };
  /// Transform an array of arrays into a single array, with retained array-value order.
  public func flatten<A>(xs : [[A]]) : [A] {
    chain<[A], A>(xs, func (x : [A]) : [A] {
      x;
    });
  };
  /// Transform each value using a function, with retained array-value order.
  public func map<A, B>(xs : [A], f : A -> B) : [B] {
    Prim.Array_tabulate<B>(xs.size(), func (i : Nat) : B {
      f(xs[i]);
    });
  };
  /// Transform each entry (index-value pair) using a function.
  public func mapEntries<A, B>(xs : [A], f : (A, Nat) -> B) : [B] {
    Prim.Array_tabulate<B>(xs.size(), func (i : Nat) : B {
      f(xs[i], i);
    });
  };

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
  public func mapResult<A, R, E>(xs : [A], f : A -> Result.Result<R, E>) : Result.Result<[R], E> {
    let len : Nat = xs.size();
    var target : [var R] = [var];
    var i : Nat = 0;
    var isInit = false;
    while (i < len) {
      switch (f(xs[i])) {
        case (#err(err)) return #err(err);
        case (#ok(ok)) {
          if (not isInit) {
            isInit := true;
            target := init(len, ok);
          } else {
            target[i] := ok
          }
        };
      };
      i += 1;
    };
    #ok(freeze(target))
  };

  /// Make an array from a single value.
  public func make<A>(x: A) : [A] {
    [x];
  };
  /// Returns `xs.vals()`.
  public func vals<A>(xs : [A]) : I.Iter<A> {
    xs.vals()
  };
  /// Returns `xs.keys()`.
  public func keys<A>(xs : [A]) : I.Iter<Nat> {
    xs.keys()
  };
  /// Transform an immutable array into a mutable array.
  public func thaw<A>(xs : [A]) : [var A] {
    let xsSize = xs.size();
    if (xsSize == 0) {
      return [var];
    };
    let ys = Prim.Array_init<A>(xsSize, xs[0]);
    for (i in ys.keys()) {
      ys[i] := xs[i];
    };
    ys;
  };
  /// Initialize a mutable array with `size` copies of the initial value.
  public func init<A>(size : Nat,  initVal : A) : [var A] {
    Prim.Array_init<A>(size, initVal);
  };
  /// Initialize an immutable array of the given size, and use the `gen` function to produce the initial value for every index.
  public func tabulate<A>(size : Nat,  gen : Nat -> A) : [A] {
    Prim.Array_tabulate<A>(size, gen);
  };

  // Copy from `Iter.mo`, but `Iter` depends on `Array`.
  class range(x : Nat, y : Int) {
    var i = x;
    public func next() : ?Nat {
      if (i > y) {
         null
      } else {
        let j = i;
        i += 1;
        ?j
      }
    };
  };

  /// Initialize a mutable array using a generation function
  public func tabulateVar<A>(size : Nat,  gen : Nat -> A) : [var A] {
    if (size == 0) { return [var] };
    let xs = Prim.Array_init<A>(size, gen(0));
    for (i in range(1, size - 1)) {
      xs[i] := gen(i);
    };
    return xs;
  };

  public func reverse<A>(xs : [A]) : [A] {
    let size = xs.size();
    tabulate(size, func (n : Nat) : A {
      xs[size - 1 - n];
    });
  };
}

