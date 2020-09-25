/// Funds and units
///
/// Provides imperative operations for observing funds, transferring funds and
/// observing refunds of various units.
/// The two currently support units are `#cycle` and `#icpt`, measuring
/// computational cost and Internet Computer tokens, respectively.

/// This low-level API is experimental and likely to change, including the
/// addition of other units and alternative syntactic support for
/// manipulating funds.
///
/// Note: since unit `#cycle` is used to measure computation, the value of
/// `balance(#cycle)` generally decreases from one call to the next.

import Prim "mo:prim";
module {

  /// Units for funds: `{#cycle; #icpt}`.
  public type Unit = Prim.Unit;

  /// Returns the actor's current balance of unit `u` as `amount`.
  public let balance : (u : Unit) -> (amount : Nat64) = Prim.fundsBalance;

  /// Given `u`, returns the currently available `amount` of unit `u`.
  /// The amount available is the amount received in the current message,
  /// minus the cumulative amount `accept`ed by this message.
  /// On return to the sender, any remaining available amount is automatically
  /// refunded to the sender.
  public let available : (u : Unit) -> (amount : Nat64) = Prim.fundsAvailable;

  /// Transfers `amount` from `available(u)` to `balance(u)`,
  /// trapping on underflow.
  public let accept : (u : Unit, amount : Nat64) -> () = Prim.fundsAccept;

  /// Indicates additional `amount` of unit `u` to be transferred in
  /// the next message, i.e. evaluation of a shared function call or
  /// async expression.
  /// On message send, but not before, the total amount of units `add`ed since
  /// the last send is deducted from `balance(u)`.
  /// If this total exceeds `balance(u)`, the sender traps, aborting the send.
  ///
  /// Note: the implicit register of added amounts is reset to zero on entry to
  /// a message and after each send or resume from an await.
  public let add : (u : Unit, amount : Nat64) -> () = Prim.fundsAdd;

  /// Reports `amount` of unit `u` refunded in the last `await` of the current
  /// message, or `0` if no await has occurred yet.
  /// Calling `refunded(u)` is solely informational and does not affect,
  /// e.g. `balance(u)`.
  /// Instead, refunds are automatically added to the current balance,
  /// whether or not `refunded` is called.
  public let refunded : (u: Unit) -> (amount : Nat64) = Prim.fundsRefunded;

}
