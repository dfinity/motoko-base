/**
[#mod-Array]
= Array

The `Array` module provides functions for creating and manipulating arrays.
*/

import Prim "mo:prim";
module {
  /**
  Determine if the number of elements in one array is equal
  to the number of elements in another array.
  The function returns true if the arrays are of equal length.
  */

  public func equals<A>(a : [A], b : [A], eq : (A,A) -> Bool) : Bool {
    if (a.len() != b.len()) { 
      return false; 
    };
    var i = 0;
    while (i < a.len()) {
      if (not eq(a[i],b[i])) { 
        return false; 
      };
      i += 1;
    };
    return true; 
  };

  /**
  Append an element to the end of an array.
  */

  public func append<A>(xs : [A], ys : [A]) : [A] {
    switch(xs.len(), ys.len()) {
      case (0, 0) { []; };
      case (0, _) { ys; };
      case (_, 0) { xs; };
      case (xsLen, ysLen) {
        Prim.Array_tabulate<A>(xsLen + ysLen, func (i : Nat) : A {
          if (i < xsLen) {
            xs[i];
          } else {
            ys[i - xsLen];
          };
        });
      };
    };
  };

  /**
  Apply the specified number of elements from one array to another 
  array.
  */

  public func apply<A, B>(fs : [A -> B], xs : [A]) : [B] {
    var ys : [B] = [];
    for (f in fs.vals()) {
      ys := append<B>(ys, map<A, B>(f, xs));
    };
    ys;
  };

  /**
  Bind the elements from one array to the elements of another array.
  */

  public func bind<A, B>(xs : [A], f : A -> [B]) : [B] {
    var ys : [B] = [];
    for (i in xs.keys()) {
      ys := append<B>(ys, f(xs[i]));
    };
    ys;
  };

  /**
  Enumerate the elements in an array.
  */
  public func enumerate<A>(xs : [A]) : [(A, Nat)] {
    Prim.Array_tabulate<(A, Nat)>(xs.len(), func (i : Nat) : (A, Nat) {
      (xs[i], i);
    });
  };

  /**
  Create a new array with only those elements of the original 
  arrary for which the given function (often called 
  the _predicate_) returns true.
  */
  public func filter<A>(f : A -> Bool, xs : [A]) : [A] {
    var ys : [A] = [];
    for (x in xs.vals()) {
      if (f(x)) {
        ys := append<A>(ys, [x]);
      };
    };
    ys;
  };

  /**
  Fold the array left-to-right.
  */
  public func foldl<A, B>(f : (B, A) -> B, initial : B, xs : [A]) : B {
    var acc = initial;
    let len = xs.len();
    var i = 0;
    while (i < len) {
      acc := f(acc, xs[i]);
      i += 1;
    };
    acc;
  };

  /**
  Fold the array right-to-left.
  */
  public func foldr<A, B>(f : (A, B) -> B, initial : B, xs : [A]) : B {
    var acc = initial;
    let len = xs.len();
    var i = len;
    while (i > 0) {
      i -= 1;
      acc := f(xs[i], acc);
    };
    acc;
  };

  /**
  Return the first element for which the given predicate `f` is 
  true, if such an element exists.
  */
  public func find<A>(f : A -> Bool, xs : [A]) : ?A {
    for (x in xs.vals()) {
      if (f(x)) {
        return ?x;
      }
    };
    return null;
  };

  /**
  Freeze the number of elements allowed for a given array.
  */
  public func freeze<A>(xs : [var A]) : [A] {
    Prim.Array_tabulate<A>(xs.len(), func (i : Nat) : A {
      xs[i];
    });
  };

  /**
  Add an element to a given array.
  */
  public func join<A>(xs : [[A]]) : [A] {
    bind<[A], A>(xs, func (x : [A]) : [A] {
      x;
    });
  };

  /**
  Call the given function on each element in an array and use the 
  results to create a new array.
  */
  public func map<A, B>(f : A -> B, xs : [A]) : [B] {
    Prim.Array_tabulate<B>(xs.len(), func (i : Nat) : B {
      f(xs[i]);
    });
  };

  /**
  Call the given function on each element in an array and use the 
  results to create a new indexed array.
  */
  public func mapWithIndex<A, B>(f : (A, Nat) -> B, xs : [A]) : [B] {
    Prim.Array_tabulate<B>(xs.len(), func (i : Nat) : B {
      f(xs[i], i);
    });
  };

  /**
  ?
  */
  public func pure<A>(x: A) : [A] {
    [x];
  };

  /**
  ?
  */
  public func thaw<A>(xs : [A]) : [var A] {
    let xsLen = xs.len();
    if (xsLen == 0) {
      return [var];
    };
    let ys = Prim.Array_init<A>(xsLen, xs[0]);
    for (i in ys.keys()) {
      ys[i] := xs[i];
    };
    ys;
  };

  /**
  Set the initial length of a mutable array.
  */
  public func init<A>(len : Nat,  x : A) : [var A] {
    Prim.Array_init<A>(len, x);
  };

  /**
  Calculate the length of an array.
  */
  public func tabulate<A>(len : Nat,  gen : Nat -> A) : [A] {
    Prim.Array_tabulate<A>(len, gen);
  };

  /**
  Set a range of values for an array.
  */
  // copy from iter.mo, but iter depends on array
  class range(x : Nat, y : Int) {
    var i = x;
    public func next() : ?Nat { if (i > y) null else {let j = i; i += 1; ?j} };
  };

  /**
  ?
  */
  public func tabulateVar<A>(len : Nat,  gen : Nat -> A) : [var A] {
    if (len == 0) { return [var] };
    let xs = Prim.Array_init<A>(len, gen 0);
    for (i in range(1,len-1)) {
      xs[i] := gen i;
    };
    return xs;
  };
}
