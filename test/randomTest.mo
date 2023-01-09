import Prim "mo:prim";
import Random "mo:base/Random";
import Nat8 "mo:base/Nat8";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let nat8Testable : T.Testable<Nat8> = object {
  public func display(n: Nat8) : Text {
    Nat8.toText(n)
  };
  public func equals(first : Nat8, second : Nat8) : Bool {
    first == second
  }
};

let { run; test; suite } = Suite;


run(
  suite(
    "random-coin",
    [
      test(
        "random empty coin",
        Random.Finite("").coin(),
        M.equals(T.optional(T.boolTestable, null : ?Bool))
      ),
      test(
        "random non-empty coin - true",
        Random.Finite("\FF").coin(),
        M.equals(T.optional(T.boolTestable, ?true : ?Bool))
      ),
      test(
        "random non-empty coin - false",
        Random.Finite("\7F").coin(),
        M.equals(T.optional(T.boolTestable, ?false : ?Bool))
      ),
    ]
  )
);

run(
  suite(
    "random-range",
    [
      test(
        "random empty range 8",
        Random.Finite("").range(8),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "random 1 byte range 8",
        Random.Finite("\FF").range(8),
        M.equals(T.optional(T.natTestable, ?255 : ?Nat))
      ),
      test(
        "random 1 byte range 8",
        Random.Finite("\00").range(8),
        M.equals(T.optional(T.natTestable, ?0 : ?Nat))
      ),
      test(
        "random 1 byte range 16",
        Random.Finite("\00").range(16),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
       test(
        "random 2 byte range 16",
        Random.Finite("\FF\FF").range(16),
        M.equals(T.optional(T.natTestable, ?65535 : ?Nat))
      ),
    ]
  )
);

run(
  suite(
    "random-binomial",
    [
      test(
        "random empty binomial 8",
        Random.Finite("").binomial(8),
        M.equals(T.optional(nat8Testable, null : ?Nat8))
      ),
      test(
        "random 1 byte binomial 8 8",
        Random.Finite("\FF").binomial(8),
        M.equals(T.optional(nat8Testable, ?8 : ?Nat8))
      ),
      test(
        "random 1 byte binomial 8 0",
        Random.Finite("\00").binomial(8),
        M.equals(T.optional(nat8Testable, ?0 : ?Nat8))
      ),
      test(
        "random 1 byte binomial 8 0",
        Random.Finite("\AA").binomial(8),
        M.equals(T.optional(nat8Testable, ?4 : ?Nat8))
      ),
      test(
        "random 1 byte binomial 16",
        Random.Finite("\00").binomial(16),
        M.equals(T.optional(nat8Testable, null : ?Nat8))
      ),
      test(
        "random 2 byte binomial 16/16",
        Random.Finite("\FF\FF").binomial(16),
        M.equals(T.optional(nat8Testable, ?16 : ?Nat8))
      ),
      test(
        "random 2 byte binomial 0/16",
        Random.Finite("\00\00").binomial(16),
        M.equals(T.optional(nat8Testable, ?0 : ?Nat8))
      ),
      test(
        "random 2 byte binomial 8/16",
        Random.Finite("\AA\AA").binomial(16),
        M.equals(T.optional(nat8Testable, ?8 : ?Nat8))
      ),
    ]
  )
)
