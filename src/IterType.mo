/// Iterator type -- break cycle module def

module {
  public type Iter<T> = {next : () -> ?T};
}
