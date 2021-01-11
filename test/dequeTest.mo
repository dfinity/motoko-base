import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import O "mo:base/Option";
import D "mo:base/Debug";

// test for Queue
do {
    var l = Deque.empty<Nat>();
    for (i in Iter.range(0, 100)) {
        l := Deque.pushBack(l, i);
    };
    for (i in Iter.range(0, 100)) {
        let x = Deque.peekFront(l);
        switch (Deque.popFront(l)) {
          case (?(y, l2)) { l := l2;
             switch x {
               case null assert false;
               case (?x) assert (x == y) } };
          case null { assert false };
        };
        assert(O.unwrap(x) == i);
    };
    O.assertNull(Deque.peekFront<Nat>(l));
};

// test for Deque
do {
    var l = Deque.empty<Int>();
    for (i in Iter.range(1, 100)) {
        l := Deque.pushFront(l, -i);
        l := Deque.pushBack(l, i);
    };
    label F for (i in Iter.revRange(100, -100)) {
        if (i == 0) continue F;
        let x = Deque.peekBack(l);
        switch (Deque.popBack(l)) {
          case (?(l2, y)) { l := l2;
             switch x {
               case null assert false;
               case (?x) assert (x == y) } };
          case null { assert false };
        };
        assert(O.unwrap(x) == i);
    };
};
