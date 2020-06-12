/// Hash values -- types

module {
  public type Hash = Word32;

  /// The hash length, always 31.
  public let length : Nat = 31; // Why not 32?
}
