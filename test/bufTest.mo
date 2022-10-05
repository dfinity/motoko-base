import Prim "mo:⛔";
import B "mo:base/Buffer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Order "mo:base/Order";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let {run;test;suite} = Suite;

let NatBufferTestable : T.Testable<B.Buffer<Nat>> = object {
  public func display(buffer : B.Buffer<Nat>) : Text {
    B.toText(buffer, Nat.toText);
  };
  public func equals(buffer1 : B.Buffer<Nat>, buffer2 : B.Buffer<Nat>) : Bool {
    B.equal(buffer1, buffer2, Nat.equal)
  };
};

class OrderTestable(initItem : Order.Order) : T.TestableItem<Order.Order> {
  public let item = initItem;
  public func display(order : Order.Order) : Text {
    switch (order) {
      case (#less) {
        "#less"
      };
      case (#greater) {
        "#greater"
      };
      case (#equal) {
        "#equal"
      }
    }
  };
  public let equals = Order.equal;
};

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
    M.equals(T.nat(10))
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
    M.equals(T.nat(2))
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
    M.equals(T.nat(1))
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
    M.equals(T.nat(10))
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
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

buffer2 := buffer.clone();

run(suite("clone",
[
  test(
    "size",
    buffer2.size(),
    M.equals(T.nat(buffer.size()))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(buffer2.capacity()))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, buffer2.toArray()))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

var size = 0;

for (element in buffer.vals()) {
  M.assertThat(element, M.equals(T.nat(size)));
  size += 1;
};

run(suite("vals",
[
  test(
    "size",
    size,
    M.equals(T.nat(7))
  )
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

/* --------------------------------------- */
run(suite("empty array round trips",
[
  test(
    "fromArray and toArray",
    B.fromArray<Nat>([]).toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
  test(
    "fromVarArray",
    B.fromVarArray<Nat>([var]).toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  )
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 6)) {
  buffer.add(i)
};

run(suite("iter round trips",
[
  test(
    "fromIter and vals",
    B.fromIter<Nat>(buffer.vals()).toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 6]))
  ),
  test(
    "empty",
    B.fromIter<Nat>(B.Buffer<Nat>(2).vals()).toArray(),
    M.equals(T.array<Nat>(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

B.trimToSize(buffer);

run(suite("trimToSize",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(7))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 6]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

B.trimToSize(buffer);

run(suite("trimToSize on empty",
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
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

buffer2 := B.map<Nat, Nat>(buffer, func x = x * 2);

run(suite("map",
[
  test(
    "size",
    buffer2.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer2.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer2.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 2, 4, 6, 8, 10, 12]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(0);

buffer2 := B.map<Nat, Nat>(buffer, func x = x * 2);

run(suite("map empty",
[
  test(
    "size",
    buffer2.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer2.capacity(),
    M.equals(T.nat(0))
  ),
  test(
    "elements",
    buffer2.toArray(),
    M.equals(T.array<Nat>(T.natTestable, []))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

var sum = 0;

B.iterate<Nat>(buffer, func x = sum += x);

run(suite("iterate",
[
  test(
    "sum",
    sum,
    M.equals(T.nat(21))
  ),
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
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 2, 3, 4, 5, 6]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

// FIXME Why does B.make need to be wrapped?
buffer2 := B.chain<Nat, Nat>(buffer, func x = B.make<Nat>(x));

run(suite("chain",
[
  test(
    "size",
    buffer2.size(),
    M.equals(T.nat(buffer.size()))
  ),
  test(
    "elements",
    buffer2.toArray(),
    M.equals(T.array<Nat>(T.natTestable, buffer.toArray()))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

buffer2 := B.mapFilter<Nat, Nat>(buffer, func x = if (x % 2 == 0) { ?x } else { null });

run(suite("mapFilter",
[
  test(
    "size",
    buffer2.size(),
    M.equals(T.nat(4))
  ),
  test(
    "capacity",
    buffer2.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer2.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 2, 4, 6]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

buffer2 := B.mapEntries<Nat, Nat>(buffer, func (i, x) = i * x);

run(suite("mapEntries",
[
  test(
    "size",
    buffer2.size(),
    M.equals(T.nat(7))
  ),
  test(
    "capacity",
    buffer2.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements",
    buffer2.toArray(),
    M.equals(T.array<Nat>(T.natTestable, [0, 1, 4, 9, 16, 25, 36]))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

var bufferResult = B.mapResult<Nat, Nat, Text>(buffer, func x = #ok x);

run(suite("mapResult success",
[
  test(
    "return value",
    #ok buffer,
    M.equals(T.result<B.Buffer<Nat>, Text>(NatBufferTestable, T.textTestable, bufferResult))
  )
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

bufferResult := 
  B.mapResult<Nat, Nat, Text>(
    buffer,
    func x = if (x == 4) { #err "error"} else { #ok x }
  );

run(suite("mapResult failure",
[
  test(
    "return value",
    #err "error",
    M.equals(T.result<B.Buffer<Nat>, Text>(NatBufferTestable, T.textTestable, bufferResult))
  )
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

run(suite("foldLeft",
[
  test(
    "return value",
    B.foldLeft<Text, Nat>(buffer, "", func(acc, x) = acc # Nat.toText(x)),
    M.equals(T.text("0123456"))
  ),
  test(
    "return value empty",
    B.foldLeft<Text, Nat>(B.Buffer<Nat>(4), "", func(acc, x) = acc # Nat.toText(x)),
    M.equals(T.text(""))
  )
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

run(suite("foldRight",
[
  test(
    "return value",
    B.foldRight<Nat, Text>(buffer, "", func(x, acc) = acc # Nat.toText(x)),
    M.equals(T.text("6543210"))
  ),
  test(
    "return value empty",
    B.foldRight<Nat, Text>(B.Buffer<Nat>(4), "", func(x, acc) = acc # Nat.toText(x)),
    M.equals(T.text(""))
  )
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 6)) {
  buffer.add(i);
};

// FIXME unnecessary reinitialization of buffer

run(suite("forAll",
[
  test(
    "true",
    B.forAll<Nat>(buffer, func x = x >= 0),
    M.equals(T.bool(true))
  ),
  test(
    "false",
    B.forAll<Nat>(buffer, func x = x % 2 == 0),
    M.equals(T.bool(false))
  ),
  test(
    "default",
    B.forAll<Nat>(B.Buffer<Nat>(2), func _ = false),
    M.equals(T.bool(true))
  )
]));

/* --------------------------------------- */
run(suite("forSome",
[
  test(
    "true",
    B.forSome<Nat>(buffer, func x = x % 2 == 0),
    M.equals(T.bool(true))
  ),
  test(
    "false",
    B.forSome<Nat>(buffer, func x = x < 0),
    M.equals(T.bool(false))
  ),
  test(
    "default",
    B.forSome<Nat>(B.Buffer<Nat>(2), func _ = false),
    M.equals(T.bool(false))
  )
]));

/* --------------------------------------- */
run(suite("forNone",
[
  test(
    "true",
    B.forNone<Nat>(buffer, func x = x < 0),
    M.equals(T.bool(true))
  ),
  test(
    "false",
    B.forNone<Nat>(buffer, func x = x % 2 != 0),
    M.equals(T.bool(false))
  ),
  test(
    "default",
    B.forNone<Nat>(B.Buffer<Nat>(2), func _ = true),
    M.equals(T.bool(true))
  )
]));

/* --------------------------------------- */

buffer := B.make<Nat>(1);

run(suite("make",
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
    M.equals(T.array(T.natTestable, [1]))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 5)) {
  buffer.add(i)
};

run(suite("contains",
[
  test(
    "true",
    B.contains<Nat>(buffer, 2, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "true",
    B.contains<Nat>(buffer, 9, Nat.equal),
    M.equals(T.bool(false))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);

run(suite("contains empty",
[
  test(
    "true",
    B.contains<Nat>(buffer, 2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "true",
    B.contains<Nat>(buffer, 9, Nat.equal),
    M.equals(T.bool(false))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);

buffer.add(2);
buffer.add(1);
buffer.add(10);
buffer.add(1);
buffer.add(0);
buffer.add(3);

run(suite("max",
[
  test(
    "return value",
    B.max<Nat>(buffer, Nat.compare),
    M.equals(T.nat(10))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);

buffer.add(2);
buffer.add(1);
buffer.add(10);
buffer.add(1);
buffer.add(0);
buffer.add(3);
buffer.add(0);

run(suite("min",
[
  test(
    "return value",
    B.min<Nat>(buffer, Nat.compare),
    M.equals(T.nat(0))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);
buffer.add(2);

run(suite("isEmpty",
[
  test(
    "true",
    B.isEmpty(B.Buffer<Nat>(2)),
    M.equals(T.bool(true))
  ),
  test(
    "false",
    B.isEmpty(buffer),
    M.equals(T.bool(false))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);

buffer.add(2);
buffer.add(1);
buffer.add(10);
buffer.add(1);
buffer.add(0);
buffer.add(3);
buffer.add(0);

B.removeDuplicates<Nat>(buffer, Nat.compare);

run(suite("removeDuplicates",
[
  test(
    "elements (stable ordering)",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [2, 1, 10, 0, 3]))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);

B.removeDuplicates<Nat>(buffer, Nat.compare);

run(suite("removeDuplicates empty",
[
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  )
]));

/* --------------------------------------- */

buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 4)) {
  buffer.add(2);
};

B.removeDuplicates<Nat>(buffer, Nat.compare);

run(suite("removeDuplicates repeat singleton",
[
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [2]))
  )
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

run(suite("hash",
[
  test(
    "empty buffer",
    Nat32.toNat(B.hash<Nat>(B.Buffer<Nat>(8), Hash.hash)),
    M.equals(T.nat(0))
  ),
  test(
    "non-empty buffer",
    Nat32.toNat(B.hash<Nat>(buffer, Hash.hash)),
    M.equals(T.nat(3365238326))
  )
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

run(suite("toText",
[
  test(
    "empty buffer",
    B.toText<Nat>(B.Buffer<Nat>(3), Nat.toText),
    M.equals(T.text("[]"))
  ),
  test(
    "singleton buffer",
    B.toText<Nat>(B.make<Nat>(3), Nat.toText),
    M.equals(T.text("[3]"))
  ),
  test(
    "non-empty buffer",
    B.toText<Nat>(buffer, Nat.toText),
    M.equals(T.text("[0, 1, 2, 3, 4, 5]"))
  )
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(3);

for (i in Iter.range(0, 2)) {
  buffer.add(i);
};

run(suite("equal",
[
  test(
    "empty buffers",
    B.equal<Nat>(B.Buffer<Nat>(3), B.Buffer<Nat>(2), Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "non-empty buffers",
    B.equal<Nat>(buffer, buffer.clone(), Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "non-empty and empty buffers",
    B.equal<Nat>(buffer, B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "non-empty buffers mismatching lengths",
    B.equal<Nat>(buffer, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
]));

/* --------------------------------------- */
buffer := B.Buffer<Nat>(3);

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer2 := B.Buffer<Nat>(3);

for (i in Iter.range(0, 2)) {
  buffer.add(i);
};

var buffer3 = B.Buffer<Nat>(3);

for (i in Iter.range(2, 5)) {
  buffer3.add(i);
};

run(suite("compare",
[
  test(
    "empty buffers",
    B.compare<Nat>(B.Buffer<Nat>(3), B.Buffer<Nat>(2), Nat.compare),
    M.equals(OrderTestable(#equal))
  ),
  test(
    "non-empty buffers equal",
    B.compare<Nat>(buffer, buffer.clone(), Nat.compare),
    M.equals(OrderTestable(#equal))
  ),
  test(
    "non-empty and empty buffers",
    B.compare<Nat>(buffer, B.Buffer<Nat>(3), Nat.compare),
    M.equals(OrderTestable(#greater))
  ),
  test(
    "non-empty buffers mismatching lengths",
    B.compare<Nat>(buffer, buffer2, Nat.compare),
    M.equals(OrderTestable(#greater))
  ),
  test(
    "non-empty buffers lexicographic difference",
    B.compare<Nat>(buffer, buffer3, Nat.compare),
    M.equals(OrderTestable(#less))
  ),
]));

/* --------------------------------------- */

var nestedBuffer = B.Buffer<B.Buffer<Nat>>(3);
for (i in Iter.range(0, 4)) {
  let innerBuffer = B.Buffer<Nat>(2);
  for (j in if (i % 2 == 0) { Iter.range(0, 4) } else { Iter.range(0, 3) }) {
    innerBuffer.add(j)
  };
  nestedBuffer.add(innerBuffer)
};
nestedBuffer.add(B.Buffer<Nat>(2));

buffer := B.flatten<Nat>(nestedBuffer);

run(suite("flatten",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(23))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(60))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2, 3, 4, 0, 1, 2, 3, 0, 1, 2, 3, 4, 0, 1, 2, 3, 0, 1, 2, 3, 4]))
  ),
]));

/* --------------------------------------- */

nestedBuffer := B.Buffer<B.Buffer<Nat>>(3);
for (i in Iter.range(0, 4)) {
  nestedBuffer.add(B.Buffer<Nat>(2));
};

buffer := B.flatten<Nat>(nestedBuffer);

run(suite("flatten all empty inner buffers",
[
  test(
    "size",
    buffer.size(),
    M.equals(T.nat(0))
  ),
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(10))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */

nestedBuffer := B.Buffer<B.Buffer<Nat>>(3);
buffer := B.flatten<Nat>(nestedBuffer);

run(suite("flatten empty outer buffer",
[
  test( //FIXME size unnecessary after testing size and toArray?
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
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 7)) {
  buffer.add(i);
};

buffer2.clear();

for (i in Iter.range(0, 6)) {
  buffer2.add(i);
};

buffer3.clear();

var buffer4 = B.make<Nat>(3);

B.reverse<Nat>(buffer);
B.reverse<Nat>(buffer2);
B.reverse<Nat>(buffer3);
B.reverse<Nat>(buffer4);

run(suite("reverse",
[
  test(
    "even elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [7, 6, 5, 4, 3, 2, 1, 0]))
  ),
  test(
    "odd elements",
    buffer2.toArray(),
    M.equals(T.array(T.natTestable, [6, 5, 4, 3, 2, 1, 0]))
  ),
  test(
    "empty",
    buffer3.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
  test(
    "singleton",
    buffer4.toArray(),
    M.equals(T.array(T.natTestable, [3]))
  ),
]));


/* --------------------------------------- */

buffer.clear(); // FIXME use clear after clear is tested?
for (i in Iter.range(0, 5)) {
  buffer.add(i)
};

var partition = B.partition<Nat>(buffer, func x = x % 2 == 0);
buffer2 := partition.0;
buffer3 := partition.1;

run(suite("partition",
[
  test(
    "capacity of true buffer",
    buffer2.capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "elements of true buffer",
    buffer2.toArray(),
    M.equals(T.array(T.natTestable, [0, 2, 4]))
  ),
  test(
    "capacity of false buffer",
    buffer3.capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "elements of false buffer",
    buffer3.toArray(),
    M.equals(T.array(T.natTestable, [1, 3, 5]))
  ),
]));

/* --------------------------------------- */

buffer.clear();
for (i in Iter.range(0, 3)) {
  buffer.add(i)
};

for (i in Iter.range(10, 13)) {
  buffer.add(i)
};

buffer2.clear();
for (i in Iter.range(2, 5)) {
  buffer2.add(i)
};
for (i in Iter.range(13, 15)) {
  buffer2.add(i)
};

buffer := B.merge<Nat>(buffer, buffer2, Nat.compare);
// FIXME fix or surpress warnings in test

run(suite("merge",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(30))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2, 2, 3, 3, 4, 5, 10, 11, 12, 13, 13, 14, 15]))
  ),
]));

/* --------------------------------------- */

buffer.clear();
for (i in Iter.range(0, 3)) {
  buffer.add(i)
};

buffer2.clear();

buffer := B.merge<Nat>(buffer, buffer2, Nat.compare);

run(suite("merge with empty",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2, 3]))
  ),
]));

/* --------------------------------------- */

buffer.clear();
buffer2.clear();

buffer := B.merge<Nat>(buffer, buffer2, Nat.compare);

run(suite("merge two empty",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(0))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

buffer.add(0);
buffer.add(2);
buffer.add(1);
buffer.add(1);
buffer.add(5);
buffer.add(4);

buffer.sort(Nat.compare);

run(suite("sort even",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 1, 2, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

buffer.add(0);
buffer.add(2);
buffer.add(1);
buffer.add(1);
buffer.add(5);

buffer.sort(Nat.compare);

run(suite("sort odd",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 1, 2, 5]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

buffer.sort(Nat.compare);

run(suite("sort empty",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer.clear();
buffer.add(2);

buffer.sort(Nat.compare);

run(suite("sort singleton",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [2] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

partition := B.split<Nat>(buffer, 2);
buffer2 := partition.0;
buffer3 := partition.1;

run(suite("split",
[
  test(
    "capacity prefix",
    buffer2.capacity(),
    M.equals(T.nat(4))
  ),
  test(
    "elements prefix",
    buffer2.toArray(),
    M.equals(T.array(T.natTestable, [0, 1]))
  ),
  test(
    "capacity suffix",
    buffer3.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements suffix",
    buffer3.toArray(),
    M.equals(T.array(T.natTestable, [2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

partition := B.split<Nat>(buffer, 0);
buffer2 := partition.0;
buffer3 := partition.1;

run(suite("split at index 0",
[
  test(
    "capacity prefix",
    buffer2.capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "elements prefix",
    buffer2.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
  test(
    "capacity suffix",
    buffer3.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements suffix",
    buffer3.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

partition := B.split<Nat>(buffer, 6);
buffer2 := partition.0;
buffer3 := partition.1;

run(suite("split at last index",
[
  test(
    "capacity prefix",
    buffer2.capacity(),
    M.equals(T.nat(12))
  ),
  test(
    "elements prefix",
    buffer2.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2, 3, 4, 5]))
  ),
  test(
    "capacity suffix",
    buffer3.capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "elements suffix",
    buffer3.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer.clear();
buffer2.clear();

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};
for (i in Iter.range(0, 3)) {
  buffer2.add(i);
};

var bufferPairs = B.zip<Nat, Nat>(buffer, buffer2);

run(suite("zip",
[
  test(
    "capacity",
    bufferPairs.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    bufferPairs.toArray(),
    M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), 
      [(0, 0), (1, 1), (2, 2), (3, 3)]))
  ),
]));

/* --------------------------------------- */
buffer.clear();
buffer2.clear();

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

bufferPairs := B.zip<Nat, Nat>(buffer, buffer2);

run(suite("zip empty",
[
  test(
    "capacity",
    bufferPairs.capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "elements",
    bufferPairs.toArray(),
    M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), 
      [] : [(Nat, Nat)]))
  ),
]));

/* --------------------------------------- */
buffer.clear();
buffer2.clear();

bufferPairs := B.zip<Nat, Nat>(buffer, buffer2);

run(suite("zip both empty",
[
  test(
    "capacity",
    bufferPairs.capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "elements",
    bufferPairs.toArray(),
    M.equals(T.array(T.tuple2Testable(T.natTestable, T.natTestable), 
      [] : [(Nat, Nat)]))
  ),
]));

/* --------------------------------------- */
buffer.clear();
buffer2.clear();

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};
for (i in Iter.range(0, 3)) {
  buffer2.add(i);
};

buffer3 := B.zipWith<Nat, Nat, Nat>(buffer, buffer2, Nat.add);

run(suite("zipWith",
[
  test(
    "capacity",
    buffer3.capacity(),
    M.equals(T.nat(8))
  ),
  test(
    "elements",
    buffer3.toArray(),
    M.equals(T.array(T.natTestable, [0, 2, 4, 6]))
  ),
]));

/* --------------------------------------- */
buffer.clear();
buffer2.clear();

for (i in Iter.range(0, 5)) {
  buffer.add(i);
};

buffer3 := B.zipWith<Nat, Nat, Nat>(buffer, buffer2, Nat.add);

run(suite("zipWithEmpty",
[
  test(
    "capacity",
    buffer3.capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "elements",
    buffer3.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 8)) {
  buffer.add(i);
};

var chunks = B.chunk<Nat>(buffer, 2);

run(suite("chunk",
[
  test(
    "num chunks",
    chunks.size(),
    M.equals(T.nat(5))
  ),
  test(
    "chunk 0 capacity",
    chunks.get(0).capacity(),
    M.equals(T.nat(4))
  ),
  test(
    "chunk 0 elements",
    chunks.get(0).toArray(),
    M.equals(T.array(T.natTestable, [0, 1]))
  ),
  test(
    "chunk 2 capacity",
    chunks.get(2).capacity(),
    M.equals(T.nat(4))
  ),
  test(
    "chunk 2 elements",
    chunks.get(2).toArray(),
    M.equals(T.array(T.natTestable, [4, 5]))
  ),
  test(
    "chunk 4 capacity",
    chunks.get(4).capacity(),
    M.equals(T.nat(4))
  ),
  test(
    "chunk 4 elements",
    chunks.get(4).toArray(),
    M.equals(T.array(T.natTestable, [8]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

chunks := B.chunk<Nat>(buffer, 3);

run(suite("chunk empty",
[
  test(
    "num chunks",
    chunks.size(),
    M.equals(T.nat(0))
  ),
]));

/* --------------------------------------- */
buffer.clear();

buffer.add(2);
buffer.add(2);
buffer.add(2);
buffer.add(1);
buffer.add(0);
buffer.add(0);
buffer.add(2);
buffer.add(1);
buffer.add(1);

var groups = B.groupBy<Nat>(buffer, Nat.equal);

run(suite("groupBy",
[
  test(
    "num groups",
    groups.size(),
    M.equals(T.nat(5))
  ),
  test(
    "group 0 capacity",
    groups.get(0).capacity(),
    M.equals(T.nat(9))
  ),
  test(
    "group 0 elements",
    groups.get(0).toArray(),
    M.equals(T.array(T.natTestable, [2, 2, 2]))
  ),
  test(
    "group 1 capacity",
    groups.get(1).capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "group 1 elements",
    groups.get(1).toArray(),
    M.equals(T.array(T.natTestable, [1]))
  ),
  test(
    "group 4 capacity",
    groups.get(4).capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "group 4 elements",
    groups.get(4).toArray(),
    M.equals(T.array(T.natTestable, [1, 1]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

groups := B.groupBy<Nat>(buffer, Nat.equal);

run(suite("groupBy clear",
[
  test(
    "num groups",
    groups.size(),
    M.equals(T.nat(0))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(0)
};

groups := B.groupBy<Nat>(buffer, Nat.equal);

run(suite("groupBy clear",
[
  test(
    "num groups",
    groups.size(),
    M.equals(T.nat(1))
  ),
  test(
    "group 0 elements",
    groups.get(0).toArray(),
    M.equals(T.array(T.natTestable, [0, 0, 0, 0, 0]))
  )
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer := B.prefix<Nat>(buffer, 3);

run(suite("prefix",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2]))
  )
]));

/* --------------------------------------- */
buffer.clear();

buffer := B.prefix<Nat>(buffer, 0);

run(suite("prefix of empty",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(2))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  )
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer := B.prefix<Nat>(buffer, 5);

run(suite("trivial prefix",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(10))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2, 3, 4]))
  )
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer2.clear();

for (i in Iter.range(0, 2)) {
  buffer2.add(i);
};

buffer3.clear();

buffer3.add(2);
buffer3.add(1);
buffer3.add(0);

run(suite("isPrefixOf",
[
  test(
    "normal prefix",
    B.isPrefixOf<Nat>(buffer2, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "identical buffers",
    B.isPrefixOf<Nat>(buffer, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "one empty buffer",
    B.isPrefixOf<Nat>(B.Buffer<Nat>(3), buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "not prefix",
    B.isPrefixOf<Nat>(buffer3, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not prefix from length",
    B.isPrefixOf<Nat>(buffer, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not prefix of empty",
    B.isPrefixOf<Nat>(buffer, B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "empty prefix of empty",
    B.isPrefixOf<Nat>(B.Buffer<Nat>(4), B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(true))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer2.clear();

for (i in Iter.range(0, 2)) {
  buffer2.add(i);
};

buffer3.clear();

buffer3.add(2);
buffer3.add(1);
buffer3.add(0);

run(suite("isStrictPrefixOf",
[
  test(
    "normal prefix",
    B.isStrictPrefixOf<Nat>(buffer2, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "identical buffers",
    B.isStrictPrefixOf<Nat>(buffer, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "one empty buffer",
    B.isStrictPrefixOf<Nat>(B.Buffer<Nat>(3), buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "not prefix",
    B.isStrictPrefixOf<Nat>(buffer3, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not prefix from length",
    B.isStrictPrefixOf<Nat>(buffer, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not prefix of empty",
    B.isStrictPrefixOf<Nat>(buffer, B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "empty prefix of empty",
    B.isStrictPrefixOf<Nat>(B.Buffer<Nat>(4), B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer := B.infix<Nat>(buffer, 1, 3);

run(suite("infix",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [1, 2, 3]))
  )
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

run(suite("infix edge cases",
[
  test(
    "prefix",
    B.prefix(buffer, 3),
    M.equals({ {item = B.infix(buffer, 0, 3)} and NatBufferTestable})
  ),
  test(
    "suffix",
    B.suffix(buffer, 3),
    M.equals({ {item = B.infix(buffer, 2, 3)} and NatBufferTestable})
  ),
  test(
    "empty",
    B.infix(buffer, 2, 0).toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
  test(
    "trivial",
    B.infix(buffer, 0, buffer.size()),
    M.equals({ {item = buffer} and NatBufferTestable})
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer2.clear();

for (i in Iter.range(0, 2)) {
  buffer2.add(i);
};

buffer3.clear();

for (i in Iter.range(1, 3)) {
  buffer3.add(i);
};

run(suite("isInfixOf",
[
  test(
    "normal infix",
    B.isInfixOf<Nat>(buffer3, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "prefix",
    B.isInfixOf<Nat>(buffer2, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "identical buffers",
    B.isInfixOf<Nat>(buffer, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "one empty buffer",
    B.isInfixOf<Nat>(B.Buffer<Nat>(3), buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "not infix",
    B.isInfixOf<Nat>(buffer3, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not infix from length",
    B.isInfixOf<Nat>(buffer, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not infix of empty",
    B.isInfixOf<Nat>(buffer, B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "empty infix of empty",
    B.isInfixOf<Nat>(B.Buffer<Nat>(4), B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(true))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer2.clear();

for (i in Iter.range(0, 2)) {
  buffer2.add(i);
};

buffer3.clear();

for (i in Iter.range(1, 3)) {
  buffer3.add(i);
};

buffer4 := B.Buffer<Nat>(4);

for (i in Iter.range(3, 4)) {
  buffer4.add(i);
};

run(suite("isStrictInfixOf",
[
  test(
    "normal strict infix",
    B.isStrictInfixOf<Nat>(buffer3, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "prefix",
    B.isStrictInfixOf<Nat>(buffer2, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "suffix",
    B.isStrictInfixOf<Nat>(buffer4, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "identical buffers",
    B.isStrictInfixOf<Nat>(buffer, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "one empty buffer",
    B.isStrictInfixOf<Nat>(B.Buffer<Nat>(3), buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "not infix",
    B.isStrictInfixOf<Nat>(buffer3, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not infix from length",
    B.isStrictInfixOf<Nat>(buffer, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not infix of empty",
    B.isStrictInfixOf<Nat>(buffer, B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "empty not strict infix of empty",
    B.isStrictInfixOf<Nat>(B.Buffer<Nat>(4), B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer := B.suffix<Nat>(buffer, 3);

run(suite("suffix",
[
  test(
    "capacity",
    buffer.capacity(),
    M.equals(T.nat(6))
  ),
  test(
    "elements",
    buffer.toArray(),
    M.equals(T.array(T.natTestable, [2, 3, 4]))
  )
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

run(suite("suffix edge cases",
[
  test(
    "empty",
    B.prefix(buffer, 0).toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
  test(
    "trivial",
    B.prefix(buffer, buffer.size()),
    M.equals({ {item = buffer} and NatBufferTestable})
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer2.clear();
for (i in Iter.range(3, 4)) {
  buffer2.add(i)
};

buffer3.clear();

buffer3.add(2);
buffer3.add(1);
buffer3.add(0);

run(suite("isSuffixOf",
[
  test(
    "normal suffix",
    B.isSuffixOf<Nat>(buffer2, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "identical buffers",
    B.isSuffixOf<Nat>(buffer, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "one empty buffer",
    B.isSuffixOf<Nat>(B.Buffer<Nat>(3), buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "not suffix",
    B.isSuffixOf<Nat>(buffer3, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not suffix from length",
    B.isSuffixOf<Nat>(buffer, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not suffix of empty",
    B.isSuffixOf<Nat>(buffer, B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "empty suffix of empty",
    B.isSuffixOf<Nat>(B.Buffer<Nat>(4), B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(true))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

buffer2.clear();
for (i in Iter.range(3, 4)) {
  buffer2.add(i)
};

buffer3.clear();

buffer3.add(2);
buffer3.add(1);
buffer3.add(0);

run(suite("isStrictSuffixOf",
[
  test(
    "normal suffix",
    B.isStrictSuffixOf<Nat>(buffer2, buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "identical buffers",
    B.isStrictSuffixOf<Nat>(buffer, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "one empty buffer",
    B.isStrictSuffixOf<Nat>(B.Buffer<Nat>(3), buffer, Nat.equal),
    M.equals(T.bool(true))
  ),
  test(
    "not suffix",
    B.isStrictSuffixOf<Nat>(buffer3, buffer, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not suffix from length",
    B.isStrictSuffixOf<Nat>(buffer, buffer2, Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "not suffix of empty",
    B.isStrictSuffixOf<Nat>(buffer, B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
  test(
    "empty suffix of empty",
    B.isStrictSuffixOf<Nat>(B.Buffer<Nat>(4), B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.bool(false))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

run(suite("takeWhile",
[
  test(
    "normal case",
    B.takeWhile<Nat>(buffer, func x = x < 3).toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2]))
  ),
  test(
    "empty",
    B.takeWhile<Nat>(B.Buffer<Nat>(3), func x = x < 3).toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 4)) {
  buffer.add(i)
};

run(suite("dropWhile",
[
  test(
    "normal case",
    B.dropWhile<Nat>(buffer, func x = x < 3).toArray(),
    M.equals(T.array(T.natTestable, [3, 4]))
  ),
  test(
    "empty",
    B.dropWhile<Nat>(B.Buffer<Nat>(3), func x = x < 3).toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
  test(
    "drop all",
    B.dropWhile<Nat>(buffer, func _ = true).toArray(),
    M.equals(T.array(T.natTestable, [] : [Nat]))
  ),
  test(
    "drop none",
    B.dropWhile<Nat>(buffer, func _ = false).toArray(),
    M.equals(T.array(T.natTestable, [0, 1, 2, 3, 4]))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(1, 6)) {
  buffer.add(i)
};

run(suite("binarySearch",
[
  test(
    "find in middle",
    B.binarySearch<Nat>(buffer, 2, Nat.compare),
    M.equals(T.optional(T.natTestable, ?1))
  ),
  test(
    "find first",
    B.binarySearch<Nat>(buffer, 1, Nat.compare),
    M.equals(T.optional(T.natTestable, ?0))
  ),
  test(
    "find last",
    B.binarySearch<Nat>(buffer, 6, Nat.compare),
    M.equals(T.optional(T.natTestable, ?5))
  ),
  test(
    "not found to the right",
    B.binarySearch<Nat>(buffer, 10, Nat.compare),
    M.equals(T.optional(T.natTestable, null : ?Nat)) // FIXME this is how you test for null
  ),
  test(
    "not found to the left",
    B.binarySearch<Nat>(buffer, 0, Nat.compare),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
]));

/* --------------------------------------- */
buffer.clear();

for (i in Iter.range(0, 6)) {
  buffer.add(i)
};

run(suite("indexOf",
[
  test(
    "find in middle",
    B.indexOf<Nat>(buffer, 2, Nat.equal),
    M.equals(T.optional(T.natTestable, ?2))
  ),
  test(
    "find first",
    B.indexOf<Nat>(buffer, 0, Nat.equal),
    M.equals(T.optional(T.natTestable, ?0))
  ),
  test(
    "find last",
    B.indexOf<Nat>(buffer, 6, Nat.equal),
    M.equals(T.optional(T.natTestable, ?6))
  ),
  test(
    "not found",
    B.indexOf<Nat>(buffer, 10, Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
  test(
    "empty",
    B.indexOf<Nat>(B.Buffer<Nat>(3), 100, Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
]));

/* --------------------------------------- */
buffer.clear();

buffer.add(2); // 0
buffer.add(2); // 1
buffer.add(1); // 2
buffer.add(10);// 3
buffer.add(1); // 4
buffer.add(0); // 5
buffer.add(10);// 6
buffer.add(3); // 7
buffer.add(0); // 8

run(suite("lastIndexOf",
[
  test(
    "find in middle",
    B.lastIndexOf<Nat>(buffer, 10, Nat.equal),
    M.equals(T.optional(T.natTestable, ?6))
  ),
  test(
    "find only",
    B.lastIndexOf<Nat>(buffer, 3, Nat.equal),
    M.equals(T.optional(T.natTestable, ?7))
  ),
  test(
    "find last",
    B.lastIndexOf<Nat>(buffer, 0, Nat.equal),
    M.equals(T.optional(T.natTestable, ?8))
  ),
  test(
    "not found",
    B.lastIndexOf<Nat>(buffer, 100, Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
  test(
    "empty",
    B.lastIndexOf<Nat>(B.Buffer<Nat>(3), 100, Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
]));

/* --------------------------------------- */
buffer.clear();

buffer.add(2); // 0
buffer.add(2); // 1
buffer.add(1); // 2
buffer.add(10);// 3
buffer.add(1); // 4
buffer.add(10);// 5
buffer.add(3); // 6
buffer.add(0); // 7

run(suite("indexOfBuffer",
[
  test(
    "find in middle",
    B.indexOfBuffer<Nat>(buffer, B.fromArray<Nat>([1, 10, 1]), Nat.equal),
    M.equals(T.optional(T.natTestable, ?2))
  ),
  test(
    "find first",
    B.indexOfBuffer<Nat>(buffer, B.fromArray<Nat>([2, 2, 1, 10]), Nat.equal),
    M.equals(T.optional(T.natTestable, ?0))
  ),
  test(
    "find last",
    B.indexOfBuffer<Nat>(buffer, B.fromArray<Nat>([0]), Nat.equal),
    M.equals(T.optional(T.natTestable, ?7))
  ),
  test(
    "not found",
    B.indexOfBuffer<Nat>(buffer, B.fromArray<Nat>([99, 100, 1]), Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
  test(
    "search for empty buffer",
    B.indexOfBuffer<Nat>(buffer, B.fromArray<Nat>([]), Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
  test(
    "search through empty buffer",
    B.indexOfBuffer<Nat>(B.Buffer<Nat>(2), B.fromArray<Nat>([1, 2, 3]), Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
  test(
    "search for empty in empty",
    B.indexOfBuffer<Nat>(B.Buffer<Nat>(2), B.Buffer<Nat>(3), Nat.equal),
    M.equals(T.optional(T.natTestable, null : ?Nat))
  ),
]));