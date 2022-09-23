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
  ),
  test(
    "initial capacity",
    B.Buffer<Nat>(10).capacity(),
    M.equals(T.nat(0))
  ),
]));

/* --------------------------------------- */

var buffer = B.Buffer<Nat>(10);
for (i in Iter.range(0, 3)) {
  buffer.add(i);
};

run(suite("add",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(4))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(10))
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
    "capacity",
    buffer.capacity(),
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
    "capacity",
    buffer.capacity(),
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
    M.not_(M.isSome()),
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer.capacity(),
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
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);
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
    M.not_(M.isSome()),
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(3))
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
    M.not_(M.isSome()),
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer.capacity(),
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
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
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
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [1, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);
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
    M.not_(M.isSome()),
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

run(suite("remove out of bounds",
[
  test(
    "return value",
    buffer.remove(10),
    M.not_(M.isSome()),
  ),
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(1);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.filter(func(_, x) = x % 2 == 0);

run(suite("filter",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(3))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 2, 4]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(1);
buffer.filter(func(_, x) = x % 2 == 0);

run(suite("filter on empty",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(0))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(12);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};
buffer.filter(func(i, x) = i + x == 2);

run(suite("filter size down",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(1))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [1]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(10);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

run(suite("get and getOpt",
[
  test(
    "get",
    buffer.get(2),
    M.equals(T.nat(2))
  ),
  // test(
  //   "get out of bounds",
  //   buffer.get(6), // FIXME how to nicely test for traps?
  //   M.equals(T.nat(0))
  // ),
  test(
    "getOpt success",
    buffer.getOpt(0),
    M.equals(T.optional(T.natTestable, ?0))
  ),
  test(
    "getOpt out of bounds",
    buffer.getOpt(10),
    M.not_(M.isSome()),
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(10);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.put(2, 20);

run(suite("put",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 20, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(10);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};


buffer.resize(6);

run(suite("resize down",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(10);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};


buffer.resize(20);

run(suite("resize up",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(20))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(10);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

var buffer2 = B.Buffer<Nat>(20);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.append(buffer2);

run(suite("append",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(12))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(24))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(10);
for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(0);

buffer.append(buffer2);

run(suite("append empty buffer",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(10))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(10);

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(0, 5)) {
  buffer2.add(i);
};

buffer.append(buffer2);

run(suite("append to empty buffer",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(8);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.insert(3, 30);

run(suite("insert",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 30, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(8);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.insert(6, 60);

run(suite("insert at back",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 60]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(8);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.insert(0, 10);

run(suite("insert at front",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [10, 0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(6);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.insert(3, 30);

run(suite("insert with resize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 30, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(6);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.insert(6, 60);

run(suite("insert at back",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 60]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(6);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer.insert(0, 10);

run(suite("insert at front",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [10, 0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(5);

buffer.insert(0, 0);

run(suite("insert into empty buffer",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(1))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(5))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);

buffer.insert(0, 0);

run(suite("insert into empty buffer with resize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(1))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(1))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(15);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(3, buffer2);

run(suite("insertBuffer",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(12))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(15))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 10, 11, 12, 13, 14, 15, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(15);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(0, buffer2);

run(suite("insertBuffer at start",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(12))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(15))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(15);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(6, buffer2);

run(suite("insertBuffer at end",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(12))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(15))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(8);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(3, buffer2);

run(suite("insertBuffer with resize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(12))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(24))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 10, 11, 12, 13, 14, 15, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(8);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(0, buffer2);

run(suite("insertBuffer at start with resize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(12))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(24))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(8);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(6, buffer2);

run(suite("insertBuffer at end with resize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(12))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(24))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(7);

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(0, buffer2);

run(suite("insertBuffer to empty buffer",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(7))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [10, 11, 12, 13, 14, 15]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

buffer2 := B.Buffer<Nat>(10);

for (i in Iter.range(10, 15)) {
  buffer2.add(i);
};

buffer.insertBuffer(0, buffer2);

run(suite("insertBuffer to empty buffer with resize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(6))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [10, 11, 12, 13, 14, 15]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

buffer.clear();

run(suite("clear",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
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
