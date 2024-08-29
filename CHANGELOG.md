## Next release

* Breaking change: `Float.format(#hex)` is no longer supported. 
  This is because newer versions of Motoko (such as with enhanced orthogonal persistence)
  rely on the Rust-native formatter that does not offer this functionality.
  It is expected that this formatter is very rarely used in practice.

* Formatter change: The text formatting of `NaN`, positive or negative, can be `NaN`, 
  `nan`, or `-nan`, depending on the Motoko version and runtime configuration.

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
