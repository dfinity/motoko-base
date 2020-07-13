import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Order "mo:base/Order";
import Array "mo:base/Array";
import Word32 "mo:base/Word32";

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

let {run;test;suite} = Suite;

func charT(c : Char): T.TestableItem<Char> = {
  item = c;
  display = Text.fromChar;
  equals = Char.equal;
};


func ordT(o : Order.Order): T.TestableItem<Order.Order> = {
  item = o;
  display = func (o : Order.Order) : Text { debug_show(o) };
  equals = Order.equal;
};

func optTextT(ot : ?Text): T.TestableItem<?Text> = T.optional(T.textTestable, ot);

// TODO: generalize and move to Iter.mo
func iterT(c : [Char]): T.TestableItem<Iter.Iter<Char>> = {
  item = c.vals();
  display = Text.fromIter; // not this will only print the remainder of cs1 below
  equals = func (cs1 : Iter.Iter<Char>, cs2 : Iter.Iter<Char>) : Bool {
     loop {
       switch (cs1.next(), cs2.next()) {
         case (null,null) return true;
         case (? c1, ? c2)
           if (c1 != c2) return false;
         case (_, _) return false;
       }
     }
  };
};

// TODO: generalize and move to Iter.mo
func textIterT(c : [Text]): T.TestableItem<Iter.Iter<Text>> = {
  item = c.vals();
  display = func (ts: Iter.Iter<Text>) : Text { Text.joinWith(",", ts) };
     // not this will only print the remainder of cs1 below
  equals = func (ts1 : Iter.Iter<Text>, ts2 : Iter.Iter<Text>) : Bool {
     loop {
       switch (ts1.next(), ts2.next()) {
         case (null,null) return true;
         case (? t1, ? t2)
           if (t1 != t2) return false;
         case (_, _) return false;
       }
     }
  };
};


run(suite("size",
[
 test(
   "size-0",
   Text.size(""),
   M.equals(T.nat 0)),
 test(
   "size-1",
   Text.size("a"),
   M.equals(T.nat 1)),
 test(
   "size-2",
   Text.size("abcdefghijklmnopqrstuvwxyz"),
   M.equals(T.nat 26)),
 test(
   "size-3",
   Text.size("☃"),
   M.equals(T.nat 1)),
 test(
   "size-4",
   Text.size("☃☃"),
   M.equals(T.nat 2)),
]));


run(suite("size",
[
 test(
   "size-0",
   Text.size(""),
   M.equals(T.nat 0)),
 test(
   "size-1",
   Text.size("a"),
   M.equals(T.nat 1)),
 test(
   "size-2",
   Text.size("abcdefghijklmnopqrstuvwxyz"),
   M.equals(T.nat 26)),
 test(
   "size-3",
   Text.size("☃"),
   M.equals(T.nat 1)),
 test(
   "size-4",
   Text.size("☃☃"),
   M.equals(T.nat 2)),
]));


run(suite("sub",
[
 test(
   "sub-0",
   Text.sub("abcdefghijklmnopqrstuvwxyz", 0),
   M.equals(charT 'a')),
 test(
   "sub-1",
   Text.sub("abcdefghijklmnopqrstuvwxyz", 1),
   M.equals(charT 'b')),
 test(
   "sub-2",
   Text.sub("abcdefghijklmnopqrstuvwxyz", 25),
   M.equals(charT 'z')),
]));


run(suite("extract",
[
 test(
   "extract-0",
   Text.extract("", 0, ? 0),
   M.equals(T.text "")),
 test(
   "extract-1",
   Text.extract("abcdefghijklmnopqrstuvwxyz", 0, ? 3),
   M.equals(T.text "abc")),
 test(
   "extract-2",
   Text.extract("abcdefghijklmnopqrstuvwxyz", 23, ? 3),
   M.equals(T.text "xyz")),
 test(
   "extract-3",
   Text.extract("abcdefghijklmnopqrstuvwxyz", 0, ? 26),
   M.equals(T.text "abcdefghijklmnopqrstuvwxyz")),
 test(
   "extract-3",
   Text.extract("a☃c", 1, ? 2),
   M.equals(T.text "☃c")),
]));


