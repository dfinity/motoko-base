/**
[#mod-Heap]
= `Heap` -- Priority Queue 

This module provides purely-functional priority queue based on leftist heap

*/

import P "Prelude";
import L "List";

module {
    public type Comp = { #lt; #eq; #gt; };

    public class Heap<T>(ord : (T, T) -> Comp) {
        type t<T> = ?(Int, T, t<T>, t<T>);
        var heap : t<T> = null;
        func rank(heap : t<T>) : Int {
            switch heap {
            case (null) 0;
            case (?(r, _, _, _)) r;
            }
        };
        func makeT (x : T, a : t<T>, b : t<T>) : t<T> {
            if (rank(a) >= rank(b)) ?(rank(b) + 1, x, a, b) else ?(rank(a) + 1, x, b, a);
        };
        func merge (h1 : t<T>, h2 : t<T>) : t<T> {
            switch (h1, h2) {
            case (null, h) h;
            case (h, null) h;
            case (?(_, x, a, b), ?(_, y, c, d)) {
                     switch (ord(x,y)) {
                     case (#lt) makeT (x, a, merge(b, h2));
                     case _ makeT (y, c, merge(d, h1));
                     };
                 };
            };
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
        // TODO make this a static function when possible
        public func fromList(a : L.List<T>) {
            func build(xs : L.List<t<T>>) : t<T> {
                func join(xs : L.List<t<T>>) : L.List<t<T>> {
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
              heap := build (L.map (a, func (x : T) : t<T> = ?(1, x, null, null)));
            };
        };
    };
};
