// @testmode wasi

import Map "../src/PersistentOrderedMap";
import Nat "../src/Nat";
import Iter "../src/Iter";
import Debug "../src/Debug";
import Array "../src/Array";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

class MapMatcher(expected : [(Nat, Text)]) : M.Matcher<Map.Map<Nat, Text>> {
  public func describeMismatch(actual : Map.Map<Nat, Text>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(Map.entries(actual))) # " should be " # debug_show (expected))
  };

  public func matches(actual : Map.Map<Nat, Text>) : Bool {
    Iter.toArray(Map.entries(actual)) == expected
  }
};

let natMapOps = Map.MapOps<Nat>(Nat.compare);

func checkMap(rbMap : Map.Map<Nat, Text>) {
  ignore blackDepth(rbMap)
};

func blackDepth(node : Map.Map<Nat, Text>) : Nat {
  func checkNode(left : Map.Map<Nat, Text>, key : Nat, right : Map.Map<Nat, Text>) : Nat {
    checkKey(left, func(x) { x < key });
    checkKey(right, func(x) { x > key });
    let leftBlacks = blackDepth(left);
    let rightBlacks = blackDepth(right);
    assert (leftBlacks == rightBlacks);
    leftBlacks
  };
  switch node {
    case (#leaf) 0;
    case (#red(left, (key, _), right)) {
      let leftBlacks = checkNode(left, key, right);
      assert (not isRed(left));
      assert (not isRed(right));
      leftBlacks
    };
    case (#black(left, (key, _), right)) {
      checkNode(left, key, right) + 1
    }
  }
};


func isRed(node : Map.Map<Nat, Text>) : Bool {
  switch node {
    case (#red(_, _, _)) true;
    case _ false
  }
};

func checkKey(node : Map.Map<Nat, Text>, isValid : Nat -> Bool) {
  switch node {
    case (#leaf) {};
    case (#red( _, (key, _), _)) {
      assert (isValid(key))
    };
    case (#black( _, (key, _), _)) {
      assert (isValid(key))
    }
  }
};

func insert(rbTree : Map.Map<Nat, Text>, key : Nat) : Map.Map<Nat, Text>  {
  let updatedTree = natMapOps.put(rbTree, key, debug_show (key));
  checkMap(updatedTree);
  updatedTree
};

func getAll(rbTree : Map.Map<Nat, Text>, keys : [Nat]) {
  for (key in keys.vals()) {
    let value = natMapOps.get(rbTree, key);
    assert (value == ?debug_show (key))
  }
};

func clear(initialRbMap : Map.Map<Nat, Text>) : Map.Map<Nat, Text> {
  var rbMap = initialRbMap;
  for ((key, value) in Map.entries(initialRbMap)) {
    // stable iteration
    assert (value == debug_show (key));
    let (newMap, result) = natMapOps.remove(rbMap, key);
    rbMap := newMap;
    assert (result == ?debug_show (key));
    checkMap(rbMap)
  };
  rbMap
};

func expectedEntries(keys : [Nat]) : [(Nat, Text)] {
  Array.tabulate<(Nat, Text)>(keys.size(), func(index) { (keys[index], debug_show (keys[index])) })
};

func concatenateKeys(key : Nat, value : Text, accum : Text) : Text {
  accum # debug_show(key)
};

func concatenateValues(key : Nat, value : Text, accum : Text) : Text {
  accum # value
};

func multiplyKeyAndConcat(key : Nat, value : Text) : Text {
  debug_show(key * 2) # value
};

func ifKeyLessThan(threshold : Nat, f : (Nat, Text) -> Text) : (Nat, Text) -> ?Text
  = func (key, value) {
    if(key < threshold)
      ?f(key, value)
    else null
  };

/* --------------------------------------- */

var buildTestMap = func() : Map.Map<Nat, Text> {
  Map.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        Map.size(buildTestMap()),
        M.equals(T.nat(0))
      ),
      test(
        "iterate forward",
        Iter.toArray(Map.iter(buildTestMap(), #fwd)),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "iterate backward",
        Iter.toArray(Map.iter(buildTestMap(), #bwd)),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "entries",
        Iter.toArray(Map.entries(buildTestMap())),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "keys",
        Iter.toArray(Map.keys(buildTestMap())),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "vals",
        Iter.toArray(Map.vals(buildTestMap())),
        M.equals(T.array<Text>(T.textTestable, []))
      ),
      test(
        "empty from iter",
        natMapOps.fromIter(Iter.fromArray([])),
        MapMatcher([])
      ),
      test(
        "get absent",
        natMapOps.get(buildTestMap(), 0),
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "remove absent",
        natMapOps.remove(buildTestMap(), 0).1,
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace absent/no value",
        natMapOps.replace(buildTestMap(), 0, "Test").1,
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace absent/key appeared",
        natMapOps.replace(buildTestMap(), 0, "Test").0,
        MapMatcher([(0, "Test")])
      ),
      test(
        "empty right fold keys",
        Map.foldRight(buildTestMap(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold keys",
        Map.foldLeft(buildTestMap(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty right fold values",
        Map.foldRight(buildTestMap(), "", concatenateValues),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold values",
        Map.foldLeft(buildTestMap(), "", concatenateValues),
        M.equals(T.text(""))
      ),
      test(
        "traverse empty map",
        Map.map(buildTestMap(), multiplyKeyAndConcat),
        MapMatcher([])
      ),
      test(
        "empty map filter",
        natMapOps.mapFilter(buildTestMap(), ifKeyLessThan(0, multiplyKeyAndConcat)),
        MapMatcher([])
      ),
    ]
  )
);

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  insert(Map.empty(), 0);
};

var expected = expectedEntries([0]);

run(
  suite(
    "single root",
    [
      test(
        "size",
        Map.size(buildTestMap()),
        M.equals(T.nat(1))
      ),
      test(
        "iterate forward",
        Iter.toArray(Map.iter(buildTestMap(), #fwd)),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "iterate backward",
        Iter.toArray(Map.iter(buildTestMap(), #bwd)),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "entries",
        Iter.toArray(Map.entries(buildTestMap())),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "keys",
        Iter.toArray(Map.keys(buildTestMap())),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "vals",
        Iter.toArray(Map.vals(buildTestMap())),
        M.equals(T.array<Text>(T.textTestable, ["0"]))
      ),
      test(
        "from iter",
        natMapOps.fromIter(Iter.fromArray(expected)),
        MapMatcher(expected)
      ),
      test(
        "get",
        natMapOps.get(buildTestMap(), 0),
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "replace function result",
        natMapOps.replace(buildTestMap(), 0, "TEST").1,
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "replace map result",
        do {
          let rbMap = buildTestMap();
          natMapOps.replace(rbMap, 0, "TEST").0
        },
        MapMatcher([(0, "TEST")])
      ),
      test(
        "remove function result",
        natMapOps.remove(buildTestMap(), 0).1,
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "remove map result",
        do {
          var rbMap = buildTestMap();
          rbMap := natMapOps.remove(rbMap, 0).0;
          checkMap(rbMap);
          rbMap
        },
        MapMatcher([])
      ),
      test(
        "right fold keys",
        Map.foldRight(buildTestMap(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold keys",
        Map.foldLeft(buildTestMap(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "right fold values",
        Map.foldRight(buildTestMap(), "", concatenateValues),
        M.equals(T.text("0"))
      ),
      test(
        "left fold values",
        Map.foldLeft(buildTestMap(), "", concatenateValues),
        M.equals(T.text("0"))
      ),
      test(
        "traverse map",
        Map.map(buildTestMap(), multiplyKeyAndConcat),
        MapMatcher([(0, "00")])
      ),
      test(
        "map filter/filter all",
        natMapOps.mapFilter(buildTestMap(), ifKeyLessThan(0, multiplyKeyAndConcat)),
        MapMatcher([])
      ),
      test(
        "map filter/no filer",
        natMapOps.mapFilter(buildTestMap(), ifKeyLessThan(1, multiplyKeyAndConcat)),
        MapMatcher([(0, "00")])
      ),
    ]
  )
);

/* --------------------------------------- */

expected := expectedEntries([0, 1, 2]);

func rebalanceTests(buildTestMap : () -> Map.Map<Nat, Text>) : [Suite.Suite] =
  [
    test(
      "size",
      Map.size(buildTestMap()),
      M.equals(T.nat(3))
    ),
    test(
      "map match",
      buildTestMap(),
      MapMatcher(expected)
    ),
    test(
      "iterate forward",
      Iter.toArray(Map.iter(buildTestMap(), #fwd)),
      M.equals(T.array<(Nat, Text)>(entryTestable, expected))
    ),
    test(
      "iterate backward",
      Iter.toArray(Map.iter(buildTestMap(), #bwd)),
      M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(expected)))
    ),
    test(
      "entries",
      Iter.toArray(Map.entries(buildTestMap())),
      M.equals(T.array<(Nat, Text)>(entryTestable, expected))
    ),
    test(
      "keys",
      Iter.toArray(Map.keys(buildTestMap())),
      M.equals(T.array<Nat>(T.natTestable, [0, 1, 2]))
    ),
    test(
      "vals",
      Iter.toArray(Map.vals(buildTestMap())),
      M.equals(T.array<Text>(T.textTestable, ["0", "1", "2"]))
    ),
    test(
      "from iter",
      natMapOps.fromIter(Iter.fromArray(expected)),
      MapMatcher(expected)
    ),
    test(
      "get all",
      do {
        let rbMap = buildTestMap();
        getAll(rbMap, [0, 1, 2]);
        rbMap
      },
      MapMatcher(expected)
    ),
    test(
      "clear",
      clear(buildTestMap()),
      MapMatcher([])
    ),
    test(
      "right fold keys",
      Map.foldRight(buildTestMap(), "", concatenateKeys),
      M.equals(T.text("210"))
    ),
    test(
      "left fold keys",
      Map.foldLeft(buildTestMap(), "", concatenateKeys),
      M.equals(T.text("012"))
    ),
    test(
      "right fold values",
      Map.foldRight(buildTestMap(), "", concatenateValues),
      M.equals(T.text("210"))
    ),
    test(
      "left fold values",
      Map.foldLeft(buildTestMap(), "", concatenateValues),
      M.equals(T.text("012"))
    ),
    test(
      "traverse map",
      Map.map(buildTestMap(), multiplyKeyAndConcat),
      MapMatcher([(0, "00"), (1, "21"), (2, "42")])
    ),
    test(
      "map filter/filter all",
      natMapOps.mapFilter(buildTestMap(), ifKeyLessThan(0, multiplyKeyAndConcat)),
      MapMatcher([])
    ),
    test(
      "map filter/filter one",
      natMapOps.mapFilter(buildTestMap(), ifKeyLessThan(1, multiplyKeyAndConcat)),
      MapMatcher([(0, "00")])
    ),
    test(
      "map filter/no filer",
      natMapOps.mapFilter(buildTestMap(), ifKeyLessThan(3, multiplyKeyAndConcat)),
      MapMatcher([(0, "00"), (1, "21"), (2, "42")])
    ),
  ];

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 1);
  rbMap := insert(rbMap, 0);
  rbMap
};

run(suite("rebalance left, left", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 1);
  rbMap
};

run(suite("rebalance left, right", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 1);
  rbMap
};

run(suite("rebalance right, left", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 1);
  rbMap := insert(rbMap, 2);
  rbMap
};

run(suite("rebalance right, right", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

run(
  suite(
    "repeated operations",
    [
      test(
        "repeated insert",
        do {
          var rbMap = buildTestMap();
          assert (natMapOps.get(rbMap, 1) == ?"1");
          rbMap := natMapOps.put(rbMap, 1, "TEST-1");
          natMapOps.get(rbMap, 1)
        },
        M.equals(T.optional(T.textTestable, ?"TEST-1"))
      ),
      test(
        "repeated replace",
        do {
          let rbMap0 = buildTestMap();
          let (rbMap1, firstResult) = natMapOps.replace(rbMap0, 1, "TEST-1");
          assert (firstResult == ?"1");
          let (rbMap2, secondResult) = natMapOps.replace(rbMap1, 1, "1");
          assert (secondResult == ?"TEST-1");
          rbMap2
        },
        MapMatcher(expected)
      ),
      test(
        "repeated remove",
        do {
          var rbMap0 = buildTestMap();
          let (rbMap1, result) = natMapOps.remove(rbMap0, 1);
          assert (result == ?"1");
          checkMap(rbMap1);
          natMapOps.remove(rbMap1, 1).1
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "repeated delete",
        do {
          var rbMap = buildTestMap();
          rbMap := natMapOps.delete(rbMap, 1);
          natMapOps.delete(rbMap, 1)
        },
        MapMatcher(expectedEntries([0, 2]))
      )
    ]
  )
);
