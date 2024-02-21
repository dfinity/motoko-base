## 0.10.3
* Added `ExperimentalInternetComputer.performanceCounter` function to get the raw performance counters (#600).

* Added `Array.take` function to get some prefix of an array (#587).

* Deprecated `TrieSet.mem` in favor of `TrieSet.contains` (#576).

* bugfix: `Array.chain(as, f)` was incorrectly trapping when `f(a)` was an empty array (#599).