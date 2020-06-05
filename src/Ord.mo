/// Orderings

module {

/// A type to represent an ordering.
public type Ordering = {
  #lt;
  #eq;
  #gt;
};

/// Check if an ordering is less than.
public let isLT : Ordering -> Bool =
  func(ordering : Ordering) : Bool {
    switch ordering {
      case (#lt) true;
      case _ false;
    };
  };

/// Check if an ordering is equal.
public let isEQ : Ordering -> Bool =
  func(ordering : Ordering) : Bool {
    switch ordering {
      case (#eq) true;
      case _ false;
    };
  };

/// Check if an ordering is greater than.
public let isGT : Ordering -> Bool =
  func(ordering : Ordering) : Bool {
    switch ordering {
      case (#gt) true;
      case _ false;
    };
  };

};
