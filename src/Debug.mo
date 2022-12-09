/// Utility functions for debugging.
///
/// Import from the base library to use this module.
/// ```motoko name=import
/// import Debug "mo:base/Debug";
/// ```

import Prim "mo:⛔";
module {
  /// Prints `text` to output stream.
  ///
  /// NOTE: What this output stream is depends on your execution environment.
  ///
  /// ```motoko include=import
  /// Debug.print "Hello New World!"
  /// ```
  public func print(text : Text) {
    Prim.debugPrint text;
  };

  /// Causes program to trap (error) and ends execution. Prints `errorMessage`
  /// to output stream.
  ///
  /// NOTE: What this output stream is depends on your execution environment.
  ///
  /// ```motoko include=import
  /// Debug.trap "Test error message"
  /// ```
  public func trap(errorMessage : Text) : None {
    Prim.trap errorMessage;
  };
};
