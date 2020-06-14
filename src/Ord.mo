/// Orderings

module {

/// A type to represent an ordering.
public type Ordering = {
  #lt;
  #eq;
  #gt;
};

/// Check if an ordering is less than.
public func isLT(ordering : Ordering) : Bool {
  switch ordering {
    case (#lt) true;
    case _ false;
  };
};

/// Check if an ordering is equal.
public func isEQ(ordering : Ordering) : Bool {
  switch ordering {
    case (#eq) true;
    case _ false;
  };
};

/// Check if an ordering is greater than.
public func isGT(ordering : Ordering) : Bool {
  switch ordering {
    case (#gt) true;
    case _ false;
  };
};

};
