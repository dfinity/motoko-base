import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";

import AU "../src/ArrayUtil";
import AUM "./ArrayUtilMatchers";


let insertAtPositionSuite = S.suite("insertAtPosition", [
  S.test("inserting at the first index of an array of all nulls inserts at the first element",
    do {
      let array: [var ?Nat] = [var null, null, null];
      AU.insertAtPosition<Nat>(array, ?3, 0, 0);
      array;
    },
    M.equals(AUM.varArray<?Nat>(
      T.optionalTestable<Nat>(T.natTestable),
      [var ?3, null, null]
    ))
  ),
  S.test("inserting into the last spot inserts correctly without shifting elements over",
    do {
      let array: [var ?Nat] = [var ?2, ?3, null];
      AU.insertAtPosition<Nat>(array, ?5, 2, 1);
      array;
    },
    M.equals(AUM.varArray<?Nat>(
      T.optionalTestable<Nat>(T.natTestable),
      [var ?2, ?3, ?5]
    ))
  ),
  S.test("inserting into the first index of the array with non-null elements correctly inserts the element and shifts all existing elements over",
    do {
      let array: [var ?Nat] = [var ?2, ?3, null];
      AU.insertAtPosition<Nat>(array, ?1, 0, 1);
      array;
    },
    M.equals(AUM.varArray<?Nat>(
      T.optionalTestable<Nat>(T.natTestable),
      [var ?1, ?2, ?3]
    ))
  ),
  S.test("inserting into a middle index of the array with non-null elements correctly inserts the element and shifts all latter elements over",
    do {
      let array: [var ?Nat] = [var ?2, ?5, null, null];
      AU.insertAtPosition<Nat>(array, ?3, 1, 1);
      array;
    },
    do {
      
    M.equals(AUM.varArray<?Nat>(
      T.optionalTestable<Nat>(T.natTestable),
      [var ?2, ?3, ?5, null]
    ))
    }
  ),
]);

let insertOneAtIndexAndSplitArraySuite = S.suite("insertOneAtIndexAndSplitArray", [
  S.suite("odd sized array", [
    S.test("insert split with largest element", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 9, 3);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?5, null], 7, [var ?9, null, null])
        ),
      )
    ),
    S.test("insert split with element in right half/split", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9, ?13];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 10, 4);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?5, ?7, null, null], 9, [var ?10, ?13, null, null, null])
        ),
      )
    ),
    S.test("insert split with element in middle", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9, ?13];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 8, 3);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?5, ?7, null, null], 8, [var ?9, ?13, null, null, null])
        ),
      )
    ),
    S.test("insert split with element in left half/split", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9, ?13];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 6, 2);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?5, ?6, null, null], 7, [var ?9, ?13, null, null, null])
        ),
      )
    ),
    S.test("insert split with smallest element", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9, ?13];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 1, 0);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?1, ?2, ?5, null, null], 7, [var ?9, ?13, null, null, null])
        ),
      )
    ),
  ]),
  S.suite("even sized array", [
    S.test("insert split with largest element", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 10, 4);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?5, null, null], 7, [var ?9, ?10, null, null])
        ),
      )
    ),
    S.test("insert split with element in right half/split", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 8, 3);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?5, null, null], 7, [var ?8, ?9, null, null])
        ),
      )
    ),
    S.test("insert split with element in middle", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 6, 2);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?5, null, null], 6, [var ?7, ?9, null, null])
        ),
      )
    ),
    S.test("insert split with element in left half/split", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 4, 1);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?2, ?4, null, null], 5, [var ?7, ?9, null, null])
        ),
      )
    ),
    S.test("insert split with smallest element", 
      do {
        let array: [var ?Nat] = [var ?2, ?5, ?7, ?9];
        AU.insertOneAtIndexAndSplitArray<Nat>(array, 1, 0);
      },
      M.equals(
        AUM.tuple3<[var ?Nat], Nat, [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          T.natTestable,
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?1, ?2, null, null ], 5, [var ?7, ?9, null, null])
        ),
      )
    ),
  ]),
]);


