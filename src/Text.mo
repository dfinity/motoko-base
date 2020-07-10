/// Text values
///
/// This type describes a valid, human-readable text. It does not contain arbitrary
/// binary data.

import Char "Char";
import Iter "Iter";
import Hash "Hash";
import Prim "mo:prim";

module {

  /// Returns the concatenation of `x` and `y`, `x # y`.
  public func concat(x : Text, y : Text) : Text =
    x # y;

  /// Creates an [iterator](Iter.html#type.Iter) that traverses the characters of the text.
  public func toIter(text : Text) : Iter.Iter<Char> =
    text.chars();

  /// WARNING: This only hashes the lowest 32 bits of the `Int`
  public func hash(t : Text) : Hash.Hash {
    var x = 0 : Word32;
    for (c in t.chars()) {
      x := x ^ Prim.charToWord32(c);
    };
    return x
  };

  /// Returns `x == y`.
  public func equal(x : Text, y : Text) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Text, y : Text) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Text, y : Text) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Text, y : Text) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Text, y : Text) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Text, y : Text) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Text, y : Text) : { #less; #equal; #greater } {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

  /// Returns `t.size()`, the number of characters in `ts`.
  public func size(t : Text) : Nat { t.size(); };

  /// Returns the `i`-th character in `ts`. _O_(`size(t)`). May trap.
  public func sub(t : Text, i : Nat) : Char {
    let cs = t.chars();
    var n : Int = i;
    loop {
      while (n > 0) {
        switch (cs.next()) {
          case null assert false;
          case (?c) n -= 1;
        };
      };
      switch (cs.next()) {
        case null assert false;
        case (?c) { return c };
      };
    };
  };

  /// Returns:
  /// - when `jo` is `null`, the subtext of `t` between characters `i` and characters `t.size()-1`.
  ///   Traps when `t.size() < i`.
  /// - when `jo` is  `?j`: the subtext of `t` between characters `i` and `i+j-1`.
  ///   Traps when `t.size < i + j`.
  public func extract(t : Text, i : Nat, jo : ?Nat) : Text {
    var r = "";
    var j = switch jo { case (?j) j; case null (t.size()) };
     let cs = t.chars();
     var n = i;
     while (n > 0) {
       switch (cs.next()) {
         case null (assert false);
         case (?_) ();
       };
       n -= 1;
     };
     n := j;
     while (n > 0) {
       switch (cs.next()) {
         case null (assert false);
         case (?c) { r #= Prim.charToText(c) }
       };
       n -= 1;
     };
     return r;
  };

  /// Returns the subtext of `t` between characters `i` and `i+j-1`. Equivalent to `extract(t, i, ?j)`. Traps when `t.size < i + j`. _O_(`size(t)`).
  public func subtext(t : Text, i : Nat, j: Nat) : Text {
    extract(t, i, ?j);
  };

  /// Returns the concatenation of text values in `ts`.
  public func join(ts : Iter.Iter<Text>) : Text {
     var r = "";
     for (t in ts) {
       r #= t
     };
     return r;
  };

  /// Returns the concatenation of text values in `ts`, separated by `sep`.
  public func joinWith(sep : Text, ts : Iter.Iter<Text>) : Text {
    var r = "";
    let next = ts.next;
    switch (next()) {
      case null { return r; };
      case (?t) {
        r #= t;
      }
    };
    loop {
      switch (next()) {
        case null { return r; };
        case (?t) {
          r #= sep;
          r #= t;
        }
      }
    }
  };

  /// Returns the text value of size 1 containing the single character `c`;
  public let fromChar : (c : Char) -> Text = Prim.charToText;

  /// Returns the text value containing the sequence of characters in `cs`.
  public func implode(cs : Iter.Iter<Char>) : Text {
    var r = "";
    for (c in cs) {
      r #= Prim.charToText(c);
    };
    return r;
  };

  /// Returns an iter enumerating the sequence of characters in `t` (from first to last).
  public func explode(t : Text) : Iter.Iter<Char> {
    t.chars();
  };

  /// Returns the result of applying `f` to each character in `ts`, concatenating the intermediate single-character text values.
  public func map(t : Text, f : Char -> Char) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= Prim.charToText(f(c));
    };
    return r;
  };

  /// Returns the result of applying `f` to each character in `ts`, concatenating the intermediate text values.
  public func translate(t : Text, f : Char -> Text) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= f(c);
    };
    return r;
  };

  /// Returns the sequence of fields in `t`, derived from left to right.
  /// A _field_ is a possibly empty, maximal subtext of `t` not containing a delimiter.
  /// A _delimiter_ is any character matching the predicate `p`.
  /// Two fields are separated by exactly one delimiter.
  public func fields(t : Text, p : Char -> Bool) : Iter.Iter<Text> {
    var getc = t.chars().next;
    var state : { #init; #resume; #done} = #init;
    var field = "";
    object {
      public func next() : ?Text {
        switch state {
          case (#done) { return null };
          case (#init) {
            loop {
              switch (getc()) {
                case (?c) {
                  if (p(c)) {
                    let r = field;
                    field := "";
                    state := #resume;
                    return ?r
                  }
                  else field #= Prim.charToText(c);
                };
                case null {
                  state := #done;
                  return if (field == "") null else ?field;
                }
              }
            }
          };
          case (#resume) {
            loop {
              switch (getc()) {
                case (?c) {
                  if (p(c)) {
                    let r = field;
                    field := "";
                    state := #resume;
                    return ?r
                  }
                  else field #= Prim.charToText(c);
                };
                case null {
                  state := #done;
                  return ?field;
                }
              }
            }
          }
        }
      }
    }
  };

  public type Pattern = { #char : Char; #text : Text; #predicate : (Char -> Bool) };

  private func take(n : Nat, cs : Iter.Iter<Char>) : Iter.Iter<Char> {
    var i = n;
    object {
      public func next() : ?Char {
        if (i == 0) return null;
        i -= 1;
        return cs.next();
      }
    }
  };

  private func singleton(c : Char) : Iter.Iter<Char> {
    var s = ?c;
    object {
      public func next() : ?Char {
        let temp = s;
        s := null;
        return temp
      }
    }
  };

  private func empty() : Iter.Iter<Char> {
    object {
      public func next() : ?Char = null;
    };
  };

  private func append(i1 : Iter.Iter<Char>, i2 : Iter.Iter<Char>) : Iter.Iter<Char> {
    var i = i1;
    var state = 0;
    object {
      public func next() : ?Char {
        if (state > 1) return null;
        switch (i.next()) {
          case null {
            switch state {
              case 0 {
                i := i2;
                state := 1;
                return i.next();
              };
              case _ {
                state := 2;
                return null;
              };
            }
          };
          case o { return o };
        }
      }
    }
  };

  private type Match = {
    /// #success on complete match
    #success;
    /// #fail(cs,c) on partial match of cs, but failing match on c
    #fail : (cs: Iter.Iter<Char>, c : Char);
    /// #empty(cs) on partial match of cs and empty stream
    #empty : (cs :Iter.Iter<Char> )
  };

  public func matchOfPattern(pat : Pattern) : (cs : Iter.Iter<Char>) -> Match {
     switch pat {
       case (#char p) {
         func (cs : Iter.Iter<Char>) : Match {
           switch (cs.next()) {
             case (?c) { if (p == c) #success else #fail (empty(), c) };
             case null #empty (empty());
           }
         }
       };
       case (#predicate p) {
         func (cs : Iter.Iter<Char>) : Match {
           switch (cs.next()) {
             case (?c) { if (p(c)) #success else #fail (empty(), c) };
             case null { #empty (empty()) };
           }
         }
       };
       case (#text p) {
         func (cs : Iter.Iter<Char>) : Match {
           var i = 0;
           let ds = p.chars();
           loop {
             switch (ds.next()) {
               case (?d)  {
                 switch (cs.next()) {
                   case (?c) {
                     if (c != d) {
                       return #fail (take(i, p.chars()), c)
                     };
                     i += 1;
                   };
                   case null {
                     return #empty (take(i, p.chars()));
                   }
                 }
               };
               case null { return #success };
             }
           }
         }
       }
     }
  };

  /// Returns the sequence of fields in `t`, derived from left to right, separated by text matching pattern `p`.
  /// A _field_ is a possibly empty, maximal subtext of `t` not containing a match for `p`.
  /// A _match_ is any sequence of characters matching the pattern `p`, where
  /// * `#char c` matches the single character sequence, `c`.
  /// * `#predicate p` matches any single character sequence `c` satisfying predicate `p(c)`.
  /// * `#text t1` matches multi-character text sequence `t1`.
  /// Two fields are separated by exactly one match.
  public func split(t : Text, p : Pattern) : Iter.Iter<Text> {
    let match = matchOfPattern p;
    var buff = empty();
    var char = null : ?Char;
    let chars = t.chars();
    var cs = object {
        public func next() : ?Char {
          switch (buff.next()) {
            case null {
	      switch char {
	        case (?c) {
		  char := null;
		  return ?c;
		};
		case null {
		  return chars.next();
                };
              }
	    };
            case oc oc;
          }
        };
      };
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
                case (#empty cs1) {
                  for (c in cs1) {
                    field #= fromChar c;
                  };
                  let r =
		    if (state == 0 and field == "")
		      null
                    else ?field;
		  state := 2;
		  return r;
                };
                case (#fail (cs1, c)) {
		  buff := cs1;
                  char := ?c;
                  switch (cs.next()) {
                    case (?ci) {
                      field #= fromChar ci;
                    };
                    case null {
		      let r =
		         if (state == 0 and field == "")
 		           null
                         else ?field;
		      state := 2;
		      return r;
                    }
                  }
                }
              }
            }
          };
          case _ { return null };
        }
      }
    }
  };

  /// Returns the sequence of tokens in `t`, derived from left to right.
  /// A _token_ is a non-empty maximal subtext of `t` not containing a delimiter.
  /// A _delimiter_ is any character matching the predicate `p`.
  /// Two tokens may be separated by more than one delimiter.
  public func tokens(t : Text, p : Char -> Bool) : Iter.Iter<Text> {
    let fs = fields(t, p);
    object {
      public func next() : ?Text {
        switch (fs.next()) {
          case (?"") next();
          case ot ot;
        }
      }
    }
  };

  /// Returns true if `t` contains a match for pattern `p`.
  /// A _match_ is any sequence of characters matching the pattern `p`, where
  /// * `#char c` matches the single character sequence, `c`.
  /// * `#predicate p` matches any single character sequence `c` satisfying predicate `p(c)`.
  /// * `#text t1` matches multi-character text sequence `t1`.
  public func contains(t : Text, p : Pattern) : Bool {
    let match = matchOfPattern p;
    var buff = empty();
    var char = null : ?Char;
    let chars = t.chars();
    var cs = object {
        public func next() : ?Char {
          switch (buff.next()) {
            case null {
	      switch char {
	        case (?c) {
		  char := null;
		  return ?c;
		};
		case null {
		  return chars.next();
                };
              }
	    };
            case oc oc;
          }
        };
      };
    loop {
      switch (match(cs)) {
        case (#success) {
          return true
        };
        case (#empty cs1) {
          return false;
        };
        case (#fail (cs1, c)) {
	  buff := cs1;
	  char := ?c;
          switch (cs.next()) {
            case null {
              return false
            };
            case _ { }; //continue
          }
        }
      }
    }
  };

/*
  /// Returns `true` if `t1` starts with prefix `t2`, otherwise returns `false`.
  public func startsWith(t1 : Text, t2 : Text) : Bool {
    var cs1 = t1.chars();
    var cs2 = t2.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, ?c2) { return false };
        case (_, null) { return true };
        case (?c1, ?c2) {
          if (c1 != c2) return false;
        }
      }
    }
  };
*/

  /// Returns `true` if `t1` starts with a prefix matching pattern `p`, otherwise returns `false`.
  public func startsWith(t1 : Text, p : Pattern) : Bool {
    var cs1 = t1.chars();
    let match = matchOfPattern p;
    switch (match(cs1)) {
      case (#success) true;
      case _ false;
    }
  };

  /// Returns `true` if `t1` ends with a suffix matching pattern `p`, otherwise returns `false`.
  public func endsWith(t1 : Text, p : Pattern) : Bool {
    let s2 = switch p {
      case (#char _) 1;
      case (#predicate _) 1;
      case (#text t) t.size();
    };
    if (s2 == 0) return true;
    let s1 = t1.size();
    if (s2 > s1) return false;
    let match = matchOfPattern p;
    var cs1 = t1.chars();
    var diff = s1 - s2;
    while (diff > 0)  {
      ignore cs1.next();
      diff -= 1;
    };
    switch (match(cs1)) {
      case (#success) true;
      case _ false;
    }
  };

  /// Returns the lexicographic comparison of `t1` and `t2`, using the given character ordering `cmp`.
  public func compareWith(
    t1 : Text,
    t2 : Text,
    cmp : (Char, Char)-> { #less; #equal; #greater })
    : { #less; #equal; #greater } {
    let cs1 = t1.chars();
    let cs2 = t2.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, null) { return #equal };
        case (null, ?_) { return #less };
        case (?_, null) { return #greater };
        case (?c1, ?c2) {
          switch (Char.compare(c1, c2)) {
            case (#equal) { }; // continue
            case other { return other; }
          }
        }
      }
    }
  };


}