run(suite("subtext",
[
 test(
   "subtext-0",
   Text.subtext("", 0, 0),
   M.equals(T.text "")),
 test(
   "subtext-1",
   Text.subtext("abcdefghijklmnopqrstuvwxyz", 0, 3),
   M.equals(T.text "abc")),
 test(
   "subtext-2",
   Text.subtext("abcdefghijklmnopqrstuvwxyz", 23, 3),
   M.equals(T.text "xyz")),
 test(
   "subtext-3",
   Text.subtext("abcdefghijklmnopqrstuvwxyz", 0, 26),
   M.equals(T.text "abcdefghijklmnopqrstuvwxyz")),
 test(
   "subtext-3",
   Text.subtext("a☃c", 1, 2),
   M.equals(T.text "☃c")),
]));


run(suite("toIter",
[
 test(
   "toIter-0",
   Text.toIter(""),
   M.equals(iterT([]))),
 test(
   "toIter-1",
   Text.toIter("a"),
   M.equals(iterT (['a']))),
 test(
   "toIter-2",
   Text.toIter("abc"),
   M.equals(iterT (['a','b','c']))),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   test(
   "fromIter-2",
   Text.toIter(Text.join(Array.map(a, Char.toText).vals())),
   M.equals(iterT a))
 },
]));

run(suite("fromIter",
[
 test(
   "fromIter-0",
   Text.fromIter(([].vals())),
   M.equals(T.text(""))),
 test(
   "fromIter-1",
   Text.fromIter((['a'].vals())),
   M.equals(T.text "a")),
 test(
   "fromIter-2",
   Text.fromIter((['a', 'b', 'c'].vals())),
   M.equals(T.text "abc")),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   test(
   "fromIter-3",
   Text.fromIter(a.vals()),
   M.equals(T.text (Text.join(Array.map(a, Char.toText).vals()))))
 },
]));


run(suite("concat",
[
 test(
   "concat-0",
   Text.concat("",""),
   M.equals(T.text(""))),
 test(
   "concat-1",
   Text.concat("","b"),
   M.equals(T.text "b")),
 test(
   "concat-2",
   Text.concat("a","b"),
   M.equals(T.text "ab")),
 test(
   "concat-3",
   Text.concat("abcdefghijklmno","pqrstuvwxyz"),
   M.equals(T.text "abcdefghijklmnopqrstuvwxyz")),
]));

run(suite("join",
[
 test(
   "join-0",
   Text.join((["",""].vals())),
   M.equals(T.text(""))),
 test(
   "join-1",
   Text.join((["","b"].vals())),
   M.equals(T.text "b")),
 test(
   "join-2",
   Text.join((["a","bb","ccc","dddd"].vals())),
   M.equals(T.text "abbcccdddd")),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   test(
   "join-3",
   Text.join(Array.map(a, Char.toText).vals()),
   M.equals(T.text (Text.fromIter(a.vals()))))
 },
 test(
   "join-4",
   Text.join(([].vals())),
   M.equals(T.text "")),
 test(
   "join-5",
   Text.join((["aaa"].vals())),
   M.equals(T.text "aaa")),
]));

run(suite("joinWith",
[
 test(
   "joinWith-0",
   Text.joinWith(",", (["",""].vals())),
   M.equals(T.text(","))),
 test(
   "joinWith-1",
   Text.joinWith(",", (["","b"].vals())),
   M.equals(T.text ",b")),
 test(
   "joinWith-2",
   Text.joinWith(",", (["a","bb","ccc","dddd"].vals())),
   M.equals(T.text "a,bb,ccc,dddd")),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   test(
   "joinWith-3",
   Text.joinWith("", Array.map(a, Char.toText).vals()),
   M.equals(T.text (Text.fromIter(a.vals()))))
  },
 test(
   "joinWith-4",
   Text.joinWith(",", ([].vals())),
   M.equals(T.text "")),
 test(
   "joinWith-5",
   Text.joinWith(",", (["aaa"].vals())),
   M.equals(T.text "aaa")),
]));


