import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Order "mo:base/Order";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

let { run; test; suite } = Suite;

func charT(c : Char) : T.TestableItem<Char> = {
  item = c;
  display = Text.fromChar;
  equals = Char.equal
};

func blobT(b : Blob) : T.TestableItem<Blob> = {
  item = b;
  display = func(b : Blob) : Text { debug_show (b) };
  equals = Blob.equal
};

func ordT(o : Order.Order) : T.TestableItem<Order.Order> = {
  item = o;
  display = func(o : Order.Order) : Text { debug_show (o) };
  equals = Order.equal
};

func optTextT(ot : ?Text) : T.TestableItem<?Text> = T.optional(T.textTestable, ot);

// TODO: generalize and move to Iter.mo
func iterT(c : [Char]) : T.TestableItem<Iter.Iter<Char>> = {
  item = c.vals();
  display = Text.fromIter; // not this will only print the remainder of cs1 below
  equals = func(cs1 : Iter.Iter<Char>, cs2 : Iter.Iter<Char>) : Bool {
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, null) return true;
        case (?c1, ?c2) if (c1 != c2) return false;
        case (_, _) return false
      }
    }
  }
};

// TODO: generalize and move to Iter.mo
func textIterT(c : [Text]) : T.TestableItem<Iter.Iter<Text>> = {
  item = c.vals();
  display = func(ts : Iter.Iter<Text>) : Text { Text.join(",", ts) };
  // not this will only print the remainder of cs1 below
  equals = func(ts1 : Iter.Iter<Text>, ts2 : Iter.Iter<Text>) : Bool {
    loop {
      switch (ts1.next(), ts2.next()) {
        case (null, null) return true;
        case (?t1, ?t2) if (t1 != t2) return false;
        case (_, _) return false
      }
    }
  }
};

run(
  suite(
    "size",
    [
      test(
        "size-0",
        Text.size(""),
        M.equals(T.nat 0)
      ),
      test(
        "size-1",
        Text.size("a"),
        M.equals(T.nat 1)
      ),
      test(
        "size-2",
        Text.size("abcdefghijklmnopqrstuvwxyz"),
        M.equals(T.nat 26)
      ),
      test(
        "size-3",
        Text.size("☃"),
        M.equals(T.nat 1)
      ),
      test(
        "size-4",
        Text.size("☃☃"),
        M.equals(T.nat 2)
      )
    ]
  )
);

run(
  suite(
    "toIter",
    [
      test(
        "toIter-0",
        Text.toIter(""),
        M.equals(iterT([]))
      ),
      test(
        "toIter-1",
        Text.toIter("a"),
        M.equals(iterT(['a']))
      ),
      test(
        "toIter-2",
        Text.toIter("abc"),
        M.equals(iterT(['a', 'b', 'c']))
      ),
      do {
        let a = Array.tabulate<Char>(1000, func i = Char.fromNat32(65 +% Nat32.fromIntWrap(i % 26)));
        test(
          "fromIter-2",
          Text.toIter(Text.join("", Array.map(a, Char.toText).vals())),
          M.equals(iterT a)
        )
      }
    ]
  )
);

run(
  suite(
    "fromIter",
    [
      test(
        "fromIter-0",
        Text.fromIter(([].vals())),
        M.equals(T.text(""))
      ),
      test(
        "fromIter-1",
        Text.fromIter((['a'].vals())),
        M.equals(T.text "a")
      ),
      test(
        "fromIter-2",
        Text.fromIter((['a', 'b', 'c'].vals())),
        M.equals(T.text "abc")
      ),
      do {
        let a = Array.tabulate<Char>(1000, func i = Char.fromNat32(65 +% Nat32.fromIntWrap(i % 26)));
        test(
          "fromIter-3",
          Text.fromIter(a.vals()),
          M.equals(T.text(Text.join("", Array.map(a, Char.toText).vals())))
        )
      }
    ]
  )
);

run(
  suite(
    "concat",
    [
      test(
        "concat-0",
        Text.concat("", ""),
        M.equals(T.text(""))
      ),
      test(
        "concat-1",
        Text.concat("", "b"),
        M.equals(T.text "b")
      ),
      test(
        "concat-2",
        Text.concat("a", "b"),
        M.equals(T.text "ab")
      ),
      test(
        "concat-3",
        Text.concat("abcdefghijklmno", "pqrstuvwxyz"),
        M.equals(T.text "abcdefghijklmnopqrstuvwxyz")
      )
    ]
  )
);

