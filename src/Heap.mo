/**
[#mod-Heap]
= `Heap` -- Priority Queue 

This module provides purely-functional priority queue based on leftist heap

*/

import P "mo:base/Prelude";
import L "mo:base/List";  

module {
    public type Heap<T> = ?(Int, T, Heap<T>, Heap<T>);
    public class MakeHeap<T>(ord : (T, T) -> Bool) {
        var heap : Heap<T> = null;
        func rank(heap : Heap<T>) : Int {
            switch heap {
            case (null) 0;
            case (?(r, _, _, _)) r;
            }
        };
        func makeT (x : T, a : Heap<T>, b : Heap<T>) : Heap<T> {
            if (rank(a) >= rank(b)) ?(rank(b) + 1, x, a, b) else ?(rank(a) + 1, x, b, a);
        };
        func merge (h1 : Heap<T>, h2 : Heap<T>) : Heap<T> {
            switch (h1, h2) {
            case (null, h) h;
            case (h, null) h;
            case (?(_, x, a, b), ?(_, y, c, d)) {
                     if (ord(x,y))
                     makeT (x, a, merge(b, h2))
                     else
                     makeT (y, c, merge(d, h1))
                 };
            }
        };

        public func add(x : T) {
            heap := merge(heap, ?(1, x, null, null));
        };
        public func peekMin() : ?T {
            switch heap {
            case (null) null;
            case (?(_, x, _, _)) ?x;
            }
        };
        public func removeMin() {
            switch heap {
            case (null) P.unreachable();
            case (?(_, _, a, b)) heap := merge(a,b);
            }
        };
        public func fromList(a : L.List<T>) {
            func build(xs : L.List<Heap<T>>) : Heap<T> {
                func join(xs : L.List<Heap<T>>) : L.List<Heap<T>> {
                    switch(xs) {
                    case (null) null;
                    case (?(hd, null)) ?(hd, null);
                    case (?(h1, ?(h2, tl))) ?(merge(h1, h2), join tl);
                    }
                };
                switch(xs) {
                case (null) P.unreachable();
                case (?(hd, null)) hd;
                case _ build (join xs);
                };
            };
            switch(a) {
            case (null) heap := null;
            case _
              heap := build (L.map (a, func (x : T) : Heap<T> = ?(1, x, null, null)));
            };
        };
    };
};
