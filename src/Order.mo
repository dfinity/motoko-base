/// Order

module {

/// A type to represent an order.
public type Order = {
  #less;
  #equal;
  #greater;
};

/// Check if an order is #less.
public func isLess(order : Order) : Bool {
  switch order {
    case (#less) true;
    case _ false;
  };
};

/// Check if an order is #equal.
public func isEqual(order : Order) : Bool {
  switch order {
    case (#equal) true;
    case _ false;
  };
};

/// Check if an order is #greater.
public func isGreater(order : Order) : Bool {
  switch order {
    case (#greater) true;
    case _ false;
  };
};

};
