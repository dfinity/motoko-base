/// Error values and inspection.
///
/// The `Error` type is the argument to `throw`, parameter of `catch`.
/// The `Error` type is opaque.

import Prim "mo:⛔";

module {

  /// Error value resulting from  `async` computations
  public type Error = Prim.Types.Error;

  /// Error code to classify different kinds of user and system errors:
  /// ```motoko
  /// type ErrorCode = {
  ///   // Fatal error.
  ///   #system_fatal;
  ///   // Transient error.
  ///   #system_transient;
  ///   // Destination invalid.
  ///   #destination_invalid;
  ///   // Explicit reject by canister code.
  ///   #canister_reject;
  ///   // Canister trapped.
  ///   #canister_error;
  ///   // Future error code (with unrecognized numeric code)
  ///   #future : Nat32;
  /// };
  /// ```
  public type ErrorCode = Prim.ErrorCode;

  /// Create an error from the message with the code `#canister_reject`.
  ///
  /// Example:
  /// ```motoko
  /// import Error "mo:base/Error";
  ///
  /// throw Error.reject("Example error");
  /// ```
  public let reject : (message : Text) -> Error = Prim.error;

  /// Returns the code of an error.
  ///
  /// Example:
  /// ```motoko
  /// import Error "mo:base/Error";
  /// import Debug "mo:base/Debug";
  ///
  /// try {
  ///    throw Error.reject("Example error");
  ///  } catch (error) {
  ///    Debug.print("The error code is " # debug_show(Error.code(error)));
  /// }
  /// ```
  public let code : (error : Error) -> ErrorCode = Prim.errorCode;

  /// Returns the message of an error.
  ///
  /// Example:
  /// ```motoko
  /// import Error "mo:base/Error";
  /// import Debug "mo:base/Debug";
  ///
  /// try {
  ///    throw Error.reject("Example error");
  /// } catch (error) {
  ///    Debug.print("The error message is " # debug_show(Error.message(error)));
  /// }
  /// ```
  public let message : (error : Error) -> Text = Prim.errorMessage;

}
