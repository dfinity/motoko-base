
* Added `explode` to `Int16`/`32`/`64`, `Nat16`/`32`/`64`, slicing fixed-length numbers into constituent bytes (#716).

## 0.14.9

(nothing)

## 0.14.8

(nothing)

## 0.14.7

* Deprecated `ExperimentalCycles.add`, use a parenthetical `(with cycles = <amount>) <send>` instead (#703).

## 0.14.6

(nothing)

## 0.14.5

(nothing)

## 0.14.4

* Added `burn : <system>Nat -> Nat` to `ExperimentalCycles` (#699).
* Added `ExperimentalInternetComputer.subnet : () -> Principal` (#700).

## 0.14.3

* Added `isRetryPossible : Error -> Bool` to `Error` (#692).
* Made `ExperimentalInternetComputer.replyDeadline` to return
  an optional return type (#693).
  _Caveat_: Breaking change (minor).
* Added `isReplicated : () -> Bool` to `ExperimentalInternetComputer` (#694).

## 0.14.2

(nothing)

## 0.14.1

(nothing)

## 0.14.0

(nothing)

## 0.13.7

(nothing)

## 0.13.6

(nothing)

## 0.13.5

* Added `Text.fromList` and `Text.toList` functions (#676).

* Added `Text.fromArray` and `Text.fromVarArray` functions (#674).

* Added `replyDeadline` to `ExperimentalInternetComputer` (#677).

## 0.13.4

* Breaking change (minor): `Float.format(#hex)` is no longer supported. 
  This is because newer versions of Motoko (such as with enhanced orthogonal persistence)
  rely on the Rust-native formatter that does not offer this functionality.
  It is expected that this formatter is very rarely used in practice.

* Formatter change (minor): The text formatting of `NaN`, positive or negative, 
  will be `NaN` in newer Motoko versions, while it was `nan` or `-nan` in older versions.

## 0.13.3

* Add modules `OrderedMap` and `OrderedSet` to replace `RBTree` (thanks to Serokell) (#662).

## 0.13.2

(nothing)

## 0.13.1

(nothing)

## 0.13.0

(nothing)

## 0.12.1

* Add `Iter.concat` function (thanks to AndyGura) (#650).

## 0.12.0

(nothing)

## 0.11.3

(nothing)

## 0.11.2

* Uppercase `Result` variants (#626).

* Un-deprecated `Array.append` (#630).

## 0.11.1

(nothing)

## 0.11.0

* Added `Option.equal` function (thanks to ByronBecker) (#615).

* Invoking `setTimer`, `ExperimentalCycles.add`, etc. now requires `system` capability (#622).

* Added `bitshiftLeft`/`bitshiftRight` to `Nat` (#613).
  This was added as part of #622 by mistake.

## 0.10.4

(nothing)

## 0.10.3

* Added `ExperimentalInternetComputer.performanceCounter` function to get the raw performance counters (#600).

* Added `Array.take` function to get some prefix of an array (#587).

* Deprecated `TrieSet.mem` in favor of `TrieSet.contains` (#576).

* bugfix: `Array.chain(as, f)` was incorrectly trapping when `f(a)` was an empty array (#599).
