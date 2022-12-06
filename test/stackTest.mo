import Stack "mo:base/Stack";
import Iter "mo:base/Iter";
import O "mo:base/Option";

do {
    var s = Stack.Stack<Nat>();
    for (i in Iter.range(0, 100)) {
        s.push(i);
    };
    for (i in Iter.revRange(100, 0)) {
        let x = s.pop();
        assert (O.unwrap(x) == i);
    };
    assert (s.isEmpty());
};
