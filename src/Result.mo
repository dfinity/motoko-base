/// Error-annotated values

import P "Prelude";
import Array "Array";

module {
/// The result of a computation that may contain errors, exceptions, etc.
///
/// Motoko does not have exceptions, so we use a datatype to encode these outcomes.
///
/// Rust does something analogous, for the same reason.  We use the Rust nomenclature for the datatype and its constructors.
public type Result<Ok,Err> = {
  #ok:Ok;
  #err:Err;
};



/// assert that we can unwrap the result; should only be used in tests, not in canister implementations. This will trap.
public func unwrapOk<Ok,Error>(r:Result<Ok,Error>):Ok {
  switch(r) {
    case (#err e) P.unreachable();
    case (#ok r) r;
  }
};

/// assert that the result is an error, and return the error
public func unwrapErr<Ok,Error>(r:Result<Ok,Error>):Error {
  switch(r) {
    case (#err e) e;
    case (#ok r) P.unreachable();
  }
};

public func assertOk(r:Result<Any,Any>) {
  switch(r) {
    case (#err _) assert false;
    case (#ok _) ();
  }
};

public func assertErr(r:Result<Any,Any>) {
  switch(r) {
    case (#err _) ();
    case (#ok _) assert false;
  }
};

/// chain operation in result monad.
public func chain<R1,R2,Error>(
  x:Result<R1,Error>,
  y:R1 -> Result<R2,Error>) : Result<R2,Error> {
  switch x {
  case (#err e) (#err e);
  case (#ok r) (y r);  
  }
};


/// Maps the `Ok` type/value, leaving any `Error` type/value unchanged.
public func mapOk<Ok1,Ok2,Error>(
  x:Result<Ok1,Error>,
  y:Ok1 -> Ok2) : Result<Ok2,Error> {
  switch x {
  case (#err e) (#err e);
  case (#ok r) (#ok (y r));
  }
};

/// create a result from an option, including an error value to handle the `null` case.
public func fromOption<R,E>(x:?R, err:E):Result<R,E> {
  switch x {
    case (? x) {#ok x};
    case null {#err err};
  }
};

/// Maps the `Ok` type/value from the optional value, or else use the given error value.
/// (Deprecate?)
public func fromSomeMap<R1,R2,E>(x:?R1, f:R1->R2, err:E):Result<R2,E> {
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
  #ok(Array.tabulate<R>(x.len(), func (i:Nat):R {unwrapOk(x[i]) }))
};
}
