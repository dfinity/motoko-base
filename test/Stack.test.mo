import Stack "../src/Stack";
import Iter "../src/Iter";
import O "../src/Option";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let stack = Stack.Stack<Nat>();
stack.push(1);
stack.push(2);

let suite = Suite.suite(
  "Stack",
  [
    Suite.test(
      "init isEmpty",
      Stack.Stack<Nat>().isEmpty(),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isEmpty false",
      stack.isEmpty(),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "peek",
      stack.peek(),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "peek empty",
      Stack.Stack<Nat>().peek(),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "pop empty",
      Stack.Stack<Nat>().pop(),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "pop",
      stack.pop(),
      M.equals(T.optional(T.natTestable, ?2 : ?Nat))
    ),
    Suite.test(
      "pop 2",
      stack.pop(),
      M.equals(T.optional(T.natTestable, ?1 : ?Nat))
    ),
    Suite.test(
      "pop until empty",
      stack.pop(),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "pop until empty isEmpty",
      stack.isEmpty(),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "push",
      do {
        stack.push(3);
        stack.peek()
      },
      M.equals(T.optional(T.natTestable, ?3 : ?Nat))
    ),
    Suite.test(
      "push isEmpty",
      stack.isEmpty(),
      M.equals(T.bool(false))
    )
  ]
);

Suite.run(suite)
