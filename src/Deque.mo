/// Double-ended Queue
///
/// This module provides a purely-functional double-ended queue.

import List "List";
import P "Prelude";

module {
    type List<T> = List.List<T>;
    
    public type Deque<T> = (List<T>, List<T>);
    public func empty<T> () : Deque<T> = (List.nil(), List.nil());
    public func isEmpty<T>(q : Deque<T>) : Bool {
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
    public func pushFront<T>(q : Deque<T>, x : T) : Deque<T> =
      check (List.push(x, q.0), q.1);

    public func peekFront<T>(q: Deque<T>) : ?T {
      switch q {
      case (?(x, f), r) ?x;
      case (null, ?(x, r)) ?x;
      case _ null;
      };
    };
    public func popFront<T>(q: Deque<T>) : Deque<T> {
      switch q {
      case (?(x, f), r) check(f, r);
      case (null, ?(x, r)) check(null, r);
      case _ P.unreachable();
      };
    };
    
    public func pushBack<T>(q : Deque<T>, x : T) : Deque<T> =
      check (q.0, List.push(x, q.1));

    public func peekBack<T>(q: Deque<T>) : ?T {
      switch q {
      case (f, ?(x, r)) ?x;
      case (?(x, r), null) ?x;
      case _ null;
      };
    };
    public func popBack<T>(q: Deque<T>) : Deque<T> {
      switch q {
      case (f, ?(x, r)) check(f, r);
      case (?(x, f), null) check(f, null);
      case _ P.unreachable();
      };
    };
};
