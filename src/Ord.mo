/**
[#mod-Ord]
= `Ord` -- Orderings
*/

module {

/**
A type to represent an ordering.
*/
public type Ord = {
  #lt;
  #eq;
  #gt;
};

/**
Check if an ordering is less than.
*/
public func isLT(ordering : Ord) : Bool {
  switch ordering {
    case (#lt) true;
    case _ false;
  };
};

/**
Check if an ordering is equal.
*/
public func isEQ(ordering : Ord) : Bool {
  switch ordering {
    case (#eq) true;
    case _ false;
  };
};

/**
Check if an ordering is greater than.
*/
public func isGT(ordering : Ord) : Bool {
  switch ordering {
    case (#gt) true;
    case _ false;
  };
};

};
