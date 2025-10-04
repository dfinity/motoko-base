The Motoko base library
=======================

> **Important update:** The Motoko `base` library has been replaced by the official [`core`](https://github.com/dfinity/motoko-core) package. New projects should use `core` instead of `base`.
>
> - [GitHub repository](https://github.com/dfinity/motoko-core)
> - [Core documentation](https://internetcomputer.org/docs/motoko/core)
> - [Core Mops package](https://mops.one/core)
> - [Migration guide from `base` to `core`](https://internetcomputer.org/docs/motoko/base-core-migration)

This repository contains the Motoko base library. It is intended to be used with the [`moc` compiler](https://github.com/dfinity/motoko) (and tools that wrap it, like `dfx`).

Usage
-----

If you are installing Motoko through the DFINITY SDK releases, then this base
library is already included.

If you build your project using the [Mops package manager], run the following command to add the base package to your project:

```sh
mops add base
```

If you build your project using the [Vessel package manager] your package-set most likely already includes base, but if it doesn't or you want to override its version, add an entry like so to your `package-set.dhall`:

```
  {
    name = "base",
    repo = "https://github.com/dfinity/motoko-base",
    version = "master",
    dependencies = [] : List Text
  }
```

The package _name_ `"base"` appears when importing its modules in Motoko (e.g., `import "mo:base/Nat"`).  The _repo_ may either be your local clone path, or this public repository url, as above.  The _version_ can be any git branch or tag name (such as `version = "moc-0.8.4"`).  There are no dependencies.  See the [Vessel package manager] docs for more details.

[Mops package manager]: https://mops.one

[Vessel package manager]: https://github.com/dfinity/vessel

Building & Testing
------------------

Run the following commands to configure your local development branch:

```sh
# First-time setup
git clone https://github.com/dfinity/motoko-base
cd motoko-base
npm install

# Run tests
npm test

# Run all tests in wasi mode
npm test -- --mode wasi

# Run formatter
npm run prettier:format
```

**Note**:
- If you are using `npm test` to run the tests:
  - You don't need to install any additional dependencies.
  - The test runner will automatically download the `moc` and `wasmtime` versions specified in `mops.toml` in the `[toolchain]` section.

- If you are using `Makefile` to run the tests:
  - The test runner will automatically detect the `moc` compiler from your system path or `dfx` installation.

  - Running the tests locally also requires [Wasmtime](https://wasmtime.dev/) and [Vessel](https://github.com/dfinity/vessel) to be installed on your system.

Run only specific test files:
```sh
npm test <filter>
```

For example `npm test list` will run `List.test.mo` and `AssocList.test.mo` test files.

Run tests in watch mode:
```sh
npm test -- --watch

# useful to combine with filter when writing tests
npm test array -- --watch
```

Documentation
-------------

The documentation can be generated in `doc/` by running

```sh
./make_docs.sh
```

which creates `_out/html/index.html`.

The `next-moc` branch
---------------------

The `next-moc` branch contains changes that make base compatible with the
in-development version of `moc`. This repository's public CI does _not_ run
on that branch.

External contributions are best made against `master`.

- `master` branch is meant for the newest **released** version of `moc`
  - The CI runs on this branch
- `next-moc` branch is meant for the **in-development** version of `moc`
  - This branch is used by the [`motoko` repository](https://github.com/dfinity/motoko)'s CI

Both branches are kept in sync with each other by mutual, circular merges:
- `next-moc` is updated automatically on each push to `master` via the [sync.yml](.github/workflows/sync.yml) workflow
- `master` is updated **manually** on each release of `moc` as part of the `motoko` release process

Only *normal* merges are allowed between `master` and `next-moc`, because development is permitted on both branches.
This policy makes every PR (to either branch) visible in the history of both branches.

Contributing
------------

Please read the [Interface Design Guide for Motoko Base Library](doc/design.md) before making a pull request.
