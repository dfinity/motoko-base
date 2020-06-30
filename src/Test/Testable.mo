/// Things we can compare in tests
///
/// This module contains the `Testable<A>` abstraction, which bundles
/// `toText` and `equals` for a type `A` so we can use them as "expected"
/// values in tests.
/// It also contains a few helpers to build `Testable`'s for compound types
/// like Arrays and Optionals. If you want to test your own objects or control
/// how things are printed compared in your own tests you'll need to create
/// your own `Testable`'s.
/// ```motoko
/// import T "Testable";
///
/// type Person = { name : Text, surname : ?Text };
/// // Helper
/// let optText : Testable<(?Text)> = T.optionalTestable(T.textTestable)
/// let testablePerson : Testable<Person> = {
///    display = func (person : Person) : Text =
///        person.name # " " #
///        optText.display(person.surname)
///    equals = func (person1 : Person, person2 : Person) : Bool =
///        person1.name == person2.name and
///        optText.equals(person1.surname, person2.surname)
/// }
/// ```
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Int "mo:base/Int";
import List "mo:base/List";
import Nat "mo:base/Nat";

module {
    /// Packs up all the functions we need to compare and display values under test
    public type Testable<A> = {
        display : A -> Text;
        equals : (A, A) -> Bool
    };

    /// A value combined with its `Testable`
    public type TestableItem<A> = {
        display : A -> Text;
        equals : (A, A) -> Bool;
        item : A;
    };

    public let textTestable : Testable<Text> = {
        // TODO Actually escape the text here
        display = func (text : Text) : Text = "\"" # text # "\"";
        equals = func (t1 : Text, t2 : Text) : Bool = t1 == t2
    };

    public func text(t : Text) : TestableItem<Text> = {
        item = t;
        display = textTestable.display;
        equals = textTestable.equals;
    };

    public let natTestable : Testable<Nat> = {
        display = func (nat : Nat) : Text = Nat.toText nat;
        equals = func (n1 : Nat, n2 : Nat) : Bool = n1 == n2
    };

    public func nat(n : Nat) : TestableItem<Nat> = {
        item = n;
        display = natTestable.display;
        equals = natTestable.equals;
    };

    public let intTestable : Testable<Int> = {
        display = func (n : Int) : Text = Int.toText n;
        equals = func (n1 : Int, n2 : Int) : Bool = n1 == n2
    };

    public func int(n : Int) : TestableItem<Int> = {
        item = n;
        display = intTestable.display;
        equals = intTestable.equals;
    };

    public let boolTestable : Testable<Bool> = {
        display = func (n : Bool) : Text = Bool.toText n;
        equals = func (n1 : Bool, n2 : Bool) : Bool = n1 == n2
    };

    public func bool(n : Bool) : TestableItem<Bool> = {
        item = n;
        display = boolTestable.display;
        equals = boolTestable.equals;
    };

    public func arrayTestable<A>(testableA : Testable<A>) : Testable<[A]> = {
        display = func (xs : [A]) : Text =
            "[" # joinWith(Array.map<A, Text>(xs, testableA.display), ", ") # "]";
        equals = func (xs1 : [A], xs2 : [A]) : Bool =
            Array.equal(xs1, xs2, testableA.equals)
    };

    public func array<A>(testableA : Testable<A>, xs : [A]) : TestableItem<[A]> = {
        let testableAs = arrayTestable(testableA);
        {
            item = xs;
            display = testableAs.display;
            equals = testableAs.equals;
        };
    };

    public func listTestable<A>(testableA : Testable<A>) : Testable<List.List<A>> = {
        display = func (xs : List.List<A>) : Text =
          // TODO fix leading comma
            "[" #
            List.foldLeft(xs, "", func(acc : Text, x : A) : Text =
                acc # ", " # testableA.display(x)
            ) #
            "]";
        equals = func (xs1 : List.List<A>, xs2 : List.List<A>) : Bool =
            List.equal(xs1, xs2, testableA.equals)
    };

    public func list<A>(testableA : Testable<A>, xs : List.List<A>) : TestableItem<List.List<A>> = {
        let testableAs = listTestable(testableA);
        {
            item = xs;
            display = testableAs.display;
            equals = testableAs.equals;
        };
    };

    public func optionalTestable<A>(testableA : Testable<A>) : Testable<?A> = {
        display = func (x : ?A) : Text = switch(x) {
            case null "null";
            case (?a) "(?" # testableA.display(a) # ")"
        };
        equals = func (x1 : ?A, x2 : ?A) : Bool = switch(x1) {
            case null switch(x2) {
                case null true;
                case _ false;
            };
            case (?x1) switch(x2) {
                case null false;
                case (?x2) testableA.equals(x1, x2);
            };
        };
    };

    public func optional<A>(testableA : Testable<A>, x : ?A) : TestableItem<?A> = {
        let testableOA = optionalTestable(testableA);
        {
            item = x;
            display = testableOA.display;
            equals = testableOA.equals;
        };
    };

    public func tuple2Testable<A, B>(ta : Testable<A>, tb : Testable<B>) : Testable<(A, B)> = {
      {
          display = func ((a, b) : (A, B)) : Text =
              "(" # ta.display(a) # ", " # tb.display(b) # ")";
          equals = func((a1, b1) : (A, B), (a2, b2) : (A, B)) : Bool =
              ta.equals(a1, a2) and tb.equals(b1, b2);
      }
    };

    public func tuple2<A, B>(ta : Testable<A>, tb : Testable<B>, x : (A, B)) : TestableItem<(A, B)> = {
      let testableTAB = tuple2Testable(ta, tb);
      {
          item = x;
          display = testableTAB.display;
          equals = testableTAB.equals;
      }
    };

    func joinWith(xs : [Text], sep : Text) : Text {
        let size = xs.size();

        if (size == 0) return "";
        if (size == 1) return xs[0];

        var result = xs[0];
        var i = 0;
        label l loop {
            i += 1;
            if (i >= size) { break l; };
            result #= sep # xs[i]
        };
        result
    };
}
