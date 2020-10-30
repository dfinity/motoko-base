/// Error handling with the Result type.

import Prim "mo:prim";
import P "Prelude";
import Array "Array";
import List "List";
import Order "Order";

module {

/// `Result<Ok, Err>` is the type used for returning and propagating errors. It
/// is a type with the variants, `#ok(Ok)`, representing success and containing
/// a value, and `#err(Err)`, representing error and containing an error value.
///
/// The simplest way of working with `Result`s is to pattern match on them:
///
/// For example, given a function `createUser(user : User) : Result<Id, String>`
/// where `String` is an error message we could use it like so:
/// ```motoko
/// switch(createUser(myUser)) {
///   case #ok(id) Debug.print("Created new user with id: " # id)
///   case #err(msg) Debug.print("Failed to create user with the error: " # msg)
/// }
/// ```
public type Result<Ok, Err> = {
  #ok : Ok;
  #err : Err;
};

// Compares two Result's for equality.
public func equal<Ok, Err>(
  eqOk : (Ok, Ok) -> Bool,
  eqErr : (Err, Err) -> Bool,
  r1 : Result<Ok, Err>,
  r2 : Result<Ok, Err>
) : Bool {
  switch (r1, r2) {
    case (#ok ok1, #ok ok2) eqOk(ok1, ok2);
    case (#err err1, #err err2) eqErr(err1, err2);
    case _ false;
  };
};

// Compares two Results. `#ok` is larger than `#err`. This ordering is
// arbitrary, but it lets you for example use Results as keys in ordered maps.
public func compare<Ok, Err>(
  compareOk : (Ok, Ok) -> Order.Order,
  compareErr : (Err, Err) -> Order.Order,
  r1 : Result<Ok, Err>,
  r2 : Result<Ok, Err>
) : Order.Order {
  switch (r1, r2) {
    case (#ok ok1, #ok ok2) compareOk(ok1, ok2);
    case (#err err1, #err err2) compareErr(err1, err2);
    case (#ok _, _) #greater;
    case (#err _, _) #less;
  };
};

/// Allows sequencing of `Result` values and functions that return
/// `Result`'s themselves.
/// ```
/// func largerThan10(x : Nat) : Result<Nat, Text> =
///   if (x > 10) { #ok(x) } else { #err("Not larger than 10.") };
///
/// func smallerThan20(x : Nat) : Result<Nat, Text> =
///   if (x < 20) { #ok(x) } else { #err("Not smaller than 20.") };
///
/// func between10And20(x : Nat) : Result<Nat, Text> =
///   chain(largerThan10(x), smallerThan20)
///
/// between10And20(15) = #ok(15);
/// between10And20(9) = #err("Not larger than 10.");
/// between10And20(21) = #err("Not smaller than 20.");
/// ```
public func chain<R1, R2, Error>(
  x : Result<R1, Error>,
  y : R1 -> Result<R2, Error>
) : Result<R2, Error> {
  switch x {
    case (#err e) (#err e);
    case (#ok r) (y r);
  }
};

/// Flattens a nested Result.
///
/// ```motoko
/// assert(flatten<Nat, Text>(#ok(#ok(10))) == #ok(10))
/// assert(flatten<Nat, Text>(#err("Wrong") == #err("Wrong"))
/// assert(flatten<Nat, Text>(#ok(#err("Wrong")) == #err("Wrong"))
/// ```
public func flatten<Ok, Error>(
  result : Result<Result<Ok, Error>, Error>
) : Result<Ok, Error> {
  switch result {
    case (#ok ok) ok;
    case (#err err) #err(err);
  }
};


/// Maps the `Ok` type/value, leaving any `Error` type/value unchanged.
public func mapOk<Ok1, Ok2, Error>(
  x : Result<Ok1, Error>,
  f : Ok1 -> Ok2
) : Result<Ok2, Error> {
  switch x {
    case (#err e) (#err e);
    case (#ok r) (#ok (f r));
  }
};

/// Maps the `Err` type/value, leaving any `Ok` type/value unchanged.
public func mapErr<Ok, Error1, Error2>(
  x : Result<Ok, Error1>,
  f : Error1 -> Error2
) : Result<Ok, Error2> {
  switch x {
    case (#err e) (#err (f e));
    case (#ok r) (#ok r);
  }
};

/// Create a result from an option, including an error value to handle the `null` case.
/// ```
/// fromOption(?(x), e) = #ok(x)
/// fromOption(null, e) = #err(e)
/// ```
public func fromOption<R, E>(x : ?R, err : E) : Result<R, E> {
  switch x {
    case (? x) {#ok x};
    case null {#err err};
  }
};

/// Maps the `Ok` type/value from the optional value, or else use the given error value.
/// (Deprecate?)
public func fromSomeMap<R1, R2, E>(x:?R1, f:R1->R2, err:E):Result<R2,E> {
  switch x {
    case (? x) {#ok (f x)};
    case null {#err err};
  }
};

/// asserts that the option is Some(_) form.
public func fromSome<Ok>(o:?Ok):Result<Ok,None> {
  switch(o) {
    case (?o) (#ok o);
    case _ P.unreachable();
  }
};

/// a result that consists of an array of Ok results from an array of results, or the first error in the result array, if any.
public func toArrayOk<R,E>(x:[Result<R,E>]) : Result<[R],E> {
  // return early with the first Err result, if any
  for (i in x.keys()) {
    switch (x[i]) {
      case (#err e) { return #err(e) };
      case (#ok _) { };
    }
  };
  // all of the results are Ok; tabulate them.
  #ok(Array.tabulate<R>(x.size(), func (i:Nat):R {unwrapOk(x[i]) }))
};

/// Applies a function to a successful value, but discards the result. Use
/// `iterate` if you're only interested in the side effect `f` produces.
///
/// ```
/// var counter : Nat = 0;
/// iterate<Nat, Text>(#ok(5), func (x : Nat) { counter += x });
/// assert(counter == 5);
/// iterate<Nat, Text>(#err("Wrong"), func (x : Nat) { counter += x });
/// assert(counter == 5);
/// ```
public func iterate<Ok, Err>(res : Result<Ok, Err>, f : Ok -> ()) {
  switch res {
    case (#ok ok) f(ok);
    case _ ();
  }
};

/// Maps a Result-returning function over an Array and returns either
/// the first error or an array of successful values.
///
/// ```motoko
/// func makeNatural(x : Int) : Result<Nat, Text> =
///   if (x >= 0) {
///     #ok(Int.abs(x))
///   } else {
///     #err(Int.toText(x) # " is not a natural number.")
///   };
///
/// traverseArray([0, 1, 2], makeNatural) = #ok([0, 1, 2]);
/// traverseArray([-1, 0, 1], makeNatural) = #err("-1 is not a natural number.");
/// ```
public func traverseArray<A, R, E>(xs : [A], f : A -> Result<R, E>) : Result<[R], E> {
  let len : Nat = xs.size();
  var target : [var R] = [var];
  var i : Nat = 0;
  var init = false;
  while (i < len) {
    switch (f(xs[i])) {
      case (#err err) return #err(err);
      case (#ok ok) {
        if (not init) {
          init := true;
          target := Array.init(len, ok);
        } else {
          target[i] := ok
        }
      };
    };
    i += 1;
  };
  #ok(Array.freeze(target))
};

/// Like [`traverseArray`](#value.traverseArray) but for Lists.
public func traverseList<A, R, E>(xs : List.List<A>, f : A -> Result<R, E>) : Result<List.List<R>, E> {
  func go(xs : List.List<A>, acc : List.List<R>) : Result<List.List<R>, E> {
    switch xs {
      case null #ok(acc);
      case (?(head, tail)) {
        switch (f(head)) {
          case (#err err) #err(err);
          case (#ok ok) go(tail, ?(ok, acc));
        };
      };
    }
  };
  mapOk(go(xs, null), func (xs : List.List<R>) : List.List<R> = List.reverse(xs))
};

/// Extract and return the value `v` of an `#ok v` result.
/// Traps if its argument is an `#err` result.
/// Recommended for testing only, not for production code.
public func unwrapOk<Ok,Error>(r:Result<Ok,Error>):Ok {
  switch(r) {
    case (#err e) P.unreachable();
    case (#ok r) r;
  }
};

// Whether this Result is an `#ok`
public func isOk(r : Result<Any, Any>) : Bool {
  switch r {
    case (#ok _) true;
    case (#err _) false;
  }
};

/// Extract and return the value `v` of an `#err v` result.
/// Traps if its argument is an `#ok` result.
/// Recommended for testing only, not for production code.
public func unwrapErr<Ok,Error>(r:Result<Ok,Error>):Error {
  switch(r) {
    case (#err e) e;
    case (#ok r) P.unreachable();
  }
};

// Whether this Result is an `#err`
public func isErr(r : Result<Any, Any>) : Bool {
  switch r {
    case (#ok _) false;
    case (#err _) true;
  }
};

/// Asserts that its argument is an `#ok` result, traps otherwise.
public func assertOk(r:Result<Any,Any>) {
  switch(r) {
    case (#err _) assert false;
    case (#ok _) ();
  }
};

/// Asserts that its argument is an `#err` result, traps otherwise.
public func assertErr(r:Result<Any,Any>) {
  switch(r) {
    case (#err _) ();
    case (#ok _) assert false;
  }
};


}
