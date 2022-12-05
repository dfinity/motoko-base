import List "mo:base/List";
import Trie "mo:base/Trie";
import Debug "mo:base/Debug";

type List<T> = List.List<T>;

/* copied because private to Trie.mo */
func lenClamp<T>(l : List<T>, max : Nat) : ?Nat {
  func rec(l : List<T>, max : Nat, i : Nat) : ?Nat {
    switch l {
      case null { ?i };
      case (?(_, t)) {
        if ( i >= max ) { null }
        else { rec(t, max, i + 1) }
      };
    }
  };
  rec(l, max, 0)
};

var s = 0;
var l = List.nil<Nat>();

while (s < 10) {
  var m = 0;
  while (m <= s + 3) {
    let o = lenClamp(l, m);
    Debug.print(debug_show ({l = List.toArray(l); m; o}));
    assert (s == List.size(l));
    assert (if (s <= m) { o == ?s} else { o == null } );
    m += 1;
  };
  l := List.push(s+1, l);
  s += 1;
}

