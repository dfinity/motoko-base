import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";

import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";

import BT "../src/BTree";


func testableNatBTree(t: BT.BTree<Nat, Nat>): T.TestableItem<BT.BTree<Nat, Nat>> {
  testableBTree(t, Nat.equal, Nat.equal, Nat.toText, Nat.toText)
};  

// Concise helper for setting up a BTree of type BTree<Nat, Nat> with multiple elements
func quickCreateBTreeWithKVPairs(order: Nat, keyValueDup: [Nat]): BT.BTree<Nat, Nat> {
  let kvPairs = Array.map<Nat, (Nat, Nat)>(keyValueDup, func(k) { (k, k) });

  BT.createBTreeWithKVPairs<Nat, Nat>(order, Nat.compare, kvPairs);
};

func testableBTree<K, V>(
  t: BT.BTree<K, V>,
  keyEquals: (K, K) -> Bool,
  valueEquals: (V, V) -> Bool,
  keyToText: K -> Text,
  valueToText: V -> Text,
): T.TestableItem<BT.BTree<K, V>> = {
  display = func(t: BT.BTree<K, V>): Text = BT.toText<K, V>(t, keyToText, valueToText);
  equals = func(t1: BT.BTree<K, V>, t2: BT.BTree<K, V>): Bool {
    BT.equals(t1, t2, keyEquals, valueEquals);
  }; 
  item = t;
};

let initSuite = S.suite("init", [
  S.test("initializes an empty BTree with order 4 to have the correct number of keys (order - 1)",
    BT.init<Nat, Nat>(4),
    M.equals(testableNatBTree({
      var root = #leaf({
        data = {
          kvs = [var null, null, null];
          var count = 0;
        }
      });
      order = 4;
    }))
  )
]);

