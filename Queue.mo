import List "mo:base/List";

module {

  // FIFO queue using purely-functional, singly-linked lists.

  type List<T> = List.List<T>;

  public type Queue<T> = (List<T>, List<T>);

  /// Create an empty queue.
  public func nil<T>() : Queue<T> { 
    (List.nil<T>(), List.nil<T>()) 
  };

  /// Check whether a queue is empty and return true if the queue is empty.
  public func isEmpty<T>(q: Queue<T>) : Bool {
    switch (q) {
      case ((null, null)) true;
      case ( _ )          false;
    }
  };

  /// Append a value to the head of the queue.
  public func enqueue<T>(v: T, q: Queue<T>) : Queue<T> {
    (?(v, q.0), q.1 );
  };

  /// Return a value from the tail of the queue, without removing it.
  public func peek<T>(q: Queue<T>) : ?T {
    switch (q.1) {
    case (?(h, t)) {
      return ?h;
    };
    case null {
        switch (q.0) {
        case (?(h, t)) {
          let swapped = (List.nil<T>(), List.reverse<T>(q.0));
          return peek<T>(swapped);
        };
        case null {
          return ( null );
        };
        };
    };
    };
  };

  /// Return a value from the tail of the queue and remove it from the queue.
  public func dequeue<T>(q: Queue<T>) : (?T, Queue<T>) {
    switch (q.1) {
    case (?(h, t)) {
      return ( ?h, (q.0, t) );
    };
    case null {
      switch (q.0) {
      case (?(h, t)) {
          let swapped = (List.nil<T>(), List.reverse<T>(q.0));
          return dequeue<T>(swapped);
      };
      case null {
        return ( null, q );
      };
      };
    };
    };
  };

};