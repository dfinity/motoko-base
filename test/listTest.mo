import List "mo:base/List";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

type X = Nat;

func opnatEq(a : ?Nat, b : ?Nat) : Bool {
  switch (a, b) {
    case (null, null) { true };
    case (?aaa, ?bbb) { aaa == bbb };
    case (_, _) { false }
  }
};
func opnat_isnull(a : ?Nat) : Bool {
  switch a {
    case (null) { true };
    case (?aaa) { false }
  }
};

// ## Construction
let l1 = List.nil<X>();
let l2 = List.push<X>(2, l1);
let l3 = List.push<X>(3, l2);

// ## Projection -- use nth
assert (opnatEq(List.get<X>(l3, 0), ?3));
assert (opnatEq(List.get<X>(l3, 1), ?2));
assert (opnatEq(List.get<X>(l3, 2), null));
//assert (opnatEq (hd<X>(l3), ?3));
//assert (opnatEq (hd<X>(l2), ?2));
//assert (opnat_isnull(hd<X>(l1)));

/*
   // ## Projection -- use nth
   assert (opnatEq(nth<X>(l3, 0), ?3));
   assert (opnatEq(nth<X>(l3, 1), ?2));
   assert (opnatEq(nth<X>(l3, 2), null));
   assert (opnatEq (hd<X>(l3), ?3));
   assert (opnatEq (hd<X>(l2), ?2));
   assert (opnat_isnull(hd<X>(l1)));
   */

// ## Deconstruction
let (a1, t1) = List.pop<X>(l3);
assert (opnatEq(a1, ?3));
let (a2, t2) = List.pop<X>(l2);
assert (opnatEq(a2, ?2));
let (a3, t3) = List.pop<X>(l1);
assert (opnatEq(a3, null));
assert (List.isNil<X>(t3));

// ## List functions
assert (List.size<X>(l1) == 0);
assert (List.size<X>(l2) == 1);
assert (List.size<X>(l3) == 2);

// ## List functions
assert (List.size<X>(l1) == 0);
assert (List.size<X>(l2) == 1);
assert (List.size<X>(l3) == 2);

do {
  Debug.print("  flatten");

  let expected : List.List<Nat> = ?(1, ?(2, ?(3, null)));
  // [[1, 2], [3]]
  let nested : List.List<List.List<Nat>> = ?(?(1, ?(2, null)), ?(?(3, null), null));
  let actual = List.flatten<Nat>(nested);

  assert List.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 });

};

do {
  Debug.print("  fromArray");

  let expected : List.List<Nat> = ?(1, ?(2, ?(3, List.nil<Nat>())));
  let array = [1, 2, 3];
  let actual = List.fromArray<Nat>(array);

  assert List.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 })
};

do {
  Debug.print("  fromVarArray");

  let expected : List.List<Nat> = ?(1, ?(2, ?(3, List.nil<Nat>())));
  let array = [var 1, 2, 3];
  let actual = List.fromVarArray<Nat>(array);

  assert List.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 })
};

