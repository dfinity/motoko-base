// @testmode wasi

import Set "../src/PersistentOrderedSet";
import Nat "../src/Nat";
import Iter "../src/Iter";
import Debug "../src/Debug";
import Array "../src/Array";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let natSet = Set.SetOps<Nat>(Nat.compare);

class SetMatcher(expected : Set.Set<Nat>) : M.Matcher<Set.Set<Nat>> {
  public func describeMismatch(actual : Set.Set<Nat>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(natSet.vals(actual))) # " should be " # debug_show (Iter.toArray(natSet.vals(expected))))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    natSet.equals(actual, expected)
  }
};

object Random {
  var number = 4711;
  public func next() : Nat {
    number := (15485863 * number + 5) % 15485867;
    number
  };

  public func nextNat(range: (Nat, Nat)): Nat {
    let n = next();
    let v = n % (range.1 - range.0 + 1) + range.0;
    v
  };

  public func nextEntries(range: (Nat, Nat), size: Nat): [Nat] {
    Array.tabulate<Nat>(size, func(_ix) {
      let key = nextNat(range); key })
  }
};

func setGenN(samples_number: Nat, size: Nat, range: (Nat, Nat), chunkSize: Nat): Iter.Iter<[Set.Set<Nat>]> {
  object {
    var n = 0;
    public func next(): ?([Set.Set<Nat>])  {
      n += 1;
      if (n > samples_number) {
        null
      } else {
        ?Array.tabulate<Set.Set<Nat>>(chunkSize, func _i = natSet.fromIter(Random.nextEntries(range, size).vals()))
      }
    }
  }
};

