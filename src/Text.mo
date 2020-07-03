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


  public func join(ts : Iter.Iter<Text>) : Text {
     var r = "";
     for (t in ts) {
       r #= t
     };
     return r;
  };

  public func joinWith(sep : Text, ts : Iter.Iter<Text>) : Text {
    var r = "";
    let next = ts.next;
    switch (next()) {
      case null { return r; };
      case (? t) {
        r #= t;
      }
    };
    loop {
      switch (next()) {
        case null { return r; };
        case (? t) {
          r #= sep;
          r #= t;
        }
      }
    }
  };

  public func implode(cs : Iter.Iter<Char>) : Text {
    var r = "";
    for (c in cs) {
      r #= Prim.charToText(c);
    };
    return r;
  };

  public func explode(t : Text) : Iter.Iter<Char> {
    t.chars();
  };

  public func map(t : Text, f : Char -> Char) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= Prim.charToText(f(c));
    };
    return r;
  };

  public func translate(t : Text, f : Char -> Text) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= f(c);
    };
    return r;
  };

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
                case (? c) {
                  if (p(c)) {
                    let r = field;
                    field := "";
                    state := #resume;
                    return ? r
                  }
                  else field #= Prim.charToText(c);
                };
                case null {
                  state := #done;
                  return if (field == "") null else ? field;
                }
              }
            }
          };
          case (#resume) {
            loop {
              switch (getc()) {
                case (? c) {
                  if (p(c)) {
                    let r = field;
                    field := "";
                    state := #resume;
                    return ? r
                  }
                  else field #= Prim.charToText(c);
                };
                case null {
                  state := #done;
                  return ? field;
                }
              }
            }
          }
        }
      }
    }
  };

  public func tokens(t : Text, p : Char -> Bool) : Iter.Iter<Text> {
    let fs = fields(t, p);
    object {
      public func next() : ? Text {
        switch (fs.next()) {
          case (? "") next();
          case ot ot;
        }
      }
    }
  };

  public func isPrefix(t1 : Text, t2 : Text) : Bool {
    var cs1 = t1.chars();
    var cs2 = t2.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, _) { return true };
        case (?c1, null) { return false };
        case (?c1, ?c2) {
          if (c1 != c2) return false;
        }
      }
    }
  };

  public func isSuffix(t1 : Text, t2 : Text) : Bool {
    let s1 = t1.size();
    if (s1 == 0) return true;
    let s2 = t2.size();
    if (s1 > s2) return false;
    var cs2 = t2.chars();
    var diff = s2 - s1;
    while (diff > 0)  {
      ignore cs2.next();
      diff -= 1;
    };
    let cs1 = t1.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, null) { return true };
        case (?c1, ?c2) {
          if (c1 != c2) return false;
        };
        case _ { assert false };
      }
    }
  };

  public func iter_isPrefix(cs1 : Iter.Iter<Char>, cs2 : Iter.Iter<Char>) : Bool {
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, _) { return true };
        case (?c1, null) { return false };
        case (?c1, ?c2) {
          if (c1 != c2) return false;
        }
      }
    }
  };

  public func isSubtext(t1 : Text, t2 : Text) : Bool {
    let s1 = t1.size();
    if (s1 == 0) return true;
    let s2 = t2.size();
    if (s1 > s2) return false;
    let buff = Prim.Array_init(s1, ' ');
    let cs2 = t2.chars();
    for (i in buff.keys()) {
      switch (cs2.next()) {
        case (? c) { buff[i] := c };
        case _ { assert false };
      }
    };
    var front = 0;
    var back = s1 - 1;
    loop {
      //let view = Prim.Array_tabulate<Char>(s1, func i = buff[(front+i) % s1]);
      //Prim.debugPrint(debug_show(view));
      let cs =
        object {
          var i = 0;
          public func next() : (? Char) {
            if (i < s1) {
              let c2 = buff[(front + i) % s1];
              i += 1;
              (? c2)
            }
            else null
          }
        };
      if (iter_isPrefix(t1.chars(), cs)) return true;
      back := (back + 1) % s1;
      buff[back] := switch (cs2.next()) {
        case (? c) { c };
        case _ { return false; }
      };
      front := (front + 1) % s1;
    };
    return false;
  };

  // TBR: Is this actually the same as compare above, or not ?
  public func compareAlt(t1 : Text, t2 : Text) : { #less; #equal; #greater } {
    let cs1 = t1.chars();
    let cs2 = t2.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, null) { return #equal};
        case (null, ? _) { return #less };
        case (? _, null) { return #greater };
        case (? c1, ? c2) {
          switch (Char.compare(c1, c2)) {
            case (#equal) { }; // continue
            case other { return other; }
          }
        }
      }
    }
  };

  public func collate(
    t1 : Text,
    t2 : Text,
    cmp : (Char,Char)-> { #less; #equal; #greater })
    : { #less; #equal; #greater } {
    let cs1 = t1.chars();
    let cs2 = t2.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, null) { return #equal };
        case (null, ? _) { return #less };
	case (? _, null) { return #greater };
        case (? c1, ? c2) {
          switch (Char.compare(c1, c2)) {
            case (#equal) { }; // continue
	    case other { return other; }
	  }
        }
      }
    }
  };


}
