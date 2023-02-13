/// Utility functions for `Text` values.
///
/// A `Text` value represents human-readable text as a sequence of characters of type `Char`.
///
/// ```motoko
/// let text = "Hello!";
/// let size = text.size(); // 6
/// let iter = text.chars(); // iterator ('H', 'e', 'l', 'l', 'o', '!')
/// let concat = text # " 👋"; // "Hello! 👋"
/// ```
///
/// The `"mo:base/Text"` module defines additional operations on `Text` values.
///
/// Import the module from the base library:
///
/// ```motoko name=import
/// import Text "mo:base/Text";
/// ```
///
/// Note: `Text` values are represented as ropes of UTF-8 character sequences with O(1) concatenation.
///

import Char "Char";
import Iter "Iter";
import Hash "Hash";
import Stack "Stack";
import Prim "mo:⛔";

module {

  /// The type corresponding to primitive `Text` values.
  ///
  /// ```motoko
  /// let hello = "Hello!";
  /// let emoji = "👋";
  /// let concat = hello # " " # emoji; // "Hello! 👋"
  /// ```
  public type Text = Prim.Types.Text;

  /// Converts the given `Char` to a `Text` value.
  ///
  /// ```motoko include=import
  /// let text = Text.fromChar('A'); // "A"
  /// ```
  public let fromChar : (c : Char) -> Text = Prim.charToText;

  /// Iterates over each `Char` value in the given `Text`.
  ///
  /// Equivalent to calling the `t.chars()` method where `t` is a `Text` value.
  ///
  /// ```motoko include=import
  /// import { print } "mo:base/Debug";
  ///
  /// for (c in Text.toIter("abc")) {
  ///   print(debug_show c);
  /// }
  /// ```
  public func toIter(t : Text) : Iter.Iter<Char> = t.chars();

  /// Creates a `Text` value from a `Char` iterator.
  ///
  /// ```motoko include=import
  /// let text = Text.fromIter(['a', 'b', 'c'].vals()); // "abc"
  /// ```
  public func fromIter(cs : Iter.Iter<Char>) : Text {
    var r = "";
    for (c in cs) {
      r #= Prim.charToText(c)
    };
    return r
  };

  /// Returns the number of characters in the given `Text`.
  ///
  /// Equivalent to calling `t.size()` where `t` is a `Text` value.
  ///
  /// ```motoko include=import
  /// let size = Text.size("abc"); // 3
  /// ```
  public func size(t : Text) : Nat { t.size() };

  /// Returns a hash obtained by using the `djb2` algorithm ([more details](http://www.cse.yorku.ca/~oz/hash.html)).
  ///
  /// ```motoko include=import
  /// let hash = Text.hash("abc");
  /// ```
  ///
  /// Note: this algorithm is intended for use in data structures rather than as a cryptographic hash function.
  public func hash(t : Text) : Hash.Hash {
    var x : Nat32 = 5381;
    for (char in t.chars()) {
      let c : Nat32 = Prim.charToNat32(char);
      x := ((x << 5) +% x) +% c
    };
    return x
  };

  /// Returns `t1 # t2`, where `#` is the `Text` concatenation operator.
  ///
  /// ```motoko include=import
  /// let a = "Hello";
  /// let b = "There";
  /// let together = a # b; // "HelloThere"
  /// let withSpace = a # " " # b; // "Hello There"
  /// let togetherAgain = Text.concat(a, b); // "HelloThere"
  /// ```
  public func concat(t1 : Text, t2 : Text) : Text = t1 # t2;

  /// Returns `t1 == t2`.
  public func equal(t1 : Text, t2 : Text) : Bool { t1 == t2 };

  /// Returns `t1 != t2`.
  public func notEqual(t1 : Text, t2 : Text) : Bool { t1 != t2 };

  /// Returns `t1 < t2`.
  public func less(t1 : Text, t2 : Text) : Bool { t1 < t2 };

  /// Returns `t1 <= t2`.
  public func lessOrEqual(t1 : Text, t2 : Text) : Bool { t1 <= t2 };

  /// Returns `t1 > t2`.
  public func greater(t1 : Text, t2 : Text) : Bool { t1 > t2 };

  /// Returns `t1 >= t2`.
  public func greaterOrEqual(t1 : Text, t2 : Text) : Bool { t1 >= t2 };

  /// Compares `t1` and `t2` lexicographically.
  ///
  /// ```motoko include=import
  /// import { print } "mo:base/Debug";
  ///
  /// print(debug_show Text.compare("abc", "abc")); // #equal
  /// print(debug_show Text.compare("abc", "def")); // #less
  /// print(debug_show Text.compare("abc", "ABC")); // #greater
  /// ```
  public func compare(t1 : Text, t2 : Text) : { #less; #equal; #greater } {
    let c = Prim.textCompare(t1, t2);
    if (c < 0) #less else if (c == 0) #equal else #greater
  };

  private func extract(t : Text, i : Nat, j : Nat) : Text {
    let size = t.size();
    if (i == 0 and j == size) return t;
    assert (j <= size);
    let cs = t.chars();
    var r = "";
    var n = i;
    while (n > 0) {
      ignore cs.next();
      n -= 1
    };
    n := j;
    while (n > 0) {
      switch (cs.next()) {
        case null { assert false };
        case (?c) { r #= Prim.charToText(c) }
      };
      n -= 1
    };
    return r
  };

  /// Join an iterator of `Text` values with a given delimiter.
  ///
  /// ```motoko include=import
  /// let joined = Text.join(", ", ["a", "b", "c"].vals()); // "a, b, c"
  /// ```
  public func join(sep : Text, ts : Iter.Iter<Text>) : Text {
    var r = "";
    if (sep.size() == 0) {
      for (t in ts) {
        r #= t
      };
      return r
    };
    let next = ts.next;
    switch (next()) {
      case null { return r };
      case (?t) {
        r #= t
      }
    };
    loop {
      switch (next()) {
        case null { return r };
        case (?t) {
          r #= sep;
          r #= t
        }
      }
    }
  };

  /// Applies a function to each character in a `Text` value, returning the concatenated `Char` results.
  ///
  /// ```motoko include=import
  /// // Replace all occurrences of '?' with '!'
  /// let result = Text.map("Motoko?", func(c) {
  ///   if (c == '?') '!'
  ///   else c
  /// });
  /// ```
  public func map(t : Text, f : Char -> Char) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= Prim.charToText(f(c))
    };
    return r
  };

  /// Returns the result of applying `f` to each character in `ts`, concatenating the intermediate text values.
  ///
  /// ```motoko include=import
  /// // Replace all occurrences of '?' with "!!"
  /// let result = Text.translate("Motoko?", func(c) {
  ///   if (c == '?') "!!"
  ///   else Text.fromChar(c)
  /// }); // "Motoko!!"
  /// ```
  public func translate(t : Text, f : Char -> Text) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= f(c)
    };
    return r
  };

  /// A pattern `p` describes a sequence of characters. A pattern has one of the following forms:
  ///
  /// * `#char c` matches the single character sequence, `c`.
  /// * `#text t` matches multi-character text sequence `t`.
  /// * `#predicate p` matches any single character sequence `c` satisfying predicate `p(c)`.
  ///
  /// A _match_ for `p` is any sequence of characters matching the pattern `p`.
  ///
  /// ```motoko include=import
  /// let charPattern = #char 'A';
  /// let textPattern = #text "phrase";
  /// let predicatePattern : Text.Pattern = #predicate (func(c) { c == 'A' or c == 'B' }); // matches "A" or "B"
  /// ```
  public type Pattern = {
    #char : Char;
    #text : Text;
    #predicate : (Char -> Bool)
  };

  private func take(n : Nat, cs : Iter.Iter<Char>) : Iter.Iter<Char> {
    var i = n;
    object {
      public func next() : ?Char {
        if (i == 0) return null;
        i -= 1;
        return cs.next()
      }
    }
  };

  private func empty() : Iter.Iter<Char> {
    object {
      public func next() : ?Char = null
    }
  };

  private type Match = {
    /// #success on complete match
    #success;
    /// #fail(cs,c) on partial match of cs, but failing match on c
    #fail : (cs : Iter.Iter<Char>, c : Char);
    /// #empty(cs) on partial match of cs and empty stream
    #empty : (cs : Iter.Iter<Char>)
  };

  private func sizeOfPattern(pat : Pattern) : Nat {
    switch pat {
      case (#text(t)) { t.size() };
      case (#predicate(_) or #char(_)) { 1 }
    }
  };

  private func matchOfPattern(pat : Pattern) : (cs : Iter.Iter<Char>) -> Match {
    switch pat {
      case (#char(p)) {
        func(cs : Iter.Iter<Char>) : Match {
          switch (cs.next()) {
            case (?c) {
              if (p == c) {
                #success
              } else {
                #fail(empty(), c)
              }
            };
            case null { #empty(empty()) }
          }
        }
      };
      case (#predicate(p)) {
        func(cs : Iter.Iter<Char>) : Match {
          switch (cs.next()) {
            case (?c) {
              if (p(c)) {
                #success
              } else {
                #fail(empty(), c)
              }
            };
            case null { #empty(empty()) }
          }
        }
      };
      case (#text(p)) {
        func(cs : Iter.Iter<Char>) : Match {
          var i = 0;
          let ds = p.chars();
          loop {
            switch (ds.next()) {
              case (?d) {
                switch (cs.next()) {
                  case (?c) {
                    if (c != d) {
                      return #fail(take(i, p.chars()), c)
                    };
                    i += 1
                  };
                  case null {
                    return #empty(take(i, p.chars()))
                  }
                }
              };
              case null { return #success }
            }
          }
        }
      }
    }
  };

  private class CharBuffer(cs : Iter.Iter<Char>) : Iter.Iter<Char> = {

    var stack : Stack.Stack<(Iter.Iter<Char>, Char)> = Stack.Stack();

    public func pushBack(cs0 : Iter.Iter<Char>, c : Char) {
      stack.push((cs0, c))
    };

    public func next() : ?Char {
      switch (stack.peek()) {
        case (?(buff, c)) {
          switch (buff.next()) {
            case null {
              ignore stack.pop();
              return ?c
            };
            case oc {
              return oc
            }
          }
        };
        case null {
          return cs.next()
        }
      }
    }
  };

  /// Splits the input `Text` with the specified `Pattern`.
  ///
  /// Two fields are separated by exactly one match.
  ///
  /// ```motoko include=import
  /// let words = Text.split("This is a sentence.", #char ' ');
  /// Text.join("|", words) // "This|is|a|sentence."
  /// ```
  public func split(t : Text, p : Pattern) : Iter.Iter<Text> {
    let match = matchOfPattern(p);
    let cs = CharBuffer(t.chars());
    var state = 0;
    var field = "";
    object {
      public func next() : ?Text {
        switch state {
          case (0 or 1) {
            loop {
              switch (match(cs)) {
                case (#success) {
                  let r = field;
                  field := "";
                  state := 1;
                  return ?r
                };
                case (#empty(cs1)) {
                  for (c in cs1) {
                    field #= fromChar(c)
                  };
                  let r = if (state == 0 and field == "") {
                    null
                  } else {
                    ?field
                  };
                  state := 2;
                  return r
                };
                case (#fail(cs1, c)) {
                  cs.pushBack(cs1, c);
                  switch (cs.next()) {
                    case (?ci) {
                      field #= fromChar(ci)
                    };
                    case null {
                      let r = if (state == 0 and field == "") {
                        null
                      } else {
                        ?field
                      };
                      state := 2;
                      return r
                    }
                  }
                }
              }
            }
          };
          case _ { return null }
        }
      }
    }
  };

  /// Returns a substring of the input `Text` delimited by the specified `Pattern`, provided with a starting position and a length.
  /// If no length is passed, returns empty string.
  ///
  /// ```motoko include=import
  /// Text.substring("This is a sentence.", 0, 4) // "This"
  /// Text.substring("This is a sentence.", 5, 4) // "is a"
  /// Text.substring("This is a sentence.", 0, 0) // ""
  /// ```
  public func substring(t : Text, start : Int, len : Int) : Text {
    var output = "";
    var count = 0;
    //handle negative length
    if (len < 0) {
      for (char in t.chars()) {
        // handle negative start
        if (start < 0) {
          if (count >= t.size() + start) {
            output := output # fromChar(char)
          };
          count := count + 1
        };
        // handle positive start
        if (count >= start) {
          output := output # fromChar(char);
          count := count + 1
        }
      };
      return output
    };

    // handle positive length
    for (char in t.chars()) {
      // handle negative start
      if (start < 0) {
        if (count >= t.size() + start and count < t.size() + start + len) {
          output := output # fromChar(char)
        };
        count := count + 1
      };
      // handle positive start
      if (count >= start and count < start + len) {
        output := output # fromChar(char);
        count := count + 1
      }
    };
    output
  };

  /// Returns a sequence of tokens from the input `Text` delimited by the specified `Pattern`, derived from start to end.
  /// A "token" is a non-empty maximal subsequence of `t` not containing a match for pattern `p`.
  /// Two tokens may be separated by one or more matches of `p`.
  ///
  /// ```motoko include=import
  /// let tokens = Text.tokens("this needs\n an   example", #predicate (func(c) { c == ' ' or c == '\n' }));
  /// Text.join("|", tokens) // "this|needs|an|example"
  /// ```
  public func tokens(t : Text, p : Pattern) : Iter.Iter<Text> {
    let fs = split(t, p);
    object {
      public func next() : ?Text {
        switch (fs.next()) {
          case (?"") { next() };
          case ot { ot }
        }
      }
    }
  };

  /// Returns `true` if the input `Text` contains a match for the specified `Pattern`.
  ///
  /// ```motoko include=import
  /// Text.contains("Motoko", #text "oto") // true
  /// ```
  public func contains(t : Text, p : Pattern) : Bool {
    let match = matchOfPattern(p);
    let cs = CharBuffer(t.chars());
    loop {
      switch (match(cs)) {
        case (#success) {
          return true
        };
        case (#empty(cs1)) {
          return false
        };
        case (#fail(cs1, c)) {
          cs.pushBack(cs1, c);
          switch (cs.next()) {
            case null {
              return false
            };
            case _ {}; // continue
          }
        }
      }
    }
  };

  /// Returns `true` if the input `Text` starts with a prefix matching the specified `Pattern`.
  ///
  /// ```motoko include=import
  /// Text.startsWith("Motoko", #text "Mo") // true
  /// ```
  public func startsWith(t : Text, p : Pattern) : Bool {
    var cs = t.chars();
    let match = matchOfPattern(p);
    switch (match(cs)) {
      case (#success) { true };
      case _ { false }
    }
  };

  /// Returns `true` if the input `Text` ends with a suffix matching the specified `Pattern`.
  ///
  /// ```motoko include=import
  /// Text.endsWith("Motoko", #char 'o') // true
  /// ```
  public func endsWith(t : Text, p : Pattern) : Bool {
    let s2 = sizeOfPattern(p);
    if (s2 == 0) return true;
    let s1 = t.size();
    if (s2 > s1) return false;
    let match = matchOfPattern(p);
    var cs1 = t.chars();
    var diff : Nat = s1 - s2;
    while (diff > 0) {
      ignore cs1.next();
      diff -= 1
    };
    switch (match(cs1)) {
      case (#success) { true };
      case _ { false }
    }
  };

  /// Returns the input text `t` with all matches of pattern `p` replaced by text `r`.
  ///
  /// ```motoko include=import
  /// let result = Text.replace("abcabc", #char 'a', "A"); // "AbcAbc"
  /// ```
  public func replace(t : Text, p : Pattern, r : Text) : Text {
    let match = matchOfPattern(p);
    let size = sizeOfPattern(p);
    let cs = CharBuffer(t.chars());
    var res = "";
    label l loop {
      switch (match(cs)) {
        case (#success) {
          res #= r;
          if (size > 0) {
            continue l
          }
        };
        case (#empty(cs1)) {
          for (c1 in cs1) {
            res #= fromChar(c1)
          };
          break l
        };
        case (#fail(cs1, c)) {
          cs.pushBack(cs1, c)
        }
      };
      switch (cs.next()) {
        case null {
          break l
        };
        case (?c1) {
          res #= fromChar(c1)
        }; // continue
      }
    };
    return res
  };

  /// Strips one occurrence of the given `Pattern` from the beginning of the input `Text`.
  /// If you want to remove multiple instances of the pattern, use `Text.trimStart()` instead.
  ///
  /// ```motoko include=import
  /// // Try to strip a nonexistent character
  /// let none = Text.stripStart("abc", #char '-'); // null
  /// // Strip just one '-'
  /// let one = Text.stripStart("--abc", #char '-'); // ?"-abc"
  /// ```
  public func stripStart(t : Text, p : Pattern) : ?Text {
    let s = sizeOfPattern(p);
    if (s == 0) return ?t;
    var cs = t.chars();
    let match = matchOfPattern(p);
    switch (match(cs)) {
      case (#success) return ?fromIter(cs);
      case _ return null
    }
  };

  /// Strips one occurrence of the given `Pattern` from the end of the input `Text`.
  /// If you want to remove multiple instances of the pattern, use `Text.trimEnd()` instead.
  ///
  /// ```motoko include=import
  /// // Try to strip a nonexistent character
  /// let none = Text.stripEnd("xyz", #char '-'); // null
  /// // Strip just one '-'
  /// let one = Text.stripEnd("xyz--", #char '-'); // ?"xyz-"
  /// ```
  public func stripEnd(t : Text, p : Pattern) : ?Text {
    let s2 = sizeOfPattern(p);
    if (s2 == 0) return ?t;
    let s1 = t.size();
    if (s2 > s1) return null;
    let match = matchOfPattern(p);
    var cs1 = t.chars();
    var diff : Nat = s1 - s2;
    while (diff > 0) {
      ignore cs1.next();
      diff -= 1
    };
    switch (match(cs1)) {
      case (#success) return ?extract(t, 0, s1 - s2);
      case _ return null
    }
  };

  /// Trims the given `Pattern` from the start of the input `Text`.
  /// If you only want to remove a single instance of the pattern, use `Text.stripStart()` instead.
  ///
  /// ```motoko include=import
  /// let trimmed = Text.trimStart("---abc", #char '-'); // "abc"
  /// ```
  public func trimStart(t : Text, p : Pattern) : Text {
    let cs = t.chars();
    let size = sizeOfPattern(p);
    if (size == 0) return t;
    var matchSize = 0;
    let match = matchOfPattern(p);
    loop {
      switch (match(cs)) {
        case (#success) {
          matchSize += size
        }; // continue
        case (#empty(cs1)) {
          return if (matchSize == 0) {
            t
          } else {
            fromIter(cs1)
          }
        };
        case (#fail(cs1, c)) {
          return if (matchSize == 0) {
            t
          } else {
            fromIter(cs1) # fromChar(c) # fromIter(cs)
          }
        }
      }
    }
  };

  /// Trims the given `Pattern` from the end of the input `Text`.
  /// If you only want to remove a single instance of the pattern, use `Text.stripEnd()` instead.
  ///
  /// ```motoko include=import
  /// let trimmed = Text.trimEnd("xyz---", #char '-'); // "xyz"
  /// ```
  public func trimEnd(t : Text, p : Pattern) : Text {
    let cs = CharBuffer(t.chars());
    let size = sizeOfPattern(p);
    if (size == 0) return t;
    let match = matchOfPattern(p);
    var matchSize = 0;
    label l loop {
      switch (match(cs)) {
        case (#success) {
          matchSize += size
        }; // continue
        case (#empty(cs1)) {
          switch (cs1.next()) {
            case null break l;
            case (?_) return t
          }
        };
        case (#fail(cs1, c)) {
          matchSize := 0;
          cs.pushBack(cs1, c);
          ignore cs.next()
        }
      }
    };
    extract(t, 0, t.size() - matchSize)
  };

  /// Trims the given `Pattern` from both the start and end of the input `Text`.
  ///
  /// ```motoko include=import
  /// let trimmed = Text.trim("---abcxyz---", #char '-'); // "abcxyz"
  /// ```
  public func trim(t : Text, p : Pattern) : Text {
    let cs = t.chars();
    let size = sizeOfPattern(p);
    if (size == 0) return t;
    var matchSize = 0;
    let match = matchOfPattern(p);
    loop {
      switch (match(cs)) {
        case (#success) {
          matchSize += size
        }; // continue
        case (#empty(cs1)) {
          return if (matchSize == 0) { t } else { fromIter(cs1) }
        };
        case (#fail(cs1, c)) {
          let start = matchSize;
          let cs2 = CharBuffer(cs);
          cs2.pushBack(cs1, c);
          ignore cs2.next();
          matchSize := 0;
          label l loop {
            switch (match(cs2)) {
              case (#success) {
                matchSize += size
              }; // continue
              case (#empty(cs3)) {
                switch (cs1.next()) {
                  case null break l;
                  case (?_) return t
                }
              };
              case (#fail(cs3, c1)) {
                matchSize := 0;
                cs2.pushBack(cs3, c1);
                ignore cs2.next()
              }
            }
          };
          return extract(t, start, t.size() - matchSize - start)
        }
      }
    }
  };

  /// Compares `t1` and `t2` using the provided character-wise comparison function.
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  ///
  /// Text.compareWith("abc", "ABC", func(c1, c2) { Char.compare(c1, c2) }) // #greater
  /// ```
  public func compareWith(
    t1 : Text,
    t2 : Text,
    cmp : (Char, Char) -> { #less; #equal; #greater }
  ) : { #less; #equal; #greater } {
    let cs1 = t1.chars();
    let cs2 = t2.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, null) { return #equal };
        case (null, ?_) { return #less };
        case (?_, null) { return #greater };
        case (?c1, ?c2) {
          switch (cmp(c1, c2)) {
            case (#equal) {}; // continue
            case other { return other }
          }
        }
      }
    }
  };

  /// Returns a UTF-8 encoded `Blob` from the given `Text`.
  ///
  /// ```motoko include=import
  /// let blob = Text.encodeUtf8("Hello");
  /// ```
  public let encodeUtf8 : Text -> Blob = Prim.encodeUtf8;

  /// Tries to decode the given `Blob` as UTF-8.
  /// Returns `null` if the blob is not valid UTF-8.
  ///
  /// ```motoko include=import
  /// let text = Text.decodeUtf8("\48\65\6C\6C\6F"); // ?"Hello"
  /// ```
  public let decodeUtf8 : Blob -> ?Text = Prim.decodeUtf8
}