let getSuite = S.suite("get", [
  S.test("returns null on an empty BTree",
    BT.get<Nat, Nat>(BT.init<Nat, Nat>(4), Nat.compare, 5),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  S.test("returns null on a BTree leaf node that does not contain the key",
    BT.get<Nat, Nat>(quickCreateBTreeWithKVPairs(4, [3, 7]), Nat.compare, 5),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  S.test("returns null on a multi-level BTree that does not contain the key",
    BT.get<Nat, Nat>(
      quickCreateBTreeWithKVPairs(4, [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160]),
      Nat.compare,
      21
    ),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  S.test("returns null on a multi-level BTree that does not contain the key, if the key is greater than all elements in the tree",
    BT.get<Nat, Nat>(
      quickCreateBTreeWithKVPairs(4, [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160]),
      Nat.compare,
      200
    ),
    M.equals(T.optional<Nat>(T.natTestable, null))
  ),
  S.test("returns the value if a BTree leaf node contains the key",
    BT.get<Nat, Nat>(quickCreateBTreeWithKVPairs(4, [3, 7, 10]), Nat.compare, 10),
    M.equals(T.optional<Nat>(T.natTestable, ?10))
  ),
  S.test("returns the value if a BTree internal node contains the key",
    BT.get<Nat, Nat>(
      quickCreateBTreeWithKVPairs(4, [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160]),
      Nat.compare,
      120
    ),
    M.equals(T.optional<Nat>(T.natTestable, ?120))
  ),
]);


let insertSuite = S.suite("insert", [
  S.suite("root as leaf tests", [
    S.test("inserts into an empty BTree",
      do {
        let t = BT.init<Nat, Nat>(4);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 4, 4);
        t;
      },
      M.equals(testableNatBTree({
        var root = #leaf({
          data = {
            kvs = [var ?(4, 4), null, null];
            var count = 1;
          }
        });
        order = 4;
      }))
    ),
    S.test("inserting an element into a BTree that does not exist returns null",
      do {
        let t = BT.init<Nat, Nat>(4);
        BT.insert<Nat, Nat>(t, Nat.compare, 4, 4);
      },
      M.equals(T.optional<Nat>(T.natTestable, null))
    ),
    S.test("replaces already existing element correctly into a BTree",
      do {
        let t = quickCreateBTreeWithKVPairs(6, [2, 4, 6]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 2, 22);
        t;
      },
      M.equals(testableNatBTree({
        var root = #leaf({
          data = {
            kvs = [var ?(2, 22), ?(4, 4), ?(6, 6), null, null];
            var count = 3;
          }
        });
        order = 6;
      }))
    ),
    S.test("returns the previous value of when replacing an already existing element in the BTree",
      do {
        let t = quickCreateBTreeWithKVPairs(6, [2, 4, 6]);
        BT.insert<Nat, Nat>(t, Nat.compare, 2, 22);
      },
      M.equals(T.optional<Nat>(T.natTestable, ?2))
    ),
    S.test("inserts new smallest element correctly into a BTree",
      do {
        let t = quickCreateBTreeWithKVPairs(6, [2, 4, 6]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 1, 1);
        t;
      },
      M.equals(testableNatBTree({
        var root = #leaf({
          data = {
            kvs = [var ?(1, 1), ?(2, 2), ?(4, 4), ?(6, 6), null];
            var count = 4;
          }
        });
        order = 6;
      }))
    ),
    S.test("inserts middle element correctly into a BTree",
      do {
        let t = quickCreateBTreeWithKVPairs(6, [2, 4, 6]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 5, 5);
        t;
      },
      M.equals(testableNatBTree({
        var root = #leaf({
          data = {
            kvs = [var ?(2, 2), ?(4, 4), ?(5,5), ?(6, 6), null];
            var count = 4;
          }
        });
        order = 6;
      }))
    ),
    S.test("inserts last element correctly into a BTree",
      do {
        let t = quickCreateBTreeWithKVPairs(6, [2, 4, 6]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 8, 8);
        t;
      },
      M.equals(testableNatBTree({
        var root = #leaf({
          data = {
            kvs = [var ?(2, 2), ?(4, 4), ?(6, 6), ?(8, 8), null];
            var count = 4;
          }
        });
        order = 6;
      }))
    ),
    S.test("orders multiple inserts into a BTree correctly",
      do {
        let t = quickCreateBTreeWithKVPairs(6, [8, 2, 10, 4, 6]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 8, 8);
        t;
      },
      M.equals(testableNatBTree({
        var root = #leaf({
          data = {
            kvs = [var ?(2, 2), ?(4, 4), ?(6, 6), ?(8, 8), ?(10, 10)];
            var count = 5;
          }
        });
        order = 6;
      }))
    ),
    S.test("inserting greatest element into full leaf splits an even ordererd BTree correctly",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 8, 8);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(6, 6), null, null];
            var count = 1;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(2, 2), ?(4, 4), null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(8, 8), null, null];
                var count = 1;
              };
            }),
            null,
            null
          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting greatest element into full leaf splits an odd ordererd BTree correctly",
      do {
        let t = quickCreateBTreeWithKVPairs(5, [2, 4, 6, 7]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 8, 8);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(6, 6), null, null, null];
            var count = 1;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(2, 2), ?(4, 4), null, null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(7, 7), ?(8, 8), null, null];
                var count = 2;
              };
            }),
            null,
            null,
            null
          ]
        });
        order = 5;
      }))
    ),
  ]),
  S.suite("root as internal tests", [
    S.test("inserting an element that already exists replaces it",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6, 8]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 8, 88);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(6, 6), null, null];
            var count = 1;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(2, 2), ?(4, 4), null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(8, 88), null, null];
                var count = 1;
              };
            }),
            null,
            null,
          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not yet exist into the right child",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6, 8]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 7, 7);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(6, 6), null, null];
            var count = 1;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(2, 2), ?(4, 4), null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(7, 7), ?(8, 8), null];
                var count = 2;
              };
            }),
            null,
            null,
          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not yet exist into the left child",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6, 8]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 3, 3);
        t;
      },
      M.equals(testableNatBTree({
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
                kvs = [var ?(8, 8), null, null];
                var count = 1;
              };
            }),
            null,
            null,
          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not yet exist into a full left most child promotes to the root correctly",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6, 8, 3]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 1, 1);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(3, 3), ?(6, 6), null];
            var count = 2;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(1, 1), ?(2, 2), null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(4, 4), null, null];
                var count = 1;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(8, 8), null, null];
                var count = 1;
              };
            }),
            null,
          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not yet exist into a full right most child promotes it to the root correctly",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6, 8, 3, 1, 10, 15]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 12, 12);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(3, 3), ?(6, 6), ?(12, 12)];
            var count = 3;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(1, 1), ?(2, 2), null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(4, 4), null, null];
                var count = 1;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(8, 8), ?(10, 10), null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(15, 15), null, null];
                var count = 1;
              };
            }),
          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not yet exist into a full right most child promotes it to the root correctly",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6, 8, 3, 1, 10, 15, 12]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 7, 7);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(3, 3), ?(6, 6), ?(12, 12)];
            var count = 3;
          };
          children = [var 
            ?#leaf({
              data = {
                kvs = [var ?(1, 1), ?(2, 2), null];
                var count = 2;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(4, 4), null, null];
                var count = 1;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(7, 7), ?(8, 8), ?(10, 10)];
                var count = 3;
              };
            }),
            ?#leaf({
              data = {
                kvs = [var ?(15, 15), null, null];
                var count = 1;
              };
            }),
          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not exist into a tree with a full root that where the inserted element is promoted to become the new root, also hitting case 2 of splitChildrenInTwoWithRebalances",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 4, 6, 8, 3, 1, 10, 15, 12, 7]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 9, 9);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(9, 9), null, null];
            var count = 1;
          };
          children = [var
            ?#internal({
              data = {
                kvs = [var ?(3, 3), ?(6, 6), null];
                var count = 2;
              };
              children = [var 
                ?#leaf({
                  data = {
                    kvs = [var ?(1, 1), ?(2, 2), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(4, 4), null, null];
                    var count = 1;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(7, 7), ?(8, 8), null];
                    var count = 2;
                  };
                }),
                null
              ]
            }),
            ?#internal({
              data = {
                kvs = [var ?(12, 12), null, null];
                var count = 1;
              };
              children = [var
                ?#leaf({
                  data = {
                    kvs = [var ?(10, 10), null, null];
                    var count = 1;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(15, 15), null, null];
                    var count = 1;
                  };
                }),
                null,
                null
              ]
            }),
            null,
            null

          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not exist into a tree with a full root that where the inserted element is promoted to be in the left internal child of the new root",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 10, 20, 8, 5, 7, 15, 25, 40, 3]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 4, 4);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(10, 10), null, null];
            var count = 1;
          };
          children = [var
            ?#internal({
              data = {
                kvs = [var ?(4, 4), ?(7, 7), null];
                var count = 2;
              };
              children = [var 
                ?#leaf({
                  data = {
                    kvs = [var ?(2, 2), ?(3, 3), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(5, 5), null, null];
                    var count = 1;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(8, 8), null, null];
                    var count = 1;
                  };
                }),
                null
              ]
            }),
            ?#internal({
              data = {
                kvs = [var ?(25, 25), null, null];
                var count = 1;
              };
              children = [var
                ?#leaf({
                  data = {
                    kvs = [var ?(15, 15), ?(20, 20), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(40, 40), null, null];
                    var count = 1;
                  };
                }),
                null,
                null
              ]
            }),
            null,
            null

          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not exist into that promotes and element from a full internal into a root internal with space, hitting case 2 of splitChildrenInTwoWithRebalances",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [2, 10, 20, 8, 5, 7, 15, 25, 40, 3, 4, 50, 60, 70, 80, 90, 100, 110, 120]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 130, 130);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(10, 10), ?(90, 90), null];
            var count = 2;
          };
          children = [var
            ?#internal({
              data = {
                kvs = [var ?(4, 4), ?(7, 7), null];
                var count = 2;
              };
              children = [var 
                ?#leaf({
                  data = {
                    kvs = [var ?(2, 2), ?(3, 3), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(5, 5), null, null];
                    var count = 1;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(8, 8), null, null];
                    var count = 1;
                  };
                }),
                null
              ]
            }),
            ?#internal({
              data = {
                kvs = [var ?(25, 25), ?(60, 60), null];
                var count = 2;
              };
              children = [var
                ?#leaf({
                  data = {
                    kvs = [var ?(15, 15), ?(20, 20), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(40, 40), ?(50, 50), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(70, 70), ?(80, 80), null];
                    var count = 2;
                  };
                }),
                null
              ]
            }),
            ?#internal({
              data = {
                kvs = [var ?(120, 120), null, null];
                var count = 1;
              };
              children = [var
                ?#leaf({
                  data = {
                    kvs = [var ?(100, 100), ?(110, 110), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(130, 130), null, null];
                    var count = 1;
                  };
                }),
                null,
                null
              ];
            }),
            null

          ]
        });
        order = 4;
      }))
    ),
    S.test("inserting an element that does not exist into a tree with a full root, promoting an element to the root and hitting case 1 of splitChildrenInTwoWithRebalances",
      do {
        let t = quickCreateBTreeWithKVPairs(4, [25, 100, 50, 75, 125, 150, 175, 200, 225, 250, 5]);
        let _ = BT.insert<Nat, Nat>(t, Nat.compare, 10, 10);
        t;
      },
      M.equals(testableNatBTree({
        var root = #internal({
          data = {
            kvs = [var ?(150, 150), null, null];
            var count = 1;
          };
          children = [var
            ?#internal({
              data = {
                kvs = [var ?(25, 25), ?(75, 75), null];
                var count = 2;
              };
              children = [var 
                ?#leaf({
                  data = {
                    kvs = [var ?(5, 5), ?(10, 10), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(50, 50), null, null];
                    var count = 1;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(100, 100), ?(125, 125), null];
                    var count = 2;
                  };
                }),
                null
              ]
            }),
            ?#internal({
              data = {
                kvs = [var ?(225, 225), null, null];
                var count = 1;
              };
              children = [var
                ?#leaf({
                  data = {
                    kvs = [var ?(175, 175), ?(200, 200), null];
                    var count = 2;
                  };
                }),
                ?#leaf({
                  data = {
                    kvs = [var ?(250, 250), null, null];
                    var count = 1;
                  };
                }),
                null,
                null
              ]
            }),
            null,
            null

          ]
        });
        order = 4;
      }))
    ),
  ])


]);


S.run(S.suite("BTree",
  [
    initSuite,
    getSuite,
    insertSuite
  ]
));