/// Debugging aids

import Prim "mo:⛔";
module {

  /// `print(t)` emits text `t` to the debug output stream.
  /// How this stream is stored or displayed depends on the
  /// execution environment.
  public let print : Text -> () = Prim.debugPrint;

}