func run_all_props(range: (Nat, Nat), size: Nat, set_samples: Nat, query_samples: Nat) {
  func prop(name: Text, f: Set.Set<Nat> -> Bool): Suite.Suite {
    var error_msg: Text = "";
    test(name, do {
      var error = true;
      label stop for(sets in setGenN(set_samples, size, range, 1)) {
        if (not f(sets[0])) {
          error_msg := "Property \"" # name # "\" failed\n";
          error_msg #= "\n s: " # debug_show(Iter.toArray(natSet.vals(sets[0])));
          break stop;
        }
      };
      error_msg
    }, M.describedAs(error_msg, M.equals(T.text(""))))
  };

  func prop2(name: Text, f: (Set.Set<Nat>, Set.Set<Nat>) -> Bool): Suite.Suite {
    var error_msg: Text = "";
    test(name, do {
      var error = true;
      label stop for(sets in setGenN(set_samples, size, range, 2)) {
        if (not f(sets[0], sets[1])) {
          error_msg := "Property \"" # name # "\" failed\n";
          error_msg #= "\n s1: " # debug_show(Iter.toArray(natSet.vals(sets[0])));
          error_msg #= "\n s2: " # debug_show(Iter.toArray(natSet.vals(sets[1])));
          break stop;
        }
      };
      error_msg
    }, M.describedAs(error_msg, M.equals(T.text(""))))
  };

  func prop3(name: Text, f: (Set.Set<Nat>, Set.Set<Nat>, Set.Set<Nat>) -> Bool): Suite.Suite {
    var error_msg: Text = "";
    test(name, do {
      var error = true;
      label stop for(sets in setGenN(set_samples, size, range, 3)) {
        if (not f(sets[0], sets[1], sets[2])) {
          error_msg := "Property \"" # name # "\" failed\n";
          error_msg #= "\n s1: " # debug_show(Iter.toArray(natSet.vals(sets[0])));
          error_msg #= "\n s2: " # debug_show(Iter.toArray(natSet.vals(sets[1])));
          error_msg #= "\n s3: " # debug_show(Iter.toArray(natSet.vals(sets[2])));
          break stop;
        }
      };
      error_msg
    }, M.describedAs(error_msg, M.equals(T.text(""))))
  };

  func prop_with_elem(name: Text, f: (Set.Set<Nat>, Nat) -> Bool): Suite.Suite {
    var error_msg: Text = "";
    test(name, do {
      label stop for(sets in setGenN(set_samples, size, range, 1)) {
        for (_query_ix in Iter.range(0, query_samples-1)) {
          let key = Random.nextNat(range);
          if (not f(sets[0], key)) {
            error_msg #= "Property \"" # name # "\" failed";
            error_msg #= "\n s: " # debug_show(Iter.toArray(natSet.vals(sets[0])));
            error_msg #= "\n e: " # debug_show(key);
            break stop;
          }
        }
      };
      error_msg
    }, M.describedAs(error_msg, M.equals(T.text(""))))
  };

  run(
    suite("Property tests",
   [
      suite("empty", [
        test("not contains(empty(), e)", label res : Bool {
          for (_query_ix in Iter.range(0, query_samples-1)) {
            let elem = Random.nextNat(range);
            if(natSet.contains(natSet.empty(), elem))
              break res(false);
          };
          true;
        }, M.equals(T.bool(true)))
      ]),

      suite("contains & put", [
        prop_with_elem("contains(put(s, e), e)", func (s, e) {
          natSet.contains(natSet.put(s, e), e)
        }),
        prop_with_elem("put(put(s, e), e) == put(s, e)", func (s, e) {
          let s1 = natSet.put(s, e);
          let s2 = natSet.put(natSet.put(s, e), e);
          SetMatcher(s1).matches(s2)
        }),
      ]),

      suite("min/max", [
        prop("max through fold", func (s) {
          let expected = natSet.foldLeft<?Nat>(s, null: ?Nat, func (v, _) = ?v );
          M.equals(T.optional(T.natTestable, expected)).matches(natSet.max(s));
        }),
        prop("min through fold", func (s) {
          let expected = natSet.foldRight<?Nat>(s, null: ?Nat, func (v, _) = ?v );
          M.equals(T.optional(T.natTestable, expected)).matches(natSet.min(s));
        }),
      ]),

      suite("all/some", [
        prop("all through fold", func(s) {
          let pred = func(k: Nat): Bool = (k <= range.1 - 2 and range.0 + 2 <= k);
          natSet.all(s, pred) == natSet.foldLeft<Bool>(s, true, func (v, acc) {acc and pred(v)})
        }),
        prop("some through fold", func(s) {
          let pred = func(k: Nat): Bool = (k >= range.1 - 1 or range.0 + 1 >= k);
          natSet.some(s, pred) == natSet.foldLeft<Bool>(s, false, func (v, acc) {acc or pred(v)})
        }),
      ]),

      suite("delete", [
        prop_with_elem("not contains(s, e) ==> delete(s, e) == s", func (s, e) {
          if (not natSet.contains(s, e)) {
            SetMatcher(s).matches(natSet.delete(s, e))
          } else { true }
        }),
        prop_with_elem("delete(put(s, e), e) == s", func (s, e) {
          if (not natSet.contains(s, e)) {
            SetMatcher(s).matches(natSet.delete(natSet.put(s, e), e))
          } else { true }
        }),
        prop_with_elem("delete(delete(s, e), e)) == delete(s, e)", func (s, e) {
          let s1 = natSet.delete(natSet.delete(s, e), e);
          let s2 = natSet.delete(s, e);
          SetMatcher(s2).matches(s1)
        })
      ]),

      suite("size", [
        prop_with_elem("size(put(s, e)) == size(s) + int(not contains(s, e))", func (s, e) {
          natSet.size(natSet.put(s, e)) == natSet.size(s) + (if (not natSet.contains(s, e)) {1} else {0})
        }),
        prop_with_elem("size(delete(s, e)) + int(contains(s, e)) == size(s)", func (s, e) {
          natSet.size(natSet.delete(s, e)) + (if (natSet.contains(s, e)) {1} else {0}) == natSet.size(s)
        })
      ]),

      suite("vals/valsRev", [
        prop("fromIter(vals(s)) == s", func (s) {
          SetMatcher(s).matches(natSet.fromIter(natSet.vals(s)))
        }),
        prop("fromIter(valsRev(s)) == s", func (s) {
          SetMatcher(s).matches(natSet.fromIter(natSet.valsRev(s)))
        }),
        prop("toArray(vals(s)).reverse() == toArray(valsRev(s))", func (s) {
          let a = Array.reverse(Iter.toArray(natSet.vals(s)));
          let b = Iter.toArray(natSet.valsRev(s));
          M.equals(T.array<Nat>(T.natTestable, a)).matches(b)
        }),
      ]),

      suite("mapFilter", [
        prop_with_elem("not contains(mapFilter(s, (!=e)), e)", func (s, e) {
          not natSet.contains(natSet.mapFilter<Nat>(s,
          func (ei) { if (ei != e) {?ei} else {null}}), e)
        }),
        prop_with_elem("contains(mapFilter(put(s, e), (==e)), e)", func (s, e) {
          natSet.contains(natSet.mapFilter<Nat>(natSet.put(s, e),
          func (ei) { if (ei == e) {?ei} else {null}}), e)
        })
      ]),

      suite("map", [
        prop("map(s, id) == s", func (s) {
          SetMatcher(s).matches(natSet.map<Nat>(s, func (e) {e}))
        })
      ]),

      suite("set operations", [
        prop("isSubset(s, s)", func (s) {
          natSet.isSubset(s, s)
        }),
        prop("isSubset(empty(), s)", func (s) {
          natSet.isSubset(natSet.empty(), s)
        }),
        prop_with_elem("isSubset(delete(s, e), s)", func (s, e) {
          natSet.isSubset(natSet.delete(s, e), s)
        }),
        prop_with_elem("contains(s, e) ==> not isSubset(s, delete(s, e))", func (s, e) {
          if (natSet.contains(s, e)) {
            not natSet.isSubset(s, natSet.delete(s, e))
          } else { true }
        }),
        prop_with_elem("isSubset(s, put(s, e))", func (s, e) {
          natSet.isSubset(s, natSet.put(s, e))
        }),
        prop_with_elem("not contains(s, e) ==> not isSubset(put(s, e), s)", func (s, e) {
          if (not natSet.contains(s, e)) {
            not natSet.isSubset(natSet.put(s, e), s)
          } else { true }
        }),
        prop("intersect(empty(), s) == empty()", func (s) {
          SetMatcher(natSet.empty()).matches(natSet.intersect(natSet.empty(), s))
        }),
        prop("intersect(s, empty()) == empty()", func (s) {
          SetMatcher(natSet.empty()).matches(natSet.intersect(s, natSet.empty()))
        }),
        prop("union(s, empty()) == s", func (s) {
          SetMatcher(s).matches(natSet.union(s, natSet.empty()))
        }),
        prop("union(empty(), s) == s", func (s) {
          SetMatcher(s).matches(natSet.union(natSet.empty(), s))
        }),
        prop("diff(empty(), s) == empty()", func (s) {
          SetMatcher(natSet.empty()).matches(natSet.diff(natSet.empty(), s))
        }),
        prop("diff(s, empty()) == s", func (s) {
          SetMatcher(s).matches(natSet.diff(s, natSet.empty()))
        }),
        prop("intersect(s, s) == s", func (s) {
          SetMatcher(s).matches(natSet.intersect(s, s))
        }),
        prop("union(s, s) == s", func (s) {
          SetMatcher(s).matches(natSet.union(s, s))
        }),
        prop("diff(s, s) == empty()", func (s) {
          SetMatcher(natSet.empty()).matches(natSet.diff(s, s))
        }),
        prop2("intersect(s1, s2) == intersect(s2, s1)", func (s1, s2) {
          SetMatcher(natSet.intersect(s1, s2)).matches(natSet.intersect(s2, s1))
        }),
        prop2("union(s1, s2) == union(s2, s1)", func (s1, s2) {
          SetMatcher(natSet.union(s1, s2)).matches(natSet.union(s2, s1))
        }),
        prop2("isSubset(diff(s1, s2), s1)", func (s1, s2) {
          natSet.isSubset(natSet.diff(s1, s2), s1)
        }),
        prop2("intersect(diff(s1, s2), s2) == empty()", func (s1, s2) {
          SetMatcher(natSet.intersect(natSet.diff(s1, s2), s2)).matches(natSet.empty())
        }),
        prop3("union(union(s1, s2), s3) == union(s1, union(s2, s3))", func (s1, s2, s3) {
          SetMatcher(natSet.union(natSet.union(s1, s2), s3)).matches(natSet.union(s1, natSet.union(s2, s3)))
        }),
        prop3("intersect(intersect(s1, s2), s3) == intersect(s1, intersect(s2, s3))", func (s1, s2, s3) {
          SetMatcher(natSet.intersect(natSet.intersect(s1, s2), s3)).matches(natSet.intersect(s1, natSet.intersect(s2, s3)))
        }),
        prop3("union(s1, intersect(s2, s3)) == intersect(union(s1, s2), union(s1, s3))", func (s1, s2, s3) {
          SetMatcher(natSet.union(s1, natSet.intersect(s2, s3))).matches(
            natSet.intersect(natSet.union(s1, s2), natSet.union(s1, s3)))
        }),
        prop3("intersect(s1, union(s2, s3)) == union(intersect(s1, s2), intersect(s1, s3))", func (s1, s2, s3) {
          SetMatcher(natSet.intersect(s1, natSet.union(s2, s3))).matches(
            natSet.union(natSet.intersect(s1, s2), natSet.intersect(s1, s3)))
        }),
      ]),
    ]))
};

run_all_props((1, 3), 0, 1, 10);
run_all_props((1, 5), 5, 100, 100);
run_all_props((1, 10), 10, 100, 100);
run_all_props((1, 100), 20, 100, 100);
run_all_props((1, 1000), 100, 100, 100);
