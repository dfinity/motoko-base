## 0.11.1

(nothing)

## 0.11.0

* Added `Option.equal` function (thanks to ByronBecker) (#615).

* Invoking `setTimer`, `ExperimentalCycles.add`, etc. now requires `system` capability (#622)

* Added `bitshiftLeft`/`bitshiftRight` to `Nat` (#613).
  This was added as part of #622 by mistake.

## 0.10.4

(nothing)

## 0.10.3

* Added `ExperimentalInternetComputer.performanceCounter` function to get the raw performance counters (#600).

* Added `Array.take` function to get some prefix of an array (#587).

* Deprecated `TrieSet.mem` in favor of `TrieSet.contains` (#576).

* bugfix: `Array.chain(as, f)` was incorrectly trapping when `f(a)` was an empty array (#599).