let insertTwoAtIndexAndSplitArraySuite = S.suite("insertTwoAtIndexAndSplitArray", [
  S.suite("odd sized array", [
    S.test("Case 1, both rebalanced child halves are inserted into smallest index of the left split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70];
        AU.splitArrayAndInsertTwo<Nat>(array, 0, 9, 11)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          // Note: 10 does not appear, as it was replaced by 9 & 11 (think of 10 as a node splitting in two, with 9 and 11 as the new rebalanced halves)
          ([var ?9, ?11, ?20, ?30, null, null, null], [var ?40, ?50, ?60, ?70, null, null, null])
        )
      ),
    ),
    S.test("Case 1, both rebalanced child halves are inserted into the middle of the left split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70];
        AU.splitArrayAndInsertTwo<Nat>(array, 1, 19, 21)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?19, ?21, ?30, null, null, null], [var ?40, ?50, ?60, ?70, null, null, null])
        )
      ),
    ),
    S.test("Case 1, both rebalanced child halves are inserted into the left split with the right rebalanced child as the last index of the left split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70];
        AU.splitArrayAndInsertTwo<Nat>(array, 2, 29, 31)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?29, ?31, null, null, null], [var ?40, ?50, ?60, ?70, null, null, null])
        )
      ),
    ),
    S.test("Case 2, both rebalanced child halves are inserted into smallest index of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70];
        AU.splitArrayAndInsertTwo<Nat>(array, 4, 49, 51)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?40, null, null, null], [var ?49, ?51, ?60, ?70, null, null, null])
        )
      ),
    ),
    S.test("Case 2, both rebalanced child halves are inserted into the middle of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70];
        AU.splitArrayAndInsertTwo<Nat>(array, 5, 59, 61)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?40, null, null, null], [var ?50, ?59, ?61, ?70, null, null, null])
        )
      ),
    ),
    S.test("Case 2, both rebalanced child halves are inserted into the right split with the right rebalanced child as the last index of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70];
        AU.splitArrayAndInsertTwo<Nat>(array, 6, 69, 71)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?40, null, null, null], [var ?50, ?60, ?69, ?71, null, null, null])
        )
      ),
    ),
    S.test("Case 3, the left rebalanced child half is inserted into the last index of the left split and the right rebalanced child is inserted into the first index of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70];
        AU.splitArrayAndInsertTwo<Nat>(array, 3, 39, 41)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?39, null, null, null], [var ?41, ?50, ?60, ?70, null, null, null])
        )
      ),
    ),
  ]),
  S.suite("even sized array", [
    S.test("Case 1, both rebalanced child halves are inserted into smallest index of the left split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70, ?80];
        AU.splitArrayAndInsertTwo<Nat>(array, 0, 9, 11)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          // Note: 10 does not appear, as it was replaced by 9 & 11 (think of 10 as a node splitting in two, with 9 and 11 as the new rebalanced halves)
          ([var ?9, ?11, ?20, ?30, ?40, null, null, null], [var ?50, ?60, ?70, ?80, null, null, null, null])
        )
      ),
    ),
    S.test("Case 1, both rebalanced child halves are inserted into the middle of the left split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70, ?80];
        AU.splitArrayAndInsertTwo<Nat>(array, 1, 19, 21)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?19, ?21, ?30, ?40, null, null, null], [var ?50, ?60, ?70, ?80, null, null, null, null])
        )
      ),
    ),
    S.test("Case 1, both rebalanced child halves are inserted into the left split with the right rebalanced child as the last index of the left split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70, ?80];
        AU.splitArrayAndInsertTwo<Nat>(array, 3, 39, 41)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?39, ?41, null, null, null], [var ?50, ?60, ?70, ?80, null, null, null, null])
        )
      ),
    ),
    S.test("Case 2, both rebalanced child halves are inserted into smallest index of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70, ?80];
        AU.splitArrayAndInsertTwo<Nat>(array, 5, 59, 61)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?40, ?50, null, null, null], [var ?59, ?61, ?70, ?80, null, null, null, null])
        )
      ),
    ),
    S.test("Case 2, both rebalanced child halves are inserted into the middle of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70, ?80];
        AU.splitArrayAndInsertTwo<Nat>(array, 6, 69, 71)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?40, ?50, null, null, null], [var ?60, ?69, ?71, ?80, null, null, null, null])
        )
      ),
    ),
    S.test("Case 2, both rebalanced child halves are inserted into the right split with the right rebalanced child as the last index of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70, ?80];
        AU.splitArrayAndInsertTwo<Nat>(array, 7, 79, 81)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?40, ?50, null, null, null], [var ?60, ?70, ?79, ?81, null, null, null, null])
        )
      ),
    ),
    S.test("Case 3, the left rebalanced child half is inserted into the last index of the left split and the right rebalanced child is inserted into the first index of the right split, replacing the element at that index",
      do {
        let array: [var ?Nat] = [var ?10, ?20, ?30, ?40, ?50, ?60, ?70, ?80];
        AU.splitArrayAndInsertTwo<Nat>(array, 4, 49, 51)
      },
      M.equals(
        T.tuple2<[var ?Nat], [var ?Nat]>(
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          AUM.varArrayTestable<?Nat>(
            T.optionalTestable<Nat>(T.natTestable)
          ),
          ([var ?10, ?20, ?30, ?40, ?49, null, null, null], [var ?51, ?60, ?70, ?80, null, null, null, null])
        )
      ),
    ),
  ])
]);


S.run(S.suite("ArrayUtil",
  [
    insertAtPositionSuite,
    insertOneAtIndexAndSplitArraySuite,
    insertTwoAtIndexAndSplitArraySuite
  ]
));