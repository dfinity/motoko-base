/// Composable assertions
///
/// This module contains functions for building and combining `Matcher`s that
/// can be used to build up assertions for testing.
/// ```motoko
/// import M "Matchers";
/// import T "Testable";
///
/// assertThat(5 + 5, M.equals(T.nat(10)));
/// assertThat(5 + 5, M.allOf<Nat>([M.greaterThan(8), M.lessThan(12)]));
/// assertThat([1, 2], M.array([M.equals(T.nat(1)), M.equals(T.nat(2))]));
/// ```
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import T "Testable";

module {
    /// A `Matcher` is a composable way of building up assertions for tests
    public type Matcher<A> = {
        matches : (item: A) -> Bool;
        describeMismatch : (item : A, description : Description) -> ();
    };

    /// Matches an `item` against a matcher and traps with an error if the
    /// matcher fails. This is primarily for experimentation and one-offs. For
    /// writing an actual test suite you probably want to use the functions in
    /// [Suite](Suite.html).
    public func assertThat<A>(item : A, matcher : Matcher<A>) {
        if (not matcher.matches(item)) {
            let description = Description();
            matcher.describeMismatch(item, description);
            Debug.print(description.toText());
            assert(false)
        }
    };

    /// Turns a `Matcher` for `A`s into a `Matcher` for `B`s by using `f` as an adapter.
    // TODO Maybe call this adapt?
    public func contramap<A, B>(matcher : Matcher<A>, f : B -> A) : Matcher<B> = {
        matches = func (item : B) : Bool = matcher.matches(f(item));
        describeMismatch = func (item : B, description : Description) {
            matcher.describeMismatch(f(item), description)
        }
    };

    /// `Matcher`s describe match failures by inserting them into a `Description`.
    // TODO More complicated descriptions? Maybe a bit more structure than raw text?
    public class Description() {
        var message : Text = "";

        public func appendText(text : Text) {
            message := message # text;
        };

        public func toText() : Text = message;
    };

    /// Always matches, useful if you don’t care what the object under test is
    public func anything<A>() : Matcher<A> = {
        matches = func (item : A) : Bool = true;
        describeMismatch = func (item : A, description : Description) = ();
    };

    /// Decorator that allows adding a custom failure description
    public func describedAs<A>(msg : Text, matcher : Matcher<A>) : Matcher<A> = {
        matches = func (item : A) : Bool = matcher.matches(item);
        describeMismatch = func (item : A, description : Description) = {
            description.appendText(msg);
        };
    };

    /// Matches values equal to an expected `Testable`
    public func equals<A>(expected : T.TestableItem<A>) : Matcher<A> = {
        matches = func (item : A) : Bool = expected.equals(expected.item, item);
        describeMismatch = func (item : A, description : Description) = {
            description.appendText(expected.display(item) # " was expected to be " # expected.display(expected.item));
        };
    };

    /// Matches values greater than `expected`
    public func greaterThan<A <: Int>(expected : Int) : Matcher<A> = {
        matches = func (item : A) : Bool = item > expected;
        describeMismatch = func (item : A, description : Description) = {
            description.appendText(Int.toText(expected) # " was expected to be greater than " # Int.toText(item));
        };
    };

    /// Matches values greater than or equal to `expected`
    public func greaterThanOrEqual<A <: Int>(expected : Int) : Matcher<A> = {
        matches = func (item : A) : Bool = item >= expected;
        describeMismatch = func (item : A, description : Description) = {
            description.appendText(Int.toText(expected) # " was expected to be greater than or equal to " # Int.toText(item));
        };
    };

    /// Matches values less than `expected`
    public func lessThan<A <: Int>(expected : Int) : Matcher<A> = {
        matches = func (item : A) : Bool = item < expected;
        describeMismatch = func (item : A, description : Description) = {
            description.appendText(Int.toText(expected) # " was expected to be less than " # Int.toText(item));
        };
    };

    /// Matches values less than or equal to `expected`
    public func lessThanOrEqual<A <: Int>(expected : Int) : Matcher<A> = {
        matches = func (item : A) : Bool = item <= expected;
        describeMismatch = func (item : A, description : Description) = {
            description.appendText(Int.toText(expected) # " was expected to be less than or equal to " # Int.toText(item));
        };
    };

    /// Matches if all matchers match, short circuits (like `and`)
    public func allOf<A>(matchers : [Matcher<A>]) : Matcher<A> = {
        matches = func (item : A) : Bool {
            for (matcher in matchers.vals()) {
                if (not matcher.matches(item)) {
                    return false;
                }
            };
            return true;
        };
        describeMismatch = func (item : A, description : Description) = {
            var first = true;
            for (matcher in matchers.vals()) {
                if (not matcher.matches(item)) {
                    if (first) {
                        first := false;
                    } else {
                        description.appendText("\nand ");
                    };
                    matcher.describeMismatch(item, description);
                };
            };
        };
    };

    /// Matches if any matchers match, short circuits (like `or`)
    public func anyOf<A>(matchers : [Matcher<A>]) : Matcher<A> = {
        matches = func (item : A) : Bool {
            for (matcher in matchers.vals()) {
                if (matcher.matches(item)) {
                    return true;
                }
            };
            return false;
        };
        describeMismatch = func (item : A, description : Description) = {
            var first = true;
            for (matcher in matchers.vals()) {
                if (not matcher.matches(item)) {
                    if (first) {
                        first := false;
                    } else {
                        description.appendText("\nor ");
                    };
                    matcher.describeMismatch(item, description);
                };
            };
        };
    };

    /// Matches if the wrapped matcher doesn’t match and vice versa
    public func not_<A>(matcher : Matcher<A>) : Matcher<A> = {
        matches = func (item : A) : Bool = not matcher.matches(item);
        describeMismatch = func (item : A, description : Description) = {
            // Do I need to return a `Matcher<Testable<A>>` instead?
            // Would be a little unfortunate
            description.appendText("Shouldn't have matched.");
        };
    };

    /// Test an array’s elements against an array of matchers
    public func array<A>(matchers : [Matcher<A>]) : Matcher<[A]> = {
        matches = func (items : [A]) : Bool = {
            if (items.size() != matchers.size()) {
                return false;
            };
            for (ix in items.keys()) {
                if (not matchers[ix].matches(items[ix])) {
                    return false
                }
            };
            return true;
        };
        describeMismatch = func (items : [A], description : Description) = {
            if (items.size() != matchers.size()) {
                description.appendText(
                    "Length mismatch between " #
                    Nat.toText(items.size()) #
                    " items and " #
                    Nat.toText(matchers.size()) #
                    " matchers"
                );
                return;
            };
            for (ix in items.keys()) {
                if (not matchers[ix].matches(items[ix])) {
                    description.appendText("At index " # Nat.toText(ix) # ": ");
                    matchers[ix].describeMismatch(items[ix], description);
                    description.appendText("\n");
                }
            };
        };
    };

    /// Tests that a value is not-null
    public func isSome<A>() : Matcher<?A> = {
        matches = func (item : ?A) : Bool = Option.isSome(item);
        describeMismatch = func (item : ?A, description : Description) {
            description.appendText("expected some value, but got `null`");
        };
    };

    /// Tests that a value is null
    public func isNull<A>() : Matcher<T.TestableItem<?A>> = {
        matches = func (testable : T.TestableItem<?A>) : Bool = Option.isNull(testable.item);
        describeMismatch = func (testable : T.TestableItem<?A>, description : Description) {
            switch (testable.item) {
                case null ();
                case (?i) description.appendText("expected `null`, but got " # testable.display(?i));
            }
        };
    };

}