do {
  Debug.print("  toArray");

  let expected = [1, 2, 3];
  let list : List.List<Nat> = ?(1, ?(2, ?(3, List.nil<Nat>())));
  let actual = List.toArray<Nat>(list);

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toVarArray");

  let expected = [var 1, 2, 3];
  let list : List.List<Nat> = ?(1, ?(2, ?(3, List.nil<Nat>())));
  let actual = List.toVarArray<Nat>(list);

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toIter");

  let list : List.List<Nat> = ?(1, ?(2, ?(3, List.nil<Nat>())));
  let _actual = List.toIter<Nat>(list);
  let actual = [var 0, 0, 0];
  let expected = [1, 2, 3];

  Iter.iterate<Nat>(_actual, func(x, i) { actual[i] := x });

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

func makeNatural(x : Int) : Result.Result<Nat, Text> = if (x >= 0) {
  #ok(Int.abs(x))
} else { #err(Int.toText(x) # " is not a natural number.") };

func listRes(itm : Result.Result<List.List<Nat>, Text>) : T.TestableItem<Result.Result<List.List<Nat>, Text>> {
  let resT = T.resultTestable(T.listTestable<Nat>(T.intTestable), T.textTestable);
  { display = resT.display; equals = resT.equals; item = itm }
};



let mapResult = Suite.suite(
  "mapResult",
  [
    Suite.test(
      "empty list",
      List.mapResult<Int, Nat, Text>(List.nil(), makeNatural),
      M.equals(listRes(#ok(List.nil())))
    ),
    Suite.test(
      "success",
      List.mapResult<Int, Nat, Text>(?(1, ?(2, ?(3, null))), makeNatural),
      M.equals(listRes(#ok(?(1, ?(2, ?(3, null))))))
    ),
    Suite.test(
      "fail fast",
      List.mapResult<Int, Nat, Text>(?(-1, ?(2, ?(3, null))), makeNatural),
      M.equals(listRes(#err("-1 is not a natural number.")))
    ),
    Suite.test(
      "fail last",
      List.mapResult<Int, Nat, Text>(?(1, ?(2, ?(-3, null))), makeNatural),
      M.equals(listRes(#err("-3 is not a natural number.")))
    )
  ]
);

Suite.run(Suite.suite("List", [mapResult]));

let replicate = Suite.suite(
  "replicate",
  [
    Suite.test(
      "empty-list",
      List.replicate<Nat>(0, 0),
      M.equals(
        T.list(T.natTestable, List.nil<Nat>())
      )
    ),
    Suite.test(
      "small-list",
      List.replicate(3, 0),
      M.equals(
        T.list<Nat>(T.natTestable, ?(0, ?(0, ?(0, null))))
      )
    )
  ]
);

let tabulate = Suite.suite(
  "tabulate",
  [
    Suite.test(
      "empty-list",
      List.tabulate<Nat>(0, func i { i }),
      M.equals(
        T.list(T.natTestable, List.nil<Nat>())
      )
    ),
    Suite.test(
      "small-list",
      List.tabulate<Nat>(3, func i { i * 2 }),
      M.equals(
        T.list<Nat>(T.natTestable, ?(0, ?(2, ?(4, null))))
      )
    ),
    Suite.test(
      "large-list",
      List.tabulate<Nat>(10000, func i { 0 }),
      M.equals(
        T.list<Nat>(T.natTestable, List.replicate(10000, 0))
      )
    )
  ]
);

let append = Suite.suite(
  "append",
  [
    Suite.test(
      "small-list",
      List.append(
        List.tabulate<Nat>(10, func i { i }),
        List.tabulate<Nat>(10, func i { i + 10 })
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(20, func i { i }))
      )
    ),
    Suite.test(
      "large-list",
      List.append(
        List.tabulate<Nat>(10000, func i { i }),
        List.tabulate<Nat>(10000, func i { i + 10000 })
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(20000, func i { i }))
      )
    )
  ]
);

let isNil = Suite.suite(
  "isNil",
  [
    Suite.test(
      "empty",
      List.isNil(List.nil<Nat>()),
       M.equals(T.bool(true))
    ),
    Suite.test(
      "singleton",
      List.isNil(?(3, null)),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "nary",
      List.isNil(?(1, ?(2, ?(3, null)))),
      M.equals(T.bool(false))
    )
  ]
);

let push = Suite.suite(
  "push",
  [
    Suite.test(
      "empty",
      List.push(0, List.nil<Nat>()),
      M.equals(T.list(T.natTestable, ?(0, null)))
    ),
    Suite.test(
      "singleton",
      List.push(1, List.push(0, List.nil<Nat>())),
      M.equals(T.list(T.natTestable, ?(1, ?(0, null))))
    ),
    Suite.test(
      "nary",
      List.push(2, List.push(1, List.push(0, List.nil<Nat>()))),
      M.equals(T.list(T.natTestable, ?(2, ?(1, ?(0, null)))))
    )
  ]
);


let last = Suite.suite(
  "last",
  [
    Suite.test(
      "empty list",
      List.last(List.nil<Nat>()),
       M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton",
      List.last(?(3, null)),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "threesome",
      List.last(?(1, ?(2, ?(3, null)))),
      M.equals(T.optional(T.natTestable, ?3))
    )
  ]
);

let pop = Suite.suite(
  "pop",
  [
    Suite.test(
      "empty list",
      List.pop(List.nil<Nat>()),
      M.equals(T.tuple2(T.optionalTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (null, null) : (?Nat, List.List<Nat>) ))
    ),
    Suite.test(
      "singleton",
      List.pop(?(3, null)),
      M.equals(T.tuple2(T.optionalTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?3, null) : (?Nat, List.List<Nat>) ))
    ),
    Suite.test(
      "threesome",
      List.pop(?(1, ?(2, ?(3, null)))),
      M.equals(T.tuple2(T.optionalTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?1, ?(2, ?(3, null))) : (?Nat, List.List<Nat>) ))
    ),
  ]
);

let size = Suite.suite(
  "size",
  [
    Suite.test(
      "empty list",
      List.size(List.nil<Nat>()),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "singleton",
      List.size(?(3, null)),
      M.equals(T.nat(1))
    ),
    Suite.test(
      "threesome",
      List.size(?(1, ?(2, ?(3, null)))),
      M.equals(T.nat(3))
    ),
  ]
);

let get = Suite.suite(
  "get",
  [
    Suite.test(
      "empty list",
      List.get(List.nil<Nat>(), 0),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton-0",
      List.get(?(3, null), 0),
      M.equals(T.optional(T.natTestable, ?3 : ?Nat))
    ),
     Suite.test(
      "singleton-1",
      List.get(?(3, null), 1),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton-2",
      List.get(?(3, null), 2),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "threesome-0",
      List.get(?(1, ?(2, ?(3, null))), 0),
      M.equals(T.optional(T.natTestable, ?1 : ?Nat))
    ),
     Suite.test(
      "threesome-1",
      List.get(?(1, ?(2, ?(3, null))), 1),
      M.equals(T.optional(T.natTestable, ?2 : ?Nat))
    ),
     Suite.test(
      "threesome-3",
      List.get(?(1, ?(2, ?(3, null))), 3),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "threesome-4",
      List.get(?(1, ?(2, ?(3, null))), 4),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    )
  ]
);


let reverse = Suite.suite(
  "reverse",
  [
    Suite.test(
      "empty list",
      List.reverse(List.nil<Nat>()),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))

    ),
    Suite.test(
      "singleton",
      List.reverse(?(3, null)),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "threesome",
      List.reverse(?(1, ?(2, ?(3, null)))),
      M.equals(T.list(T.natTestable, ?(3, ?(2, ?(1, null)))))
    ),
  ]
);

let iterate = Suite.suite(
  "iterate",
  [
    Suite.test(
      "empty list",
      do {
        var t = "";
        List.iterate<Nat>(List.nil<Nat>(), func n { t #= debug_show n });
        t
      },
      M.equals(T.text(""))
    ),
    Suite.test(
      "singleton",
      do {
        var t = "";
        List.iterate<Nat>(?(3, null), func n { t #= debug_show n });
        t
      },
      M.equals(T.text("3"))
    ),
    Suite.test(
      "threesome",
      do {
        var t = "";
        List.iterate<Nat>(?(1, ?(2, ?(3, null))), func n { t #= debug_show n });
        t
      },
      M.equals(T.text("123"))
    ),
  ]
);

let map = Suite.suite(
  "map",
  [
    Suite.test(
      "empty list",
      List.map<Nat,Nat>(
       List.nil<Nat>(),
      func n { n + 1 }),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "singleton",
      List.map<Nat,Nat>(
        ?(3, null),
        func n { n + 1 }),
      M.equals(T.list(T.natTestable, ?(4, null)))
    ),
    Suite.test(
      "threesome",
      List.map<Nat,Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n + 1 }),
      M.equals(T.list(T.natTestable, ?(2, ?(3, ?(4, null)))))
    ),
  ]
);


let filter = Suite.suite(
  "filter",
  [
    Suite.test(
      "empty list",
      List.filter<Nat>(
       List.nil<Nat>(),
       func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "singleton",
      List.filter<Nat>(
        ?(3, null),
      func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "threesome",
      List.filter<Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, ?(2, null)))
    ),
    Suite.test(
      "foursome",
      List.filter<Nat>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, ?(2, ?(4, null))))
    ),
  ]
);

let partition = Suite.suite(
  "partition",
  [
    Suite.test(
      "empty list",
      List.partition<Nat>(
       List.nil<Nat>(),
       func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (null, null) : (List.List<Nat>, List.List<Nat>)))
    ),
    Suite.test(
      "singleton-false",
      List.partition<Nat>(
        ?(3, null),
      func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (null, ?(3, null)) : (List.List<Nat>, List.List<Nat>)))

    ),
    Suite.test(
      "singleton-true",
      List.partition<Nat>(
        ?(2, null),
      func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?(2, null), null) : (List.List<Nat>, List.List<Nat>)))
    ),
    Suite.test(
      "threesome",
      List.partition<Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?(2, null), ?(1, ?(3, null))) : (List.List<Nat>, List.List<Nat>)))
    ),
    Suite.test(
      "foursome",
      List.partition<Nat>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?(2, ?(4, null)),
                         ?(1, ?(3, null))) : (List.List<Nat>, List.List<Nat>)))
    ),
  ]
);


