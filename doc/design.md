# Interface Design Guide for Motoko Base Library

## General

* Follow the Motoko Style Guide for general conventions, especially wrt names and types.

* Use doc comments throughout.


## Types

### Naming

* Use `UpperCamelCase` for type and class names, including type parameters.

* Use `lowerCamelCase` for value parameter and field names, including variant cases.

* Where needed, use a `Var` prefix to distinguish mutable from immutable versions of a similar type or class name.

* Classes are encapsulated abstractions; name them after their conceptual _function_, not their _implementation_,
  except when having to distinguish multiple different implementations of the same concept (e.g., `OrderedMap` vs `HashMap`).

* In contrast, other types are transparent, so can be named either after their function or their structure where appropriate (e.g. `Tree`).

### Type Aliases

* Define type aliases for complex object or variant types or ones that are used more than once.

* Also define type aliases to clarify uses of generic types for specific purposes (e

* Do not use `T` as a type name or alias for the main type of a module.

* No need (yet) to define types for common collection interfaces.
  This can be deferred until there are practical use cases for abstracting over them.


## Functions and Methods

### General

* Use `lowerCamelCase` for functions and methods.

* The name of accessors or functions returning a value should describe that value (as a noun).
  Avoid redundant `get` prefixes, unless the function is named only `get` and is the generic getter for a container (see below).

* The name of mutators or functions performing side effects or complex operations should describe that operation (as a verb in imperative form).

* The name of predicate functions returning `Bool` should use an `is` or `has` prefix or a similar description of the tested property (as a verb in indicative form).

* Analogous functions should have the same name across different modules and classes.

* Avoid overly specialized or baroque functions.
  Every library module has a size and complexity budget.
  A use case is not a sufficient reason to add something to the library!


### Primitive Modules

* There should be a module corresponding to each primitive type.

* The following functions should be provided in these modules:

  - `equal`: compare two values
  - `compare`: compare two values (return `Order = {#less; #equal; #greater}`)
  - `toText`: convert to textual representation

* There should be a function representing each built-in operator in respective modules:

  - `neg`, `add`, `sub`, `mul`, `div`, `rem`, `pow`
  - `equal`, `notEqual`, `less`, `lessOrEqual`, `greater`, `greaterOrEqual`
  - `bitnot`, `bitand`, `bitor`, `bitshiftLeft`, `bitshiftRight`, `bitshiftRightSigned`, `bitrotLeft`, `bitrotRight`
  - `lognot`, `logand`, `logor`
  - `concat`


### Containers

* Roughly, there are 4 main classes of containers:

  - sequences: dense indexed (Nat-keyed) collection of values, e.g., lists, arrays
  - maps: sparse keyed collection of values, e.g., search trees, hash tables
  - sets: plain collection of values, e.g., sets, bags
  - singletons: container with a single value, e.g., options, results, lazy thunks, promises

* Furthermore, containers can be either mutable or immutable.
  Where it makes sense, the library should provide both versions.

* Finally, containers can be provided as either classes or procedural modules.
  For now, the preference should be on classes, since they are safer and more convenient to define and use (see below).

* Here is a list of common container operations and suggested names that ought to be consistent across containers:

  - `has`: test membership

  - `get`: read from container (usually returns option, except for arrays)

  - `put`: write to container (overwrites if entry already exists)

    Note: Choosing this instead of `set` since it works better for containers like sets and is visually easier to distinghuish from `get`.

  - `delete`: remove from collection (does nothing if not present)

  - `replace`: write to container and return old value (as for `get`)

  - `remove`: remove and return old value (as for `get`)

  - `size`: query number of entries in collection (returns `Nat`)

    TODO: Should we rename `array.len` to `array.size` for consistency?

  - `isEmpty`: check if collections is empty (may be faster than `size`)

  - `clear`: remove all entries from mutable collection

  - `clone`: copy mutable container

  - `keys`: iterator over keys of collection (same as `vals` for sets)

  - `vals`: iterator over valus of collection

  - `entries`: iterator over (key, value) pairs

  - `equal`: compare collections (where polymorphic, takes equality predicate for values)

  - `compare`: compare collections over ordered values (where polymorphic, takes ordering function for values)

  - `iterate`: map unit function over container (a.k.a. `iter` or `forEach`)

  - `map`: map function over container (may change type for polymorphic containers)

  - `fold`, `foldLeft`, `foldRight`: fold unordered or ordered collection (have the same argument order, but their callback type differs in its order of arguments)

  - `filter`: narrow collections

  - `find`: search for element based on predicate (returns option)

  - `some`, `all`: check for existential or universal property

* In addition to the above higher-order functions, keyed collections can provide variants where the parameter function takes a `(key, value)` pair:

  - `iterateEntries`
  - `mapEntries`
  - `foldEntries`, `foldEntriesLeft`, `foldEntriesRight`
  - `filterEntries`
  - `findEntry` 
  - `someEntry`, `allEntries`

* Some containers (lists, arrays, options, results), satisfy the structure of a monad and should provide respective primitives:

  - `make`: monadic unit a.k.a. return
  - `flatten`: monadic join a.k.a. concat
  - `chain`: monadic bind

  Note: Names are chosen to be more intuitive to average programmers.

* All higher-order functions put the function parameter last.


## Classes

* Abstract data types need to be provided as classes, since that currently is the only means for encapsultion.
  In particular, use classes for any type where it is desirable to maintain the liberty to change its representation in the future --
  a library type that is transparent and happens to be sharable by accident can never again be changed, since clients might already use it in a shared context.

* Classes also enable direct parameterization over values _associated_ with the instantiation type of a generic type parameter, such as hash or ordering functions that are required to be the same for all operations on a given instance (emulating "functors" or "type class dictionaries").

* The `share`/`unshare` functions of a class need to convert to a type that is designed for stability (potentially, including extensibility) and space efficiency, not for enabling efficient direct operations.
