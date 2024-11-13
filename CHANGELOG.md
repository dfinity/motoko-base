## 0.13.2

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