run(suite("split",
[
 test(
   "split-char-empty",
   Text.split("", #char ';'),
   M.equals(textIterT([]))),
 test(
   "split-char-none",
   Text.split("abc", #char ';'),
   M.equals(textIterT(["abc"]))),
 test(
   "split-char-empties2",
   Text.split(";", #char ';'),
   M.equals(textIterT(["",""]))),
 test(
   "split-char-empties3",
   Text.split(";;", #char ';'),
   M.equals(textIterT(["","",""]))),
 test(
   "split-char-singles",
   Text.split("a;b;;c;;;d", #char ';'),
   M.equals(textIterT(["a","b","","c","","","d"]))),
 test(
   "split-char-mixed",
   Text.split("a;;;ab;;abc;", #char ';'),
   M.equals(textIterT(["a","","","ab","","abc",""]))),
 {
   let a = Array.tabulate<Text>(1000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   test(
     "split-char-large",
     Text.split(t, #char ';'),
     M.equals(textIterT a))
 },
 {
   let a = Array.tabulate<Text>(100000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   test(
     "split-char-very-large",
     Text.split(t, #char ';'),
     M.equals(textIterT a))
 },
]));


{
let pat : Text.Pattern = #predicate (func (c : Char) : Bool { c == ';' or c == '!' }) ;
run(suite("split",
[
 test(
   "split-pred-empty",
   Text.split("", pat),
   M.equals(textIterT([]))),
 test(
   "split-pred-none",
   Text.split("abc", pat),
   M.equals(textIterT(["abc"]))),
 test(
   "split-pred-empties2",
   Text.split(";", pat),
   M.equals(textIterT(["",""]))),
 test(
   "split-pred-empties3",
   Text.split(";!", pat),
   M.equals(textIterT(["","",""]))),
 test(
   "split-pred-singles",
   Text.split("a;b;!c!;;d", pat),
   M.equals(textIterT(["a","b","","c","","","d"]))),
 test(
   "split-pred-mixed",
   Text.split("a;!;ab;!abc;", pat),
   M.equals(textIterT(["a","","","ab","","abc",""]))),
 {
   let a = Array.tabulate<Text>(1000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   test(
     "split-pred-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
 {
   let a = Array.tabulate<Text>(10000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   test(
     "split-pred-very-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
]))
};


{
let pat : Text.Pattern = #text "PAT" ;
run(suite("split",
[
 test(
   "split-pat-empty",
   Text.split("", pat),
   M.equals(textIterT([]))),
 test(
   "split-pat-none",
   Text.split("abc", pat),
   M.equals(textIterT(["abc"]))),
 test(
   "split-pat-empties2",
   Text.split("PAT", pat),
   M.equals(textIterT(["",""]))),
 test(
   "split-pat-empties3",
   Text.split("PATPAT", pat),
   M.equals(textIterT(["","",""]))),
 test(
   "split-pat-singles",
   Text.split("aPATbPATPATcPATPATPATd", pat),
   M.equals(textIterT(["a","b","","c","","","d"]))),
 test(
   "split-pat-mixed",
   Text.split("aPATPATPATabPATPATabcPAT", pat),
   M.equals(textIterT(["a","","","ab","","abc",""]))),
 {
   let a = Array.tabulate<Text>(1000,func _ = "abc");
   let t = Text.joinWith("PAT", a.vals());
   test(
     "split-pat-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
 {
   let a = Array.tabulate<Text>(10000,func _ = "abc");
   let t = Text.joinWith("PAT", a.vals());
   test(
     "split-pat-very-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
]))
};


run(suite("tokens",
[
 test(
   "tokens-char-empty",
   Text.tokens("", #char ';'),
   M.equals(textIterT([]))),
 test(
   "tokens-char-none",
   Text.tokens("abc", #char ';'),
   M.equals(textIterT(["abc"]))),
 test(
   "tokens-char-empties2",
   Text.tokens(";", #char ';'),
   M.equals(textIterT([]))),
 test(
   "tokens-char-empties3",
   Text.tokens(";;", #char ';'),
   M.equals(textIterT([]))),
 test(
   "tokens-char-singles",
   Text.tokens("a;b;;c;;;d", #char ';'),
   M.equals(textIterT(["a","b","c","d"]))),
 test(
   "tokens-char-mixed",
   Text.tokens("a;;;ab;;abc;", #char ';'),
   M.equals(textIterT(["a","ab","abc"]))),
 {
   let a = Array.tabulate<Text>(1000,func _ = "abc");
   let t = Text.joinWith(";;", a.vals());
   test(
     "tokens-char-large",
     Text.tokens(t, #char ';'),
     M.equals(textIterT a))
 },
 {
   let a = Array.tabulate<Text>(100000,func _ = "abc");
   let t = Text.joinWith(";;", a.vals());
   test(
     "tokens-char-very-large",
     Text.tokens(t, #char ';'),
     M.equals(textIterT a))
 },
]));

run(suite("startsWith",
[
 test(
   "startsWith-both-empty",
   Text.startsWith("", #text ""),
   M.equals(T.bool true)),
 test(
   "startsWith-empty-text",
   Text.startsWith("", #text "abc"),
   M.equals(T.bool false)),
 test(
   "startsWith-empty-pat",
   Text.startsWith("abc", #text ""),
   M.equals(T.bool true)),
 test(
   "startsWith-1",
   Text.startsWith("a", #text "b"),
   M.equals(T.bool false)),
 test(
   "startsWith-2",
   Text.startsWith("abc", #text "abc"),
   M.equals(T.bool true)),
 test(
   "startsWith-3",
   Text.startsWith("abcd", #text "ab"),
   M.equals(T.bool true)),
 test(
   "startsWith-4",
   Text.startsWith("abcdefghijklmnopqrstuvwxyz",#text "abcdefghijklmno"),
   M.equals(T.bool true)),
]));



run(suite("endsWith",
[
 test(
   "endsWith-both-empty",
   Text.endsWith("", #text ""),
   M.equals(T.bool true)),
 test(
   "endsWith-empty-text",
   Text.endsWith("", #text "abc"),
   M.equals(T.bool false)),
 test(
   "endsWith-empty-pat",
   Text.endsWith("abc", #text ""),
   M.equals(T.bool true)),
 test(
   "endsWith-1",
   Text.endsWith("a", #text "b"),
   M.equals(T.bool false)),
 test(
   "endsWith-2",
   Text.endsWith("abc", #text "abc"),
   M.equals(T.bool true)),
 test(
   "endsWith-3",
   Text.endsWith("abcd", #text "cd"),
   M.equals(T.bool true)),
 test(
   "endsWith-4",
   Text.endsWith("abcdefghijklmnopqrstuvwxyz",#text "pqrstuvwxyz"),
   M.equals(T.bool true)),
]));


run(suite("contains",
[
 test(
   "contains-start",
   Text.contains("abcd", #text "ab"),
   M.equals(T.bool true)),
 test(
   "contains-empty",
   Text.contains("abc", #text ""),
   M.equals(T.bool true)),
 test(
   "contains-false",
   Text.contains("ab", #text "bc" ),
   M.equals(T.bool false)),
 test(
   "contains-exact",
   Text.contains("abc", #text "abc"),
   M.equals(T.bool true)),
 test(
   "contains-within",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "qrst"),
   M.equals(T.bool true)),
 test(
   "contains-front",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "abcdefg"),
   M.equals(T.bool true)),
 test(
   "contains-end",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "xyz"),
   M.equals(T.bool true)),
 test(
   "contains-false",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "lkj"),
   M.equals(T.bool false)),
 test(
   "contains-empty-nonempty",
   Text.contains("", #text "xyz"),
   M.equals(T.bool false)),
]));


run(suite("replace",
[
 test(
   "replace-start",
   Text.replace("abcd", #text "ab", "AB"),
   M.equals(T.text "ABcd")),
 test(
   "replace-empty",
   Text.replace("abc", #text "", "AB"),
   M.equals(T.text "ABaABbABcAB")),
 test(
   "replace-none",
   Text.replace("ab", #text "bc", "AB"),
   M.equals(T.text "ab")),
 test(
   "replace-exact",
   Text.replace("ab", #text "ab", "AB"),
   M.equals(T.text "AB")),
 test(
   "replace-several",
   Text.replace("abcdabghijabmnopqrstuabwxab", #text "ab", "AB"),
   M.equals(T.text "ABcdABghijABmnopqrstuABwxAB")),
 test(
   "replace-delete",
   Text.replace("abcdabghijabmnopqrstuabwxab", #text "ab", ""),
   M.equals(T.text "cdghijmnopqrstuwx")),
 test(
   "replace-pred",
   Text.replace("abcdefghijklmnopqrstuvwxyz", #predicate (func (c : Char) : Bool { c < 'm'}), ""),
   M.equals(T.text "mnopqrstuvwxyz")),
]));

run(suite("stripStart",
[
 test(
   "stripStart-none",
   Text.stripStart("cd", #text "ab"),
   M.equals(optTextT (null))),
 test(
   "stripStart-one",
   Text.stripStart("abcd", #text "ab"),
   M.equals(optTextT (?"cd"))),
 test(
   "stripStart-two",
   Text.stripStart("abababcd", #text "ab", ),
   M.equals(optTextT (?"ababcd"))),
 test(
   "stripStart-only",
   Text.stripStart("ababababab", #text "ab", ),
   M.equals(optTextT (?"abababab"))),
 test(
   "stripStart-empty",
   Text.stripStart("abcdef", #text ""),
   M.equals(optTextT(?"abcdef"))),
 test(
   "stripStart-tooshort",
   Text.stripStart("abcdef", #text "abcdefg"),
   M.equals(optTextT(null))),
]));


run(suite("stripEnd",
[
 test(
   "stripEnd-exact",
   Text.stripEnd("cd", #text "cd"),
   M.equals(optTextT (?""))),
 test(
   "stripEnd-one",
   Text.stripEnd("abcd", #text "cd"),
   M.equals(optTextT (?"ab"))),
 test(
   "stripEnd-three",
   Text.stripEnd("abcdcdcd", #text "cd", ),
   M.equals(optTextT (?"abcdcd"))),
 test(
   "stripEnd-many",
   Text.stripEnd("cdcdcdcdcdcdcd", #text "cd", ),
   M.equals(optTextT (?"cdcdcdcdcdcd"))),
 test(
   "stripEnd-empty-pat",
   Text.stripEnd("abcdef", #text ""),
   M.equals(optTextT (?"abcdef"))),
 test(
   "stripEnd-empty",
   Text.stripEnd("", #text "cd"),
   M.equals(optTextT null)),
 test(
   "stripEnd-tooshort",
   Text.stripEnd("bcdef", #text "abcdef"),
   M.equals(optTextT null)),
]));


run(suite("trimStartMatches",
[
 test(
   "trimStartMatches-none",
   Text.trimStartMatches("cd", #text "ab"),
   M.equals(T.text "cd")),
 test(
   "trimStartMatches-one",
   Text.trimStartMatches("abcd", #text "ab"),
   M.equals(T.text "cd")),
 test(
   "trimStartMatches-two",
   Text.trimStartMatches("abababcd", #text "ab", ),
   M.equals(T.text "cd")),
 test(
   "trimStartMatches-only",
   Text.trimStartMatches("ababababab", #text "ab", ),
   M.equals(T.text "")),
 test(
   "trimStartMatches-empty",
   Text.trimStartMatches("abcdef", #text ""),
   M.equals(T.text "abcdef")),
]));

run(suite("trimEndMatches",
[
 test(
   "trimEndMatches-exact",
   Text.trimEndMatches("cd", #text "cd"),
   M.equals(T.text "")),
 test(
   "trimEndMatches-one",
   Text.trimEndMatches("abcd", #text "cd"),
   M.equals(T.text "ab")),
 test(
   "trimEndMatches-three",
   Text.trimEndMatches("abcdcdcd", #text "cd", ),
   M.equals(T.text "ab")),
 test(
   "trimEndMatches-many",
   Text.trimEndMatches("cdcdcdcdcdcdcd", #text "cd", ),
   M.equals(T.text "")),
 test(
   "trimEndMatches-empty-pat",
   Text.trimEndMatches("abcdef", #text ""),
   M.equals(T.text "abcdef")),
 test(
   "trimEndMatches-empty",
   Text.trimEndMatches("", #text "cd"),
   M.equals(T.text "")),
]));


{
let cmp = Char.compare;
run(suite("compareWith",
[
 test(
   "compareWith-empties",
   Text.compareWith("", "", cmp),
   M.equals(ordT (#equal))),
 test(
   "compareWith-empty",
   Text.compareWith("abc", "", cmp),
   M.equals(ordT (#greater))),
 test(
   "compareWith-equal-nonempty",
   Text.compareWith("abc", "abc", cmp ),
   M.equals(ordT (#equal))),
 test(
   "compareWith-less-nonempty",
   Text.compareWith("abc", "abd", cmp),
   M.equals(ordT (#less))),
 test(
   "compareWith-less-nonprefix",
   Text.compareWith("abc", "abcd", cmp),
   M.equals(ordT (#less))),
 test(
   "compareWith-empty-nonempty",
   Text.compareWith("", "abcd", cmp),
   M.equals(ordT (#less))),
 test(
   "compareWith-prefix",
   Text.compareWith("abcd", "abc", cmp),
   M.equals(ordT (#greater)))
]))
};