run(
  suite(
    "join",
    [
      test(
        "join-0",
        Text.join("", (["", ""].vals())),
        M.equals(T.text(""))
      ),
      test(
        "join-1",
        Text.join("", (["", "b"].vals())),
        M.equals(T.text "b")
      ),
      test(
        "join-2",
        Text.join("", (["a", "bb", "ccc", "dddd"].vals())),
        M.equals(T.text "abbcccdddd")
      ),
      do {
        let a = Array.tabulate<Char>(1000, func i = Char.fromNat32(65 +% Nat32.fromIntWrap(i % 26)));
        test(
          "join-3",
          Text.join("", Array.map(a, Char.toText).vals()),
          M.equals(T.text(Text.fromIter(a.vals())))
        )
      },
      test(
        "join-4",
        Text.join("", ([].vals())),
        M.equals(T.text "")
      ),
      test(
        "join-5",
        Text.join("", (["aaa"].vals())),
        M.equals(T.text "aaa")
      )
    ]
  )
);

run(
  suite(
    "join",
    [
      test(
        "join-0",
        Text.join(",", (["", ""].vals())),
        M.equals(T.text(","))
      ),
      test(
        "join-1",
        Text.join(",", (["", "b"].vals())),
        M.equals(T.text ",b")
      ),
      test(
        "join-2",
        Text.join(",", (["a", "bb", "ccc", "dddd"].vals())),
        M.equals(T.text "a,bb,ccc,dddd")
      ),
      do {
        let a = Array.tabulate<Char>(1000, func i = Char.fromNat32(65 +% Nat32.fromIntWrap(i % 26)));
        test(
          "join-3",
          Text.join("", Array.map(a, Char.toText).vals()),
          M.equals(T.text(Text.fromIter(a.vals())))
        )
      },
      test(
        "join-4",
        Text.join(",", ([].vals())),
        M.equals(T.text "")
      ),
      test(
        "join-5",
        Text.join(",", (["aaa"].vals())),
        M.equals(T.text "aaa")
      )
    ]
  )
);

