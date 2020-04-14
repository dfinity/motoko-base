The motoko base library
=======================

This repository contains the Motoko base library.

Usage
-----

If you are installing Motoko through the DFINITY SDK releases, then this base
library is already included.

If you build your project using the [vessel package manager] then, TODO

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

Documentation
-------------

The documentation can be generated in `doc/` by running

    make

which creates `_out/index.html`. This requires `asciidoctor` and `perl` to be
installed.

Note that the documentation tool relies on a very peculiar coding convention.
See `doc/README.md` for details. This convention is not necessarily the best
convention!
