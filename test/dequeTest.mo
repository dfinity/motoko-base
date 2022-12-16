import Prim "mo:prim";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import O "mo:base/Option";
import D "mo:base/Debug";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

func iterate<T>(deque: Deque.Deque<T>) : Iter.Iter<T> {
  var current = deque;
  object {
    public func next() : ?T {
      switch (Deque.popFront(current)) {
        case null null;
        case (?result) {
          current := result.1;
          ?result.0
        }
      }
    }
  }
};

func toArray<T>(deque: Deque.Deque<T>): [T] {
  Iter.toArray(iterate(deque))
};

func toText(deque : Deque.Deque<Nat>) : Text {
  var text = "[";
  var isFirst = true;
  for (element in iterate(deque)) {
    if (not isFirst) {
      isFirst := false;
      text #= ", ";
    };
    text #= debug_show(element);
  };
  text #= "]";
  text
};

let natDequeTestable : T.Testable<Deque.Deque<Nat>> = object {
  public func display(deque : Deque.Deque<Nat>) : Text {
    toText(deque)
  };
  public func equals(first : Deque.Deque<Nat>, second : Deque.Deque<Nat>) : Bool {
    Array.equal(toArray(first), toArray(second), Nat.equal)
  }
};

func matchFrontRemoval(element: Nat, remainder: Deque.Deque<Nat>): M.Matcher<?(Nat, Deque.Deque<Nat>)> {
  let testable = T.tuple2Testable(T.natTestable, natDequeTestable);
  M.equals(T.optional(testable, ?(element, remainder)))
};

func matchEmptyFrontRemoval(): M.Matcher<?(Nat, Deque.Deque<Nat>)> {
  let testable = T.tuple2Testable(T.natTestable, natDequeTestable);
  M.equals(T.optional(testable, null: ?(Nat, Deque.Deque<Nat>)))
};

func matchBackRemoval(remainder: Deque.Deque<Nat>, element: Nat): M.Matcher<?(Deque.Deque<Nat>, Nat)> {
  let testable = T.tuple2Testable(natDequeTestable, T.natTestable);
  M.equals(T.optional(testable, ?(remainder, element)))
};

func matchEmptyBackRemoval(): M.Matcher<?(Deque.Deque<Nat>, Nat)> {
  let testable = T.tuple2Testable(natDequeTestable, T.natTestable);
  M.equals(T.optional(testable, null: ?(Deque.Deque<Nat>, Nat)))
};

/* --------------------------------------- */
run(
  suite(
    "construct",
    [
      test(
        "empty",
        Deque.isEmpty(Deque.empty<Nat>()),
        M.equals(T.bool(true))
      ),
      test(
        "dump",
        toArray(Deque.empty<Nat>()),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "peek front",
        Deque.peekFront(Deque.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "peek back",
        Deque.peekBack(Deque.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "pop front",
        Deque.popFront(Deque.empty<Nat>()),
        matchEmptyFrontRemoval()
      ),
      test(
        "pop back",
        Deque.popBack(Deque.empty<Nat>()),
        matchEmptyBackRemoval()
      ),
    ]
  )
);

/* --------------------------------------- */

let deque = Deque.pushFront(Deque.empty<Nat>(), 1);

run(
  suite(
    "single item",
    [
      test(
        "not empty",
        Deque.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "dump",
        toArray(deque),
        M.equals(T.array<Nat>(T.natTestable, [1]))
      ),
      test(
        "peek front",
        Deque.peekFront(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "peek back",
        Deque.peekBack(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "pop front",
        Deque.popFront(deque),
        matchFrontRemoval(1, Deque.empty())
      ),
      test(
        "pop back",
        Deque.popBack(deque),
        matchBackRemoval(Deque.empty(), 1)
      )
    ]
  )
);


// test for Queue
do {
  var l = Deque.empty<Nat>();
  for (i in Iter.range(0, 100)) {
    l := Deque.pushBack(l, i)
  };
  for (i in Iter.range(0, 100)) {
    let x = Deque.peekFront(l);
    switch (Deque.popFront(l)) {
      case (?(y, l2)) {
        l := l2;
        switch x {
          case null assert false;
          case (?x) assert (x == y)
        }
      };
      case null { assert false }
    };
    assert (O.unwrap(x) == i)
  };
  O.assertNull(Deque.peekFront<Nat>(l))
};

// test for Deque
do {
  var l = Deque.empty<Int>();
  for (i in Iter.range(1, 100)) {
    l := Deque.pushFront(l, -i);
    l := Deque.pushBack(l, i)
  };
  label F for (i in Iter.revRange(100, -100)) {
    if (i == 0) continue F;
    let x = Deque.peekBack(l);
    switch (Deque.popBack(l)) {
      case (?(l2, y)) {
        l := l2;
        switch x {
          case null assert false;
          case (?x) assert (x == y)
        }
      };
      case null { assert false }
    };
    assert (O.unwrap(x) == i)
  }
}
