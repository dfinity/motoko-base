/**
[#mod-Deque]
= `Deque` -- Double-ended Queue 

This module provides purely-functional double-ended queue.

*/

import List "mo:base/List";
import P "mo:base/Prelude";

module {
    type List<T> = List.List<T>;
    
    public type Deque<T> = (List<T>, List<T>);
    public let empty : <T> () -> Deque<T> =
      func<T> () : Deque<T> {
        (List.nil(), List.nil());
    };
    public let isEmpty : <T> Deque<T> -> Bool =
      func<T>(q : Deque<T>) : Bool {
        switch q {
        case (f, r) List.isNil(f) and List.isNil(r);
        }
    };
    func check<T>(q : Deque<T>) : Deque<T> {
      switch q {
      case (null, r) { let (a,b) = List.splitAt(List.len(r) / 2, r); (List.rev(b), a) };
      case (f, null) { let (a,b) = List.splitAt(List.len(f) / 2, f); (a, List.rev(b)) };
      case q q;
      }
    };
    public let pushFront : <T> (Deque<T>, T) -> Deque<T> =
      func<T>((f : List<T>, r : List<T>), x : T) : Deque<T> = check (List.push(x, f), r);
    public let peekFront : <T> Deque<T> -> ?T =
      func<T>(q: Deque<T>) : ?T {
        switch q {
        case (?(x, f), r) ?x;
        case (null, ?(x, r)) ?x;
        case _ null;
        };
    };
    public let removeFront : <T> Deque<T> -> Deque<T> =
      func<T>(q: Deque<T>) : Deque<T> {
        switch q {
        case (?(x, f), r) check(f, r);
        case (null, ?(x, r)) check(null, r);
        case _ P.unreachable();
        };
    };
    
    public let pushBack : <T> (Deque<T>, T) -> Deque<T> =
      func<T>((f : List<T>, r : List<T>), x : T) : Deque<T> = check (f, List.push(x, r));
    public let peekBack : <T> Deque<T> -> ?T =
      func<T>(q: Deque<T>) : ?T {
        switch q {
        case (f, ?(x, r)) ?x;
        case (?(x, r), null) ?x;
        case _ null;
        };
    };
    public let removeBack : <T> Deque<T> -> Deque<T> =
      func<T>(q: Deque<T>) : Deque<T> {
        switch q {
        case (f, ?(x, r)) check(f, r);
        case (?(x, f), null) check(f, null);
        case _ P.unreachable();
        };
    };
};
