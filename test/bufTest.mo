import Prim "mo:⛔";
import B "mo:base/Buffer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let {run;test;suite} = Suite;

/* --------------------------------------- */
run(suite("construct",
[
  test(
    "initial size",
    B.Buffer<Nat>(10).size(),
    M.equals(T.nat(0))
  )
]));

var buffer = B.Buffer<Nat>(10);
for (i in Iter.range(0, 3)) {
  buffer.add(i);
};

/* --------------------------------------- */
run(suite("add",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(4))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(2);
for (i in Iter.range(0, 3)) {
  buffer.add(i);
};

run(suite("add with resize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(4))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);
for (i in Iter.range(0, 3)) {
  buffer.add(i);
};

run(suite("add with resize, initial capacity 0",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(4))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(2);

run(suite("removeLast on empty buffer",
[
  test(
    "return value",
    buffer.removeLast(),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(2);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

run(suite("removeLast",
[
  test(
    "return value",
    buffer.removeLast(),
    M.equals(T.optional<Nat>(T.natTestable, ?5))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(5))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(2);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

for (i in Iter.range(0, 5)) {
  ignore buffer.removeLast();
};

run(suite("removeLast until empty",
[
  test(
    "return value",
    buffer.removeLast(),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);

run(suite("remove on empty buffer",
[
  test(
    "return value",
    buffer.remove(0),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);

buffer := B.Buffer<Nat>(2);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

run(suite("remove",
[
  test(
    "return value",
    buffer.remove(2),
    M.equals(T.optional<Nat>(T.natTestable, ?2))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(5))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 3, 4, 5]))
  ),
  test(
    "return value",
    buffer.remove(0),
    M.equals(T.optional<Nat>(T.natTestable, ?0))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(4))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [1, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);

buffer := B.Buffer<Nat>(2);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

for (i in Iter.range(0, 5)) {
  ignore buffer.remove(5 - i);
};

run(suite("remove until empty",
[
  test(
    "return value",
    buffer.remove(0),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);

buffer := B.Buffer<Nat>(2);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

run(suite("remove out of bounds",
[
  test(
    "return value",
    buffer.remove(10),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
]));


/* --------------------------------------- */
run(suite("array round trips",
[
  test(
    "fromArray and toArray",
    B.fromArray<Nat>([0, 1, 2, 3]).toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3]))
  ),
  test(
    "fromVarArray",
    B.fromVarArray<Nat>([var 0, 1, 2, 3]).toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3]))
  )
]));
