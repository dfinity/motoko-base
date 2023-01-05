import Prim "mo:prim";
import Deque "mo:base/Deque";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

func iterateForward<T>(deque : Deque.Deque<T>) : Iter.Iter<T> {
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

func iterateBackward<T>(deque : Deque.Deque<T>) : Iter.Iter<T> {
  var current = deque;
  object {
    public func next() : ?T {
      switch (Deque.popBack(current)) {
        case null null;
        case (?result) {
          current := result.0;
          ?result.1
        }
      }
    }
  }
};

func toText(deque : Deque.Deque<Nat>) : Text {
  var text = "[";
  var isFirst = true;
  for (element in iterateForward(deque)) {
    if (not isFirst) {
      text #= ", "
    } else {
      isFirst := false
    };
    text #= debug_show (element)
  };
  text #= "]";
  text
};

let natDequeTestable : T.Testable<Deque.Deque<Nat>> = object {
  public func display(deque : Deque.Deque<Nat>) : Text {
    toText(deque)
  };
  public func equals(first : Deque.Deque<Nat>, second : Deque.Deque<Nat>) : Bool {
    Array.equal(Iter.toArray(iterateForward(first)), Iter.toArray(iterateForward(second)), Nat.equal)
  }
};

func matchFrontRemoval(element : Nat, remainder : Deque.Deque<Nat>) : M.Matcher<?(Nat, Deque.Deque<Nat>)> {
  let testable = T.tuple2Testable(T.natTestable, natDequeTestable);
  M.equals(T.optional(testable, ?(element, remainder)))
};

func matchEmptyFrontRemoval() : M.Matcher<?(Nat, Deque.Deque<Nat>)> {
  let testable = T.tuple2Testable(T.natTestable, natDequeTestable);
  M.equals(T.optional(testable, null : ?(Nat, Deque.Deque<Nat>)))
};

func matchBackRemoval(remainder : Deque.Deque<Nat>, element : Nat) : M.Matcher<?(Deque.Deque<Nat>, Nat)> {
  let testable = T.tuple2Testable(natDequeTestable, T.natTestable);
  M.equals(T.optional(testable, ?(remainder, element)))
};

func matchEmptyBackRemoval() : M.Matcher<?(Deque.Deque<Nat>, Nat)> {
  let testable = T.tuple2Testable(natDequeTestable, T.natTestable);
  M.equals(T.optional(testable, null : ?(Deque.Deque<Nat>, Nat)))
};

func reduceFront<T>(deque : Deque.Deque<T>, amount : Nat) : Deque.Deque<T> {
  var current = deque;
  for (_ in Iter.range(1, amount)) {
    switch (Deque.popFront(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.1
    }
  };
  current
};

func reduceBack<T>(deque : Deque.Deque<T>, amount : Nat) : Deque.Deque<T> {
  var current = deque;
  for (_ in Iter.range(1, amount)) {
    switch (Deque.popBack(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.0
    }
  };
  current
};

/* --------------------------------------- */

var deque = Deque.empty<Nat>();

run(
  suite(
    "construct",
    [
      test(
        "empty",
        Deque.isEmpty(deque),
        M.equals(T.bool(true))
      ),
      test(
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "peek front",
        Deque.peekFront(deque),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "peek back",
        Deque.peekBack(deque),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "pop front",
        Deque.popFront(deque),
        matchEmptyFrontRemoval()
      ),
      test(
        "pop back",
        Deque.popBack(deque),
        matchEmptyBackRemoval()
      )
    ]
  )
);

/* --------------------------------------- */

deque := Deque.pushFront(Deque.empty<Nat>(), 1);

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
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(T.array(T.natTestable, [1]))
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(T.array(T.natTestable, [1]))
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

/* --------------------------------------- */

let testSize = 100;

func populateForward(from : Nat, to : Nat) : Deque.Deque<Nat> {
  var deque = Deque.empty<Nat>();
  for (number in Iter.range(from, to)) {
    deque := Deque.pushFront(deque, number)
  };
  deque
};

deque := populateForward(1, testSize);

run(
  suite(
    "forward insertion",
    [
      test(
        "not empty",
        Deque.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                testSize - index
              }
            )
          )
        )
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                index + 1
              }
            )
          )
        )
      ),
      test(
        "peek front",
        Deque.peekFront(deque),
        M.equals(T.optional(T.natTestable, ?testSize))
      ),
      test(
        "peek back",
        Deque.peekBack(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "pop front",
        Deque.popFront(deque),
        matchFrontRemoval(testSize, populateForward(1, testSize - 1))
      ),
      test(
        "empty after front removal",
        Deque.isEmpty(reduceFront(deque, testSize)),
        M.equals(T.bool(true))
      ),
      test(
        "empty after front removal",
        Deque.isEmpty(reduceBack(deque, testSize)),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

func populateBackward(from : Nat, to : Nat) : Deque.Deque<Nat> {
  var deque = Deque.empty<Nat>();
  for (number in Iter.range(from, to)) {
    deque := Deque.pushBack(deque, number)
  };
  deque
};

deque := populateBackward(1, testSize);

run(
  suite(
    "backward insertion",
    [
      test(
        "not empty",
        Deque.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                index + 1
              }
            )
          )
        )
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                testSize - index
              }
            )
          )
        )
      ),
      test(
        "peek front",
        Deque.peekFront(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "peek back",
        Deque.peekBack(deque),
        M.equals(T.optional(T.natTestable, ?testSize))
      ),
      test(
        "pop front",
        Deque.popFront(deque),
        matchFrontRemoval(1, populateBackward(2, testSize))
      ),
      test(
        "pop back",
        Deque.popBack(deque),
        matchBackRemoval(populateBackward(1, testSize - 1), testSize)
      ),
      test(
        "empty after front removal",
        Deque.isEmpty(reduceFront(deque, testSize)),
        M.equals(T.bool(true))
      ),
      test(
        "empty after front removal",
        Deque.isEmpty(reduceBack(deque, testSize)),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

object Random {
  var number = 4711;
  public func next() : Int {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

func randomPopulate(amount : Nat) : Deque.Deque<Nat> {
  var current = Deque.empty<Nat>();
  for (number in Iter.range(1, amount)) {
    current := if (Random.next() % 2 == 0) {
      Deque.pushFront(current, Nat.sub(amount, number))
    } else {
      Deque.pushBack(current, amount + number)
    }
  };
  current
};

func isSorted(deque : Deque.Deque<Nat>) : Bool {
  let array = Iter.toArray(iterateForward(deque));
  let sorted = Array.sort(array, Nat.compare);
  Array.equal(array, sorted, Nat.equal)
};

func randomRemoval(deque : Deque.Deque<Nat>, amount : Nat) : Deque.Deque<Nat> {
  var current = deque;
  for (number in Iter.range(1, amount)) {
    current := if (Random.next() % 2 == 0) {
      let pair = Deque.popFront(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.1
      }
    } else {
      let pair = Deque.popBack(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.0
      }
    }
  };
  current
};

deque := randomPopulate(testSize);

run(
  suite(
    "random insertion",
    [
      test(
        "not empty",
        Deque.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "correct order",
        isSorted(deque),
        M.equals(T.bool(true))
      ),
      test(
        "consistent iteration",
        Iter.toArray(iterateForward(deque)),
        M.equals(T.array(T.natTestable, Array.reverse(Iter.toArray(iterateBackward(deque)))))
      ),
      test(
        "random quarter removal",
        isSorted(randomRemoval(deque, testSize / 4)),
        M.equals(T.bool(true))
      ),
      test(
        "random half removal",
        isSorted(randomRemoval(deque, testSize / 2)),
        M.equals(T.bool(true))
      ),
      test(
        "random three quarter removal",
        isSorted(randomRemoval(deque, testSize * 3 / 4)),
        M.equals(T.bool(true))
      ),
      test(
        "random total removal",
        Deque.isEmpty(randomRemoval(deque, testSize)),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

func randomInsertionDeletion(steps : Nat) : Deque.Deque<Nat> {
  var current = Deque.empty<Nat>();
  var size = 0;
  for (number in Iter.range(1, steps)) {
    let random = Random.next();
    current := switch (random % 4) {
      case 0 {
        size += 1;
        Deque.pushFront(current, Nat.sub(steps, number))
      };
      case 1 {
        size += 1;
        Deque.pushBack(current, steps + number)
      };
      case 2 {
        switch (Deque.popFront(current)) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.1
          }
        }
      };
      case 3 {
        switch (Deque.popBack(current)) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.0
          }
        }
      };
      case _ Prim.trap("Impossible case")
    };
    assert (isSorted(current))
  };
  current
};

run(
  suite(
    "completely random",
    [
      test(
        "random insertion and deletion",
        isSorted(randomInsertionDeletion(1000)),
        M.equals(T.bool(true))
      )
    ]
  )
)
