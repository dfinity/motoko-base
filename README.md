The motoko base library
=======================

This repository contains the Motoko base library.

Usage
-----

If you are installing Motoko through the DFINITY SDK releases, then this base
library is already included.

If you build your project using the [vessel package manager] then, add this entry to your `package-set.json` file:

```
  {
    "name": "base",
    "repo": "https://github.com/dfinity-lab/motoko-base",
    "version": "master",
    "dependencies": []
  }
```

The package _name_ `"base"` appears when importing its modules in Motoko (e.g., `import "mo:base/Nat"`).  The _repo_ may either be your local clone path, or this public repository url, as above.  The _version_ can be any git branch name (among other things).  There are no dependencies.  See [vessel package manager] docs for more details.

[vessel package manager]: https://github.com/kritzcreek/vessel

Building/testing
----------------

In `test/`, run

    make

in `test`. This will expect `dfx` to be installed and in your `$PATH`, and call
`moc` via the wrapper in `./bin/moc`. You can add that wrapper to your PATH, if
you want.

Running the tests requires `wasmtime` to be installed.

If you installed `moc` some other way, you can instruct the `Makefile` to use
that compiler:

    make MOC=moc

Similarly, you can run `make` in `examples/`.

Documentation
-------------

The documentation can be generated in `doc/` by running

    make

which creates `_out/index.html`. This requires `asciidoctor` and `perl` to be
installed.

Note that the documentation tool relies on a very peculiar coding convention.
See `doc/README.md` for details. This convention is not necessarily the best
convention!

The `next-moc` branch
---------------------

The `next-moc` branch contains changes that make base compatible with the
in-development version of `moc`. This repositorie's public CI does _not_ run
on that branch.

External contributions are best made against `master`.

