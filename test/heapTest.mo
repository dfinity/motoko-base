import D "mo:base/Debug";
import H "mo:base/Heap";
import I "mo:base/Iter";
import L "mo:base/List";
import O "mo:base/Option";
import Order "mo:base/Order";

func order(x : Int, y : Int) : Order.Order {
    if (x < y) #less
    else if (x == y) #equal
    else #greater;
};

{
    var pq = H.Heap<Int>(order);
    for (i in I.revRange(100, 0)) {
        pq.put(i);
        let x = pq.peekMin();
        assert(O.unwrap(x) == i);
    };
    for (i in I.range(0, 100)) {
        pq.put(i);
        let x = pq.peekMin();
        assert(O.unwrap(x) == 0);
    };
    for (i in I.range(0, 100)) {
        pq.deleteMin();
        let x = pq.peekMin();
        pq.deleteMin();
        assert(O.unwrap(x) == i);
    };
    O.assertNull(pq.peekMin());
};

// fromList
{
    let list = L.fromArray([5,10,9,7,3,8,1,0,2,4,6]);
    var pq = H.Heap<Int>(order);
    pq.fromList(list);
    for (i in I.range(0, 10)) {
        let x = pq.peekMin();
        assert(O.unwrap(x) == i);
        pq.deleteMin();
    };
    O.assertNull(pq.peekMin());

    pq.fromList(null);
    O.assertNull(pq.peekMin());

    pq.fromList(?(100, null));
    assert(O.unwrap(pq.peekMin()) == 100);
};
