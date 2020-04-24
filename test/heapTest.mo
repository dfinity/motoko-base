import Heap "mo:base/Heap";
import I "mo:base/Iter";
import O "mo:base/Option";
import D "mo:base/Debug";
import L "mo:base/List";

let ord : Heap.Comparable<Int> = object {
    public func compare(x : Int, y : Int) : Heap.Order {
        if (x < y) #lt
        else if (x > y) #gt
        else #eq;
    };
};

{
    var pq : Heap.t<Int> = Heap.makeHeap<Int>(ord);
    for (i in I.revRange(100, 0)) {
        pq.add(i);
        let x = pq.peekMin();
        assert(O.unwrap(x) == i);
    };
    for (i in I.range(0, 100)) {
        pq.add(i);
        let x = pq.peekMin();
        assert(O.unwrap(x) == 0);
    };
    for (i in I.range(0, 100)) {
        pq.removeMin();
        let x = pq.peekMin();
        pq.removeMin();
        assert(O.unwrap(x) == i);
    };
    O.assertNull(pq.peekMin());
};

// fromList
{
    let list = L.fromArray([5,10,9,7,3,8,1,0,2,4,6]);
    var pq = Heap.makeHeap<Int>(ord);
    pq.fromList(list);
    for (i in I.range(0, 10)) {
        let x = pq.peekMin();
        assert(O.unwrap(x) == i);
        pq.removeMin();
    };
    O.assertNull(pq.peekMin());

    pq.fromList(null);
    O.assertNull(pq.peekMin());

    pq.fromList(?(100, null));
    assert(O.unwrap(pq.peekMin()) == 100);
};