run(
  suite(
    "split",
    [
      test(
        "split-char-empty",
        Text.split("", #char ';'),
        M.equals(textIterT([]))
      ),
      test(
        "split-char-none",
        Text.split("abc", #char ';'),
        M.equals(textIterT(["abc"]))
      ),
      test(
        "split-char-empties2",
        Text.split(";", #char ';'),
        M.equals(textIterT(["", ""]))
      ),
      test(
        "split-char-empties3",
        Text.split(";;", #char ';'),
        M.equals(textIterT(["", "", ""]))
      ),
      test(
        "split-char-singles",
        Text.split("a;b;;c;;;d", #char ';'),
        M.equals(textIterT(["a", "b", "", "c", "", "", "d"]))
      ),
      test(
        "split-char-mixed",
        Text.split("a;;;ab;;abc;", #char ';'),
        M.equals(textIterT(["a", "", "", "ab", "", "abc", ""]))
      ),
      do {
        let a = Array.tabulate<Text>(1000, func _ = "abc");
        let t = Text.join(";", a.vals());
        test(
          "split-char-large",
          Text.split(t, #char ';'),
          M.equals(textIterT a)
        )
      },
      do {
        let a = Array.tabulate<Text>(100000, func _ = "abc");
        let t = Text.join(";", a.vals());
        test(
          "split-char-very-large",
          Text.split(t, #char ';'),
          M.equals(textIterT a)
        )
      }
    ]
  )
);

run(
  suite(
    "substring",
    [
      test(
        "zero length",
        Text.substring("abc", 0, 0),
        M.equals(T.text "")
      ),
      test(
        "length of 1 from start",
        Text.substring("abc", 0, 1),
        M.equals(T.text "a")
      ),
      test(
        "length of 2 from start",
        Text.substring("abc", 0, 2),
        M.equals(T.text "ab")
      ),
      test(
        "length of 3 from start",
        Text.substring("abc", 0, 3),
        M.equals(T.text "abc")
      ),
      test(
        "length of 1 from middle",
        Text.substring("abc", 1, 1),
        M.equals(T.text "b")
      ),
      test(
        "length of 2 from middle",
        Text.substring("abc", 1, 2),
        M.equals(T.text "bc")
      ),
      test(
        "length of 1 from end",
        Text.substring("abc", 2, 1),
        M.equals(T.text "c")
      ),
      test(
        "length of 2 from end",
        Text.substring("abc", 2, 2),
        M.equals(T.text "c")
      ),
      test(
        "should handle negative start",
        Text.substring("abc", -1, 1),
        M.equals(T.text "c")
      ),
      test(
        "should handle negative length",
        Text.substring("abc", 0, -1),
        M.equals(T.text "")
      ),
      test(
        "should handle negative start and length",
        Text.substring("abc", -1, -1),
        M.equals(T.text "")
      ),
      test(
        "should handle start past end",
        Text.substring("abc", 3, 1),
        M.equals(T.text "")
      )
    ]
  )
);

do {
  let pat : Text.Pattern = #predicate(func(c : Char) : Bool { c == ';' or c == '!' });
  run(
    suite(
      "split",
      [
        test(
          "split-pred-empty",
          Text.split("", pat),
          M.equals(textIterT([]))
        ),
        test(
          "split-pred-none",
          Text.split("abc", pat),
          M.equals(textIterT(["abc"]))
        ),
        test(
          "split-pred-empties2",
          Text.split(";", pat),
          M.equals(textIterT(["", ""]))
        ),
        test(
          "split-pred-empties3",
          Text.split(";!", pat),
          M.equals(textIterT(["", "", ""]))
        ),
        test(
          "split-pred-singles",
          Text.split("a;b;!c!;;d", pat),
          M.equals(textIterT(["a", "b", "", "c", "", "", "d"]))
        ),
        test(
          "split-pred-mixed",
          Text.split("a;!;ab;!abc;", pat),
          M.equals(textIterT(["a", "", "", "ab", "", "abc", ""]))
        ),
        do {
          let a = Array.tabulate<Text>(1000, func _ = "abc");
          let t = Text.join(";", a.vals());
          test(
            "split-pred-large",
            Text.split(t, pat),
            M.equals(textIterT a)
          )
        },
        do {
          let a = Array.tabulate<Text>(10000, func _ = "abc");
          let t = Text.join(";", a.vals());
          test(
            "split-pred-very-large",
            Text.split(t, pat),
            M.equals(textIterT a)
          )
        }
      ]
    )
  )
};

do {
  let pat : Text.Pattern = #text "PAT";
  run(
    suite(
      "split",
      [
        test(
          "split-pat-empty",
          Text.split("", pat),
          M.equals(textIterT([]))
        ),
        test(
          "split-pat-none",
          Text.split("abc", pat),
          M.equals(textIterT(["abc"]))
        ),
        test(
          "split-pat-empties2",
          Text.split("PAT", pat),
          M.equals(textIterT(["", ""]))
        ),
        test(
          "split-pat-empties3",
          Text.split("PATPAT", pat),
          M.equals(textIterT(["", "", ""]))
        ),
        test(
          "split-pat-singles",
          Text.split("aPATbPATPATcPATPATPATd", pat),
          M.equals(textIterT(["a", "b", "", "c", "", "", "d"]))
        ),
        test(
          "split-pat-mixed",
          Text.split("aPATPATPATabPATPATabcPAT", pat),
          M.equals(textIterT(["a", "", "", "ab", "", "abc", ""]))
        ),
        do {
          let a = Array.tabulate<Text>(1000, func _ = "abc");
          let t = Text.join("PAT", a.vals());
          test(
            "split-pat-large",
            Text.split(t, pat),
            M.equals(textIterT a)
          )
        },
        do {
          let a = Array.tabulate<Text>(10000, func _ = "abc");
          let t = Text.join("PAT", a.vals());
          test(
            "split-pat-very-large",
            Text.split(t, pat),
            M.equals(textIterT a)
          )
        }
      ]
    )
  )
};

run(
  suite(
    "tokens",
    [
      test(
        "tokens-char-empty",
        Text.tokens("", #char ';'),
        M.equals(textIterT([]))
      ),
      test(
        "tokens-char-none",
        Text.tokens("abc", #char ';'),
        M.equals(textIterT(["abc"]))
      ),
      test(
        "tokens-char-empties2",
        Text.tokens(";", #char ';'),
        M.equals(textIterT([]))
      ),
      test(
        "tokens-char-empties3",
        Text.tokens(";;", #char ';'),
        M.equals(textIterT([]))
      ),
      test(
        "tokens-char-singles",
        Text.tokens("a;b;;c;;;d", #char ';'),
        M.equals(textIterT(["a", "b", "c", "d"]))
      ),
      test(
        "tokens-char-mixed",
        Text.tokens("a;;;ab;;abc;", #char ';'),
        M.equals(textIterT(["a", "ab", "abc"]))
      ),
      do {
        let a = Array.tabulate<Text>(1000, func _ = "abc");
        let t = Text.join(";;", a.vals());
        test(
          "tokens-char-large",
          Text.tokens(t, #char ';'),
          M.equals(textIterT a)
        )
      },
      do {
        let a = Array.tabulate<Text>(100000, func _ = "abc");
        let t = Text.join(";;", a.vals());
        test(
          "tokens-char-very-large",
          Text.tokens(t, #char ';'),
          M.equals(textIterT a)
        )
      }
    ]
  )
);

run(
  suite(
    "startsWith",
    [
      test(
        "startsWith-both-empty",
        Text.startsWith("", #text ""),
        M.equals(T.bool true)
      ),
      test(
        "startsWith-empty-text",
        Text.startsWith("", #text "abc"),
        M.equals(T.bool false)
      ),
      test(
        "startsWith-empty-pat",
        Text.startsWith("abc", #text ""),
        M.equals(T.bool true)
      ),
      test(
        "startsWith-1",
        Text.startsWith("a", #text "b"),
        M.equals(T.bool false)
      ),
      test(
        "startsWith-2",
        Text.startsWith("abc", #text "abc"),
        M.equals(T.bool true)
      ),
      test(
        "startsWith-3",
        Text.startsWith("abcd", #text "ab"),
        M.equals(T.bool true)
      ),
      test(
        "startsWith-4",
        Text.startsWith("abcdefghijklmnopqrstuvwxyz", #text "abcdefghijklmno"),
        M.equals(T.bool true)
      )
    ]
  )
);

run(
  suite(
    "endsWith",
    [
      test(
        "endsWith-both-empty",
        Text.endsWith("", #text ""),
        M.equals(T.bool true)
      ),
      test(
        "endsWith-empty-text",
        Text.endsWith("", #text "abc"),
        M.equals(T.bool false)
      ),
      test(
        "endsWith-empty-pat",
        Text.endsWith("abc", #text ""),
        M.equals(T.bool true)
      ),
      test(
        "endsWith-1",
        Text.endsWith("a", #text "b"),
        M.equals(T.bool false)
      ),
      test(
        "endsWith-2",
        Text.endsWith("abc", #text "abc"),
        M.equals(T.bool true)
      ),
      test(
        "endsWith-3",
        Text.endsWith("abcd", #text "cd"),
        M.equals(T.bool true)
      ),
      test(
        "endsWith-4",
        Text.endsWith("abcdefghijklmnopqrstuvwxyz", #text "pqrstuvwxyz"),
        M.equals(T.bool true)
      )
    ]
  )
);

run(
  suite(
    "contains",
    [
      test(
        "contains-start",
        Text.contains("abcd", #text "ab"),
        M.equals(T.bool true)
      ),
      test(
        "contains-empty",
        Text.contains("abc", #text ""),
        M.equals(T.bool true)
      ),
      test(
        "contains-false",
        Text.contains("ab", #text "bc"),
        M.equals(T.bool false)
      ),
      test(
        "contains-exact",
        Text.contains("abc", #text "abc"),
        M.equals(T.bool true)
      ),
      test(
        "contains-within",
        Text.contains("abcdefghijklmnopqrstuvwxyz", #text "qrst"),
        M.equals(T.bool true)
      ),
      test(
        "contains-front",
        Text.contains("abcdefghijklmnopqrstuvwxyz", #text "abcdefg"),
        M.equals(T.bool true)
      ),
      test(
        "contains-end",
        Text.contains("abcdefghijklmnopqrstuvwxyz", #text "xyz"),
        M.equals(T.bool true)
      ),
      test(
        "contains-false",
        Text.contains("abcdefghijklmnopqrstuvwxyz", #text "lkj"),
        M.equals(T.bool false)
      ),
      test(
        "contains-empty-nonempty",
        Text.contains("", #text "xyz"),
        M.equals(T.bool false)
      )
    ]
  )
);

run(
  suite(
    "replace",
    [
      test(
        "replace-start",
        Text.replace("abcd", #text "ab", "AB"),
        M.equals(T.text "ABcd")
      ),
      test(
        "replace-empty",
        Text.replace("abc", #text "", "AB"),
        M.equals(T.text "ABaABbABcAB")
      ),
      test(
        "replace-none",
        Text.replace("ab", #text "bc", "AB"),
        M.equals(T.text "ab")
      ),
      test(
        "replace-exact",
        Text.replace("ab", #text "ab", "AB"),
        M.equals(T.text "AB")
      ),
      test(
        "replace-several",
        Text.replace("abcdabghijabmnopqrstuabwxab", #text "ab", "AB"),
        M.equals(T.text "ABcdABghijABmnopqrstuABwxAB")
      ),
      test(
        "replace-delete",
        Text.replace("abcdabghijabmnopqrstuabwxab", #text "ab", ""),
        M.equals(T.text "cdghijmnopqrstuwx")
      ),
      test(
        "replace-pred",
        Text.replace("abcdefghijklmnopqrstuvwxyz", #predicate(func(c : Char) : Bool { c < 'm' }), ""),
        M.equals(T.text "mnopqrstuvwxyz")
      ),
      test(
        "replace-partial",
        Text.replace("123", #text "124", "ABC"),
        M.equals(T.text "123")
      ),
      test(
        "replace-partial-2",
        Text.replace("12341235124", #text "124", "ABC"),
        M.equals(T.text "12341235ABC")
      ),
      test(
        "replace-partial-3",
        Text.replace("111234123511124", #text "124", "ABC"),
        M.equals(T.text "111234123511ABC")
      )
    ]
  )
);

run(
  suite(
    "stripStart",
    [
      test(
        "stripStart-none",
        Text.stripStart("cd", #text "ab"),
        M.equals(optTextT(null))
      ),
      test(
        "stripStart-one",
        Text.stripStart("abcd", #text "ab"),
        M.equals(optTextT(?"cd"))
      ),
      test(
        "stripStart-two",
        Text.stripStart("abababcd", #text "ab"),
        M.equals(optTextT(?"ababcd"))
      ),
      test(
        "stripStart-only",
        Text.stripStart("ababababab", #text "ab"),
        M.equals(optTextT(?"abababab"))
      ),
      test(
        "stripStart-empty",
        Text.stripStart("abcdef", #text ""),
        M.equals(optTextT(?"abcdef"))
      ),
      test(
        "stripStart-tooshort",
        Text.stripStart("abcdef", #text "abcdefg"),
        M.equals(optTextT(null))
      )
    ]
  )
);

run(
  suite(
    "stripEnd",
    [
      test(
        "stripEnd-exact",
        Text.stripEnd("cd", #text "cd"),
        M.equals(optTextT(?""))
      ),
      test(
        "stripEnd-one",
        Text.stripEnd("abcd", #text "cd"),
        M.equals(optTextT(?"ab"))
      ),
      test(
        "stripEnd-three",
        Text.stripEnd("abcdcdcd", #text "cd"),
        M.equals(optTextT(?"abcdcd"))
      ),
      test(
        "stripEnd-many",
        Text.stripEnd("cdcdcdcdcdcdcd", #text "cd"),
        M.equals(optTextT(?"cdcdcdcdcdcd"))
      ),
      test(
        "stripEnd-empty-pat",
        Text.stripEnd("abcdef", #text ""),
        M.equals(optTextT(?"abcdef"))
      ),
      test(
        "stripEnd-empty",
        Text.stripEnd("", #text "cd"),
        M.equals(optTextT null)
      ),
      test(
        "stripEnd-tooshort",
        Text.stripEnd("bcdef", #text "abcdef"),
        M.equals(optTextT null)
      )
    ]
  )
);

run(
  suite(
    "trimStart",
    [
      test(
        "trimStart-none",
        Text.trimStart("cd", #text "ab"),
        M.equals(T.text "cd")
      ),
      test(
        "trimStart-one",
        Text.trimStart("abcd", #text "ab"),
        M.equals(T.text "cd")
      ),
      test(
        "trimStart-two",
        Text.trimStart("abababcd", #text "ab"),
        M.equals(T.text "cd")
      ),
      test(
        "trimStart-only",
        Text.trimStart("ababababab", #text "ab"),
        M.equals(T.text "")
      ),
      test(
        "trimStart-empty",
        Text.trimStart("abcdef", #text ""),
        M.equals(T.text "abcdef")
      )
    ]
  )
);

run(
  suite(
    "trimEnd",
    [
      test(
        "trimEnd-exact",
        Text.trimEnd("cd", #text "cd"),
        M.equals(T.text "")
      ),
      test(
        "trimEnd-one",
        Text.trimEnd("abcd", #text "cd"),
        M.equals(T.text "ab")
      ),
      test(
        "trimEnd-three",
        Text.trimEnd("abcdcdcd", #text "cd"),
        M.equals(T.text "ab")
      ),
      test(
        "trimEnd-many",
        Text.trimEnd("cdcdcdcdcdcdcd", #text "cd"),
        M.equals(T.text "")
      ),
      test(
        "trimEnd-empty-pat",
        Text.trimEnd("abcdef", #text ""),
        M.equals(T.text "abcdef")
      ),
      test(
        "trimEnd-empty",
        Text.trimEnd("", #text "cd"),
        M.equals(T.text "")
      )
    ]
  )
);

run(
  suite(
    "trim",
    [
      test(
        "trim-exact",
        Text.trim("cd", #text "cd"),
        M.equals(T.text "")
      ),
      test(
        "trim-one",
        Text.trim("cdabcd", #text "cd"),
        M.equals(T.text "ab")
      ),
      test(
        "trim-three",
        Text.trim("cdcdcdabcdcdcd", #text "cd"),
        M.equals(T.text "ab")
      ),
      test(
        "trim-many",
        Text.trim("cdcdcdcdcdcdcd", #text "cd"),
        M.equals(T.text "")
      ),
      test(
        "trim-empty-pat",
        Text.trim("abcdef", #text ""),
        M.equals(T.text "abcdef")
      ),
      test(
        "trim-empty",
        Text.trim("", #text "cd"),
        M.equals(T.text "")
      )
    ]
  )
);

run(
  suite(
    "compare",
    [
      test(
        "compare-empties",
        Text.compare("", ""),
        M.equals(ordT(#equal))
      ),
      test(
        "compare-empty-nonempty",
        Text.compare("", "a"),
        M.equals(ordT(#less))
      ),
      test(
        "compare-nonempty-empty",
        Text.compare("a", ""),
        M.equals(ordT(#greater))
      ),
      test(
        "compare-a-a",
        Text.compare("a", "a"),
        M.equals(ordT(#equal))
      ),
      test(
        "compare-a-b",
        Text.compare("a", "b"),
        M.equals(ordT(#less))
      ),
      test(
        "compare-b-a",
        Text.compare("b", "a"),
        M.equals(ordT(#greater))
      )
    ]
  )
);

do {
  let cmp = Char.compare;
  run(
    suite(
      "compareWith",
      [
        test(
          "compareWith-empties",
          Text.compareWith("", "", cmp),
          M.equals(ordT(#equal))
        ),
        test(
          "compareWith-empty",
          Text.compareWith("abc", "", cmp),
          M.equals(ordT(#greater))
        ),
        test(
          "compareWith-equal-nonempty",
          Text.compareWith("abc", "abc", cmp),
          M.equals(ordT(#equal))
        ),
        test(
          "compareWith-less-nonempty",
          Text.compareWith("abc", "abd", cmp),
          M.equals(ordT(#less))
        ),
        test(
          "compareWith-less-nonprefix",
          Text.compareWith("abc", "abcd", cmp),
          M.equals(ordT(#less))
        ),
        test(
          "compareWith-empty-nonempty",
          Text.compareWith("", "abcd", cmp),
          M.equals(ordT(#less))
        ),
        test(
          "compareWith-prefix",
          Text.compareWith("abcd", "abc", cmp),
          M.equals(ordT(#greater))
        )
      ]
    )
  )
};

do {
  let cmp = func(c1 : Char, c2 : Char) : Order.Order {
    switch (Char.compare(c1, c2)) {
      case (#less) #greater;
      case (#equal) #equal;
      case (#greater) #less
    }
  };
  run(
    suite(
      "compareWith-flip",
      [
        test(
          "compareWith-flip-greater",
          Text.compareWith("abc", "abd", cmp),
          M.equals(ordT(#greater))
        ),
        test(
          "compareWith-flip-less",
          Text.compareWith("abd", "abc", cmp),
          M.equals(ordT(#less))
        )
      ]
    )
  )
};

run(
  suite(
    "utf8",
    [
      test(
        "encode-literal",
        Text.encodeUtf8("FooBär☃"),
        M.equals(blobT("FooBär☃"))
      ),
      test(
        "encode-concat",
        Text.encodeUtf8("Foo" # "Bär" # "☃"),
        M.equals(blobT("FooBär☃"))
      ),
      test(
        "decode-literal-good",
        Text.decodeUtf8("FooBär☃"),
        M.equals(optTextT(?"FooBär☃"))
      ),
      test(
        "decode-literal-bad1",
        Text.decodeUtf8("\FF"),
        M.equals(optTextT(null))
      ),
      test(
        "decode-literal-bad2",
        Text.decodeUtf8("\D8\00t d"),
        M.equals(optTextT(null))
      )
    ]
  )
)