let mapFilter = Suite.suite(
  "mapFilter",
  [
    Suite.test(
      "empty list",
      List.mapFilter<Nat, Text>(
       List.nil<Nat>(),
       func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, null : List.List<Text>))
    ),
    Suite.test(
      "singleton",
      List.mapFilter<Nat, Text>(
        ?(3, null),
       func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, null : List.List<Text>))
    ),
    Suite.test(
      "threesome",
      List.mapFilter<Nat, Text>(
        ?(1, ?(2, ?(3, null))),
       func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, ?("2", null)))
    ),
    Suite.test(
      "foursome",
      List.mapFilter<Nat, Text>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, ?("2", ?("4", null))))
    ),
  ]
);


let flatten = Suite.suite(
  "flatten",
  [
    Suite.test(
      "small-list",
      List.flatten(
        List.tabulate<List.List<Nat>>(10, func i { List.tabulate<Nat>(10, func j { i * 10 + j })})
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(100, func i { i }))
      )
    ),
    Suite.test(
      "small-nulls",
      List.flatten(
        List.tabulate<List.List<Nat>>(10, func i { null : List.List<Nat> })
      ),
      M.equals(
        T.list(T.natTestable, null : List.List<Nat>)
      )
    ),
   Suite.test(
      "flatten",
      List.flatten<Int>(?(?(1, ?(2, ?(3, null))),
                          ?(null,
                            ?(?(1, null),
                              null)))),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten empty start",
      List.flatten<Int>(?(null,
                         ?(?(1, ?(2, (?(3, null)))),
                           ?(null,
                             ?(?(1, null),
                               null))))),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten empty end",
      List.flatten<Int>(?(?(1, ?(2, (?(3, null)))),
                          ?(null,
                            ?(?(1, null),
                              ?(null,
                                null))))),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten singleton",
      List.flatten<Int>(?(?(1, ?(2, (?(3, null)))),
                          null)),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, (?(3, null))))))
    ),
    Suite.test(
      "flatten singleton empty",
      List.flatten<Int>(?(null, null)),
      M.equals(T.list<Int>(T.intTestable, null))
    ),
    Suite.test(
      "flatten empty",
      List.flatten<Int>(null),
      M.equals(T.list<Int>(T.intTestable, null))
    ),
  ]
);

let make= Suite.suite(
  "make",
    Suite.test(
      "make",
      Array.make<Int>(0),
      M.equals(T.list<Int>(T.intTestable, ?(0, null)))
    ),
);

Suite.run(Suite.suite("List", [
  mapResult,
  replicate,
  tabulate,
  append,
  isNil,
  push,
  last,
  pop,
  size,
  get,
  reverse,
  iterate,
  map,
  filter,
  partition,
  mapFilter,
  flatten,
  make
  ]))

