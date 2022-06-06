/// Low-level interface to the Internet Computer.
///
/// **WARNING:** This low-level API is **experimental** and likely to change or even disappear.

import Prim "mo:⛔";

module {

  /// Calls ``canister``'s update or query function, `name`, with the binary contents of `data` as IC argument.
  /// Returns the response to the call, an IC _reply_ or _reject_, as a Motoko future:
  ///
  /// * The message data of an IC reply determines the binary contents of `reply`.
  /// * The error code and textual message data of an IC reject determines the future's `Error` value.
  ///
  /// Note: `call` is an asynchronous function and can only be applied in an asynchronous context.
  public let call : (canister : Principal, name : Text, data : Blob) ->
     async (reply : Blob) = Prim.call_raw;

  /// Given an IC performance counter, `counter`, and computation, `comp`,
  /// measures the cost of performing computation `comp()`.
  /// Returns the difference between the state of `counter` before and after executing `comp()`.
  /// NB: Currently, the only available counter is `0`,
  /// measuring executed wasm instructions.
  /// (see [Performance Counter](https://internetcomputer.org/docs/current/references/ic-interface-spec#system-api-performance-counter))
  public func measureCounter(counter : Nat32) : (comp : () -> ()) -> Nat64 {
    func (comp) {
      let pre = Prim.performanceCounter(counter);
      comp();
      let post = Prim.performanceCounter(counter);
      post - pre
    }
  }
}
