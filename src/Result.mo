/// Error handling with the Result type.

import P "Prelude";
import Array "Array";

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
///   case #ok(id) Debug.print("Created new user with id: " # id);
///   case #err(msg) Debug.print("Failed to create user with the error: " # msg);
/// }
/// ```
public type Result<Ok, Err> = {
  #ok : Ok;
  #err : Err;
};

/// Allows sequencing of `Result` values and functions that return
/// `Result` values themselves.
/// ```motoko
/// func largerThan10(x : Nat) : Result<Nat, Text> =
///   if (x > 10) { #ok(x) } else { #err("Not larger than 10.") };
///
/// func smallerThan20(x : Nat) : Result<Nat, Text> =
///   if (x < 20) { #ok(x) } else { #err("Not smaller than 20.") };
///
/// func between10And20(x : Nat) : Result<Nat, Text> =
///   chain(largerThan10(x), smallerThan20(x));
///
/// between10And20(15) = #ok(15);
/// between10And20(9) = #err("Not larger than 10.");
/// between10And20(21) = #err("Not smaller than 20.");
/// ```
public func chain<R1, R2, Error>(
  x : Result<R1, Error>,
  y : R1 -> Result<R2, Error>
) : Result<R2, Error> {
  switch(x) {
    case (#err e) (#err e);
    case (#ok r) (y r);
  }
};


/// Maps the `Ok` type/value, leaving any `Error` type/value unchanged.
public func mapOk<Ok1, Ok2, Error>(
  x : Result<Ok1, Error>,
  f : Ok1 -> Ok2
) : Result<Ok2, Error> {
  switch(x) {
    case (#err e) (#err e);
    case (#ok r) (#ok (f r));
  }
};

/// Maps the `Err` type/value, leaving any `Ok` type/value unchanged.
public func mapErr<Ok, Error1, Error2>(
  x : Result<Ok, Error1>,
  f : Error1 -> Error2
) : Result<Ok, Error2> {
  switch(x) {
    case (#err e) (#err (f e));
    case (#ok r) (#ok r);
  }
};

/// Create a `Result` from an `Option`, including an error value to handle the
/// `null` case.
/// ```motoko
/// fromOption(?x, e) = #ok(x);
/// fromOption(null, e) = #err(e);
/// ```
public func fromOption<R, E>(x : ?R, err : E) : Result<R, E> {
  switch(x) {
    case (?x) (#ok x);
    case (null) (#err err);
  }
};

/// Maps the `Ok` type/value from the optional value, or else use the given error
/// value.
// (Deprecate?)
public func fromSomeMap<R1, R2, E>(x : ?R1, f : R1->R2, err : E) : Result<R2, E> {
  switch(x) {
    case (?x) (#ok (f x));
    case (null) (#err err);
  }
};

/// Asserts that the option is of `Some(_)` form.
public func fromSome<Ok>(o : ?Ok) : Result<Ok, None> {
  switch(o) {
    case (?o) (#ok o);
    case (_) P.unreachable();
  }
};

/// A result that consists of an array of `Ok` results from an array of results,
/// or the first error in the result array, if any.
public func toArrayOk<R,E>(x : [Result<R,E>]) : Result<[R],E> {
  // return early with the first `Err` result, if any
  for (i in x.keys()) {
    switch (x[i]) {
      case (#err e) { return #err(e) };
      case (#ok _) { };
    }
  };
  // all of the results are `Ok`; tabulate them.
  #ok(Array.tabulate<R>(x.size(), func (i : Nat) : R { unwrapOk(x[i]) }))
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

/// Extract and return the value `v` of an `#err v` result.
/// Traps if its argument is an `#ok` result.
/// Recommended for testing only, not for production code.
public func unwrapErr<Ok, Error>(r : Result<Ok, Error>) : Error {
  switch(r) {
    case (#err e) e;
    case (#ok r) P.unreachable();
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
public func assertErr(r : Result<Any, Any>) {
  switch(r) {
    case (#err _) ();
    case (#ok _) assert false;
  }
};

};
