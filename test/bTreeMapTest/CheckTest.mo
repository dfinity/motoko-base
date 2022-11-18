import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";

import Nat "mo:base/Nat";

import Check "../src/Check";
import BT "../src/BTree";
import Types "../src/Types";

let orderResultTestableItem = func(result: Check.CheckOrderResult): T.TestableItem<Check.CheckOrderResult> = {
  display = func(r: Check.CheckOrderResult): Text = switch(r) { 
    case (#ok) "#ok"; 
    case (#err) "#err";
  }; 
  equals = func(r1: Check.CheckOrderResult, r2: Check.CheckOrderResult): Bool = switch(r1, r2) {
    case (#ok, #ok) { true };
    case (#err, #err) { true };
    case _ false;
  }; 
  item = result;
};

let depthResultTestableItem = func(result: Check.CheckDepthResult): T.TestableItem<Check.CheckDepthResult> = {
  display = func(r: Check.CheckDepthResult): Text = switch(r) { 
    case (#ok(depth)) "#ok: " # Nat.toText(depth); 
    case (#err) "#err";
  }; 
  equals = func(r1: Check.CheckDepthResult, r2: Check.CheckDepthResult): Bool = switch(r1, r2) {
    case (#ok(d1), #ok(d2)) { d1 == d2 };
    case (#err, #err) { true };
    case _ false;
  }; 
  item = result;
};


let checkTreeDepthIsValidSuite = S.suite("checkTreeDepthIsValid", [
  S.suite("order 4 BTree", [
    S.test("test empty BTree has height 1",
      Check.checkTreeDepthIsValid<Nat, Nat>(BT.init<Nat, Nat>(4)),
      M.equals(depthResultTestableItem(#ok(1)))
    ),
    S.test("test 5000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(4);
        while (i < 5000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.checkTreeDepthIsValid<Nat, Nat>(t);
      },
      M.equals(depthResultTestableItem(#ok(8)))
    ),
    S.test("test 10000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(4);
        while (i < 20000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.checkTreeDepthIsValid<Nat, Nat>(t);
      },
      M.equals(depthResultTestableItem(#ok(9)))
    ),
  ]),
  S.suite("order 128 BTree", [
    S.test("test empty BTree has height 1",
      Check.checkTreeDepthIsValid<Nat, Nat>(BT.init<Nat, Nat>(128)),
      M.equals(depthResultTestableItem(#ok(1)))
    ),
    S.test("test 5000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(128);
        while (i < 5000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.checkTreeDepthIsValid<Nat, Nat>(t);
      },
      M.equals(depthResultTestableItem(#ok(2)))
    ),
    S.test("test 20000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(128);
        while (i < 20000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.checkTreeDepthIsValid<Nat, Nat>(t);
      },
      M.equals(depthResultTestableItem(#ok(3)))
    ),
  ]),
  S.test("uneven & invalid BTree depth",
    do {
      let t: Types.BTree<Nat, Nat> = {
        var root = #internal({
          data = {
            kvs = [var ?(6, 6), ?(15, 15), null];
            var count = 1;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(2, 2), ?(3, 3), ?(4, 4)];
                var count = 3;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(5, 5), ?(8, 8), null];
                var count = 1;
              };
            }),
            ?#internal({
              data = {
                kvs = [var ?(20, 20), null, null];
                var count = 1;
              };
              children = [var
                ?#leaf({
                  data = {
                    kvs = [var ?(17, 17), ?(19, 19), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(25, 25), null, null];
                    var count = 1;
                  };
                }),
                null,
                null
              ]
            }),
            null,
          ]
        });
        order = 4;
      };
      Check.checkTreeDepthIsValid<Nat, Nat>(t);
    },
    M.equals(depthResultTestableItem(#err))
  )
]);

let checkDataOrderIsValidSuite = S.suite("checkDataDepthIsValid", [
  S.suite("order 4 BTree", [
    S.test("test empty BTree",
      Check.checkDataOrderIsValid<Nat, Nat>(BT.init<Nat, Nat>(4), Nat.compare),
      M.equals(orderResultTestableItem(#ok))
    ),
    S.test("test 5000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(4);
        while (i < 5000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem((#ok)))
    ),
  ]),
  S.suite("order 16 BTrees", [
    S.test("test empty BTree",
      Check.checkDataOrderIsValid<Nat, Nat>(BT.init<Nat, Nat>(16), Nat.compare),
      M.equals(orderResultTestableItem(#ok))
    ),
    S.test("test 5000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(16);
        while (i < 5000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem((#ok)))
    ),
  ]),
  S.suite("order 99 BTrees", [
    S.test("test empty BTree",
      Check.checkDataOrderIsValid<Nat, Nat>(BT.init<Nat, Nat>(99), Nat.compare),
      M.equals(orderResultTestableItem(#ok))
    ),
    S.test("test 5000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(99);
        while (i < 5000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem((#ok)))
    ),
  ]),
  S.suite("are not valid btrees", [
    S.test("if have invalid nested leaf data order",
      do {
        let t: Types.BTree<Nat, Nat> = {
          var root = #internal({
            data = {
              kvs = [var ?(6, 6), null, null];
              var count = 1;
            };
            children = [var 
              ?#leaf({
                data = {
                  kvs = [var ?(2, 2), ?(3, 3), ?(4, 4)];
                  var count = 3;
                };
              }),
              ?#leaf({
                data = {
                  kvs = [var ?(5, 5), ?(8, 8), null];
                  var count = 1;
                };
              }),
              null,
              null,
            ]
          });
          order = 4;
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem((#err)))
    ),
    S.test("if have invalid internal node data order",
      do {
        let t: Types.BTree<Nat, Nat> = {
          var root = #internal({
            data = {
              kvs = [var ?(6, 6), ?(0, 0), null];
              var count = 1;
            };
            children = [var 
              ?#leaf({
                data = {
                  kvs = [var ?(2, 2), ?(3, 3), ?(4, 4)];
                  var count = 3;
                };
              }),
              ?#leaf({
                data = {
                  kvs = [var ?(8, 8), null, null];
                  var count = 1;
                };
              }),
              null,
              null,
            ]
          });
          order = 4;
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem(#err))
    ),
    S.test("if have a null before a non-null key-value pair in a leaf",
      do {
        let t: Types.BTree<Nat, Nat> = {
          var root = #internal({
            data = {
              kvs = [var ?(6, 6), null, null];
              var count = 1;
            };
            children = [var 
              ?#leaf({
                data = {
                  kvs = [var ?(2, 2), ?(3, 3), ?(4, 4)];
                  var count = 3;
                };
              }),
              ?#leaf({
                data = {
                  kvs = [var null, ?(8, 8), null];
                  var count = 1;
                };
              }),
              null,
              null,
            ]
          });
          order = 4;
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem(#err))
    ),
    S.test("if have a null before a non-null key-value pair in an internal",
      do {
        let t: Types.BTree<Nat, Nat> = {
          var root = #internal({
            data = {
              kvs = [var null, ?(6, 6), null];
              var count = 1;
            };
            children = [var 
              ?#leaf({
                data = {
                  kvs = [var ?(2, 2), ?(3, 3), ?(4, 4)];
                  var count = 3;
                };
              }),
              ?#leaf({
                data = {
                  kvs = [var ?(8, 8), null, null];
                  var count = 1;
                };
              }),
              null,
              null,
            ]
          });
          order = 4;
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem(#err))
    ),
    S.test("if invalid number of children",
      do {
        let t: Types.BTree<Nat, Nat> = {
          var root = #internal({
            data = {
              kvs = [var ?(6, 6), ?(0, 0), null];
              var count = 1;
            };
            children = [var 
              ?#leaf({
                data = {
                  kvs = [var ?(2, 2), ?(3, 3), ?(4, 4)];
                  var count = 3;
                };
              }),
              ?#leaf({
                data = {
                  kvs = [var ?(8, 8), null, null];
                  var count = 1;
                };
              }),
              null,
              null,
              null
            ]
          });
          order = 4;
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem(#err))
    ),
    S.test("if invalid number of keys",
      do {
        let t: Types.BTree<Nat, Nat> = {
          var root = #internal({
            data = {
              kvs = [var ?(6, 6), ?(0, 0), null];
              var count = 1;
            };
            children = [var 
              ?#leaf({
                data = {
                  kvs = [var ?(2, 2), ?(3, 3), ?(4, 4), ?(5, 5)];
                  var count = 3;
                };
              }),
              ?#leaf({
                data = {
                  kvs = [var ?(8, 8), null, null];
                  var count = 1;
                };
              }),
              null,
              null,
            ]
          });
          order = 4;
        };
        Check.checkDataOrderIsValid<Nat, Nat>(t, Nat.compare);
      },
      M.equals(orderResultTestableItem(#err))
    ),
  ]),
]);

let checkSuite = S.suite("checkSuite", [
  S.suite("order 4 BTree", [
    S.test("test empty BTree",
      Check.check<Nat, Nat>(BT.init<Nat, Nat>(4), Nat.compare),
      M.equals(T.bool(true))
    ),
    S.test("test 5000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(4);
        while (i < 5000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.check<Nat, Nat>(t, Nat.compare);
      },
      M.equals(T.bool(true))
    ),
  ]),
  S.suite("order 128 BTree", [
    S.test("test empty BTree",
      Check.check<Nat, Nat>(BT.init<Nat, Nat>(128), Nat.compare),
      M.equals(T.bool(true))
    ),
    S.test("test 5000 auto incrementing inserts into the BTree",
      do {
        var i = 0;
        let t = BT.init<Nat, Nat>(128);
        while (i < 5000) {
          ignore BT.insert<Nat, Nat>(t, Nat.compare, i, i);
          i += 1
        };
        Check.check<Nat, Nat>(t, Nat.compare);
      },
      M.equals(T.bool(true))
    ),
  ])
]);

S.run(S.suite("check", [
  checkTreeDepthIsValidSuite,
  checkDataOrderIsValidSuite,
  checkSuite,
]))


