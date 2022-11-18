import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";

import Nat "mo:base/Nat";

import B "../src/BinarySearch";

func testableSearchResult(r: B.SearchResult): T.TestableItem<B.SearchResult> = {
  display = func(r: B.SearchResult): Text = debug_show(r);
  equals = func(r1: B.SearchResult, r2: B.SearchResult): Bool {
    switch(r1, r2) {
      case (#notFound(i1), #notFound(i2)) { Nat.equal(i1, i2) };
      case (#keyFound(i1), #keyFound(i2)) { Nat.equal(i1, i2) };
      case _ { false }
    }
  };
  item = r;
};


let suite = S.suite("binarySearch", [
  /* This should assert false and trap
  S.test("array size 0 gives not found with 0 index",
    do {
      let x: [var ?Nat] = [var];
      B.binarySearchNode(x, Nat.compare, 5, 3);
    },
    M.equals(testableSearchResult(#notFound(0)))
  ),
  */
  S.test("array with all nulls gives not found with 0 index",
    do {
      let x: [var ?(Nat, Nat)] = [var null, null, null];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 1, 0);
    },
    M.equals(testableSearchResult(#notFound(0)))
  ),
  S.test("array with multiple elements but not found less than gives not found with 0 index",
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(4, 4), ?(6, 6)];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 1, 3);
    },
    M.equals(testableSearchResult(#notFound(0)))
  ),
  S.test("array with multiple elements but not found middle than gives not found with correct middle index",
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(4, 4), ?(6, 6)];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 3, 3);
    },
    M.equals(testableSearchResult(#notFound(1)))
  ),
  S.test("array with multiple elements but not found greater than all elements than gives not found with correct max index",
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(4, 4), ?(6, 6)];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 9, 3);
    },
    M.equals(testableSearchResult(#notFound(3)))
  ),
  S.test("array with multiple elements and nulls and element not found at end gives not found with correct index", 
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(3, 3), ?(5, 5), ?(9, 9), ?(13, 13), null, null];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 15, 5);
    },
    M.equals(testableSearchResult(#notFound(5)))
  ),
  S.test("array with multiple elements and element left most found produces element", 
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(3, 3), ?(5, 5), ?(9, 9), ?(13, 13)];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 2, 5);
    },
    M.equals(testableSearchResult(#keyFound(0)))
  ),
  S.test("array with multiple elements and element in left middle found produces element", 
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(3, 3), ?(5, 5), ?(9, 9), ?(13, 13)];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 3, 5);
    },
    M.equals(testableSearchResult(#keyFound(1)))
  ),
  S.test("array with multiple elements and element in right middle found produces element", 
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(3, 3), ?(5, 5), ?(9, 9), ?(13, 13)];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 9, 5);
    },
    M.equals(testableSearchResult(#keyFound(3)))
  ),
  S.test("array with multiple elements and element in right most found produces element", 
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(3, 3), ?(5, 5), ?(9, 9), ?(13, 13)];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 13, 5);
    },
    M.equals(testableSearchResult(#keyFound(4)))
  ),
  S.test("array with multiple elements and nulls and element found produces element", 
    do {
      let x: [var ?(Nat, Nat)] = [var ?(2, 2), ?(3, 3), ?(5, 5), ?(9, 9), ?(13, 13), null, null];
      B.binarySearchNode<Nat, Nat>(x, Nat.compare, 13, 5);
    },
    M.equals(testableSearchResult(#keyFound(4)))
  ),
  
]);

S.run(suite);