/// Purely-functional, singly-linked lists.

import Array "Array";
import Option "Option";

module {

  // A singly-linked list consists of zero or more _cons cells_, wherein
  // each cell contains a single list element (the cell's _head_), and a pointer to the
  // remainder of the list (the cell's _tail_).
  public type List<T> = ?(T, List<T>);

  /// Create an empty list.
  public func nil<T>() : List<T> = null;

  /// Check whether a list is empty and return true if the list is empty.
  public func isNil<T>(l : List<T>) : Bool {
      switch l {
      case null { true  };
      case _    { false };
      }
    };

  /// Construct a list by pre-pending a value.
  /// This function is similar to a `list.cons(item)` function.
  public func push<T>(x : T, l : List<T>) : List<T> = ?(x, l);

  /// Return the last element of the list, if present.
  public func last<T>(l : List<T>) : ?T {
    switch l {
    case null        { null };
    case (?(x,null)) { ?x };
    case (?(_,t))    { last<T>(t) };
    }
  };

  /// Treat the list as a stack.
  /// This function combines the `head` and (non-failing) `tail` operations into one operation.
  public func pop<T>(l : List<T>) : (?T, List<T>) {
    switch l {
    case null      { (null, null) };
    case (?(h, t)) { (?h, t) };
    }
  };

  /// Return the length of the list.
  public func len<T>(l : List<T>) : Nat {
    func rec(l : List<T>, n : Nat) : Nat {
      switch l {
        case null     { n };
        case (?(_,t)) { rec(t,n+1) };
      }
    };
    rec(l,0)
  };

  /// Test the list length against a maximum value and return true if
  /// the list length is less than or equal to the value specified.
  public func lenIsEqLessThan<T>(l : List <T>, i : Nat) : Bool {
    switch l {
      case null true;
      case (?(_, t)) {
        if (i == 0) { false }
        else { lenIsEqLessThan<T>(t, i - 1) }
      };
    };
  };

  /// Return the list length unless the number of items in the list exceeds
  /// a maximum value. If the list length exceed the maximum, the function
  /// returns `null`.
  public func lenClamp<T>(l : List<T>, max : Nat) : ?Nat {
    func rec(l : List<T>, max : Nat, i : Nat) : ?Nat {
      switch l {
        case null { ?i };
        case (?(_, t)) {
          if ( i > max ) { null }
          else { rec(t, max, i + 1) }
        };
      }
    };
    rec(l, max, 0)
  };

  /// Access any item in a list, zero-based.
  ///
  /// NOTE: Indexing into a list is a linear operation, and usually an
  /// indication that a list might not be the best data structure
  /// to use.
  public func nth<T>(l : List<T>, n : Nat) : ?T {
    switch (n, l) {
    case (_, null)     { null };
    case (0, (?(h,t))) { ?h };
    case (_, (?(_,t))) { nth<T>(t, n - 1) };
    }
  };

  /// Reverse the list; tail recursive.
  public func rev<T>(l : List<T>) : List<T> {
    func rec(l : List<T>, r : List<T>) : List<T> {
      switch l {
            case null     { r };
            case (?(h,t)) { rec(t,?(h,r)) };
      }
    };
    rec(l, null)
  };

  /// Call the given function with each list element in turn.
  ///
  /// This function is equivalent to the `app` function in Standard ML Basis,
  /// and the `iter` function in OCaml.
  public func iter<T>(l : List<T>, f : T -> ()) {
    switch l {
      case null     { () };
      case (?(h,t)) { f(h) ; iter<T>(t, f) };
    }
  };

  /// Call the given function on each list element and collect the results
  /// in a new list.
  public func map<T,S>(l : List<T>, f:T -> S) : List<S> {
    switch l {
      case null     { null };
      case (?(h,t)) { ?(f(h),map<T,S>(t,f)) };
    }
  };

  /// Create a new list with only those elements of the original list for which
  /// the given function (often called the _predicate_) returns true.
  public func filter<T>(l : List<T>, f:T -> Bool) : List<T> {
    switch l {
      case null { null };
      case (?(h,t)) {
        if (f(h)) {
          ?(h,filter<T>(t, f))
        } else {
          filter<T>(t, f)
        }
      };
    };
  };

  /// Create two new lists from the results of a given function (`f`).
  /// The first list only includes the elements for which the given
  /// function `f` returns true and tThe second list only includes
  /// the elements for which the function returns false.
  ///
  /// In some languages, this operation is also known as a `partition`
  /// function.
  public func split<T>(l : List<T>, f:T -> Bool) : (List<T>, List<T>) {
    switch l {
      case null { (null, null) };
      case (?(h,t)) {
        if (f(h)) { // call f in-order
          let (l,r) = split<T>(t, f);
          (?(h,l), r)
        } else {
          let (l,r) = split<T>(t, f);
          (l, ?(h,r))
        }
      };
    };
  };

  /// Call the given function on each list element, and collect the non-null results
  /// in a new list.
  public func mapFilter<T,S>(l : List<T>, f:T -> ?S) : List<S> {
    switch l {
      case null { null };
      case (?(h,t)) {
        switch (f(h)) {
          case null { mapFilter<T,S>(t, f) };
          case (?h_){ ?(h_,mapFilter<T,S>(t, f)) };
        }
      };
    };
  };

  /// Append the elements from one list to another list.
  public func append<T>(l : List<T>, m : List<T>) : List<T> {
    func rec(l : List<T>) : List<T> {
      switch l {
      case null     { m };
      case (?(h,t)) {?(h,rec(t))};
      }
    };
    rec(l)
  };

  /// Concatenate a list of lists.
  ///
  /// In some languages, this operation is also known as a `list join`.
  public func concat<T>(l : List<List<T>>) : List<T> {
    // tail recursive, but requires "two passes"
      // 1/2: fold from left to right, reverse-appending the sublists...
      let r = foldLeft<List<T>, List<T>>(l, null, func(a,b) { revAppend<T>(a,b) });
      // 2/2: ...re-reverse the elements, to their original order:
      rev<T>(r)
    };

  // Internal utility-function
  func revAppend<T>(l1 : List<T>, l2 : List<T>) : List<T> {
    switch l1 {
    case null     { l2 };
    case (?(h,t)) { revAppend<T>(t, ?(h,l2)) };
    }
  };

  /// Take the `n` number of elements from the prefix of the given list.
  /// If the given list has fewer than `n` elements, this function returns
  /// a copy of the full input list.
  public func take<T>(l : List<T>, n:Nat) : List<T> {
    switch (l, n) {
    case (_, 0) { null };
    case (null,_) { null };
    case (?(h, t), m) {?(h, take<T>(t, m - 1))};
    }
  };

  /// Drop all but the first  `n` elements from the given list.
  public func drop<T>(l : List<T>, n:Nat) : List<T> {
    switch (l, n) {
      case (l_,     0) { l_ };
      case (null,   _) { null };
      case ((?(h,t)), m) { drop<T>(t, m - 1) };
    }
  };

  /// Fold the list left-to-right using the given function (`f`).
  public func foldLeft<T, S>(l : List<T>, a:S, f:(T,S) -> S) : S {
    switch l {
      case null     { a };
      case (?(h,t)) { foldLeft<T,S>(t, f(h,a), f) };
    };
  };

  /// Fold the list right-to-left using the given function (`f`).
  public func foldRight<T,S>(l : List<T>, a:S, f:(T,S) -> S) : S {
    switch l {
      case null     { a };
      case (?(h,t)) { f(h, foldRight<T,S>(t, a, f)) };
    };
  };

  /// Return the first element for which the given predicate `f` is true,
  /// if such an element exists.
  public func find<T>(l: List<T>, f:T -> Bool) : ?T {
    switch l {
      case null     { null };
      case (?(h,t)) { if (f(h)) { ?h } else { find<T>(t, f) } };
    };
  };

  /// Return true if there exists a list element for which
  /// the given predicate `f` is true.
  public func exists<T>(l: List<T>, f:T -> Bool) : Bool {
    switch l {
      case null     { false };
      case (?(h,t)) { f(h) or exists<T>(t, f)};
    };
  };

  /// Return true if the given predicate `f` is true for all list
  /// elements.
  public func all<T>(l: List<T>, f:T -> Bool) : Bool {
    switch l {
      case null     { true };
      case (?(h,t)) { f(h) and all<T>(t, f) };
    }
  };

  /// Merge two ordered lists into a single ordered list.
  /// This function requires both list to be ordered as specified
  /// by the given relation `lte`.
  public func merge<T>(l1: List<T>, l2: List<T>, lte:(T,T) -> Bool) : List<T> {
    switch (l1, l2) {
      case (null, _) { l2 };
      case (_, null) { l1 };
      case (?(h1,t1), ?(h2,t2)) {
        if (lte(h1,h2)) {
          ?(h1, merge<T>(t1, l2, lte))
        } else {
          ?(h2, merge<T>(l1, t2, lte))
        }
      };
    }
  };

  /// Compare two lists using lexicographic ordering specified by the given relation `lte`.

  // To do: Eventually, follow `collate` design from Standard ML Basis, with real sum
  // types, use 3-valued `order` type here.
  public func lessThanEq<T>(l1: List<T>, l2: List<T>, lte:(T,T) -> Bool) : Bool {
    switch (l1, l2) {
      case (null, _) { true };
      case (_, null) { false };
      case (?(h1,t1), ?(h2,t2)) { lte(h1,h2) and lessThanEq<T>(t1, t2, lte) };
    };
  };

  /// Compare two lists for equality as specified by the given relation `eq` on the elements.
  ///
  /// The function `isEq(l1, l2)` is equivalent to `lessThanEq(l1,l2) && lessThanEq(l2,l1)`,
  /// but the former is more efficient.
  public func isEq<T>(l1: List<T>, l2: List<T>, eq:(T,T) -> Bool) : Bool {
    switch (l1, l2) {
      case (null, null) { true };
      case (null, _)    { false };
      case (_,    null) { false };
      case (?(h1,t1), ?(h2,t2)) { eq(h1,h2) and isEq<T>(t1, t2, eq) };
    }
  };

  /// Generate a list based on a length and a function that maps from
  /// a list index to a list element.
  public func tabulate<T>(n:Nat, f:Nat -> T) : List<T> {
    func rec(i:Nat, n: Nat, f : Nat -> T) : List<T> {
      if (i == n) { null } else { ?(f(i), rec(i+1, n, f)) }
    };
    rec(0, n, f)
  };

  /// Create a list with exactly one element.
  public func singleton<X>(x : X) : List<X> = ?(x, null);

  /// Create a list of the given length with the same value in each position.
  public func replicate<X>(n : Nat, x : X) : List<X> =
    tabulate<X>(n, func _ { x });

  /// Create a list of pairs from a pair of lists.
  ///
  /// If the given lists have different lengths, then the created list will have a
  /// length equal to the length of the smaller list.
  public func zip<X, Y>(xs : List<X>, ys : List<Y>) : List<(X, Y)> =
    zipWith<X, Y, (X, Y)>(xs, ys, func (x, y) { (x, y) });

  /// Create a list in which elements are calculated from the function `f` and
  /// include elements occuring at the same position in the given lists.
  ///
  /// If the given lists have different lengths, then the created list will have a
  /// length equal to the length of the smaller list.
  public func zipWith<X, Y, Z>(
    xs : List<X>,
    ys : List<Y>,
    f : (X, Y) -> Z
  ) : List<Z> {
    switch (pop<X>(xs)) {
      case (null, _) null;
      case (?x, xt) {
        switch (pop<Y>(ys)) {
          case (null, _) null;
          case (?y, yt) {
            push<Z>(f(x, y), zipWith<X, Y, Z>(xt, yt, f))
          }
        }
      }
    }
  };

  /// Split the given list at the given zero-based index.
  public func splitAt<X>(n : Nat, xs : List<X>) : (List<X>, List<X>) {
    if (n == 0) {
      (null, xs)
    } else {
      func rec(n : Nat, xs : List<X>) : (List<X>, List<X>) {
        switch (pop<X>(xs)) {
          case (null, _) {
            (null, null)
          };
          case (?h, t) {
            if (n == 1) {
              (singleton<X>(h), t)
            } else {
              let (l, r) = rec(n - 1, t);
              (push<X>(h, l), r)
            }
          }
        }
      };
      rec(n, xs)
    }
  };

  /// Split the given list into chunks of length `n`.
  /// The last chunk will be shorter if the length of the given list
  /// does not divide by `n` evenly.
  public func chunksOf<X>(n : Nat, xs : List<X>) : List<List<X>> {
    let (l, r) = splitAt<X>(n, xs);
    if (isNil<X>(l)) {
      null
    } else {
      push<List<X>>(l, chunksOf<X>(n, r))
    }
  };

  /// Convert an array into a list.
  public func fromArray<A>(xs : [A]) : List<A> {
    Array.foldr<A, List<A>>(func (x : A, ys : List<A>) : List<A> {
      push<A>(x, ys);
    }, nil<A>(), xs);
  };

  /// Convert a mutable array into a list.
  public func fromArrayMut<A>(xs : [var A]) : List<A> =
    fromArray<A>(Array.freeze<A>(xs));

  /// Create an array from a list.
  public func toArray<A>(xs : List<A>) : [A] {
    let length = len<A>(xs);
    var list = xs;
    Array.tabulate<A>(length, func (i) {
      let popped = pop<A>(list);
      list := popped.1;
      Option.unwrap<A>(popped.0);
    });
  };

  /// Create a mutable array from a list.
  public func toArrayMut<A>(xs : List<A>) : [var A] =
    Array.thaw<A>(toArray<A>(xs));

/*

To do:
--------
- iterator objects, for use in `for ... in ...` patterns
- operations for lists of pairs and pairs of lists: split, etc
- more regression tests for everything that is below

*/
}
