Reference manual generation
===========================

This directory contains the setup to create the reference manual.

## Building

Run `./make_docs.sh`. The output is in `_out/(html|adoc)`. For accessing the `HTML` documentation you can open `_out/html/index.html` in your browser.

## Generating a DOT graph for the module structure

Requires Python3 and Graphviz, then follow the instructions in `module_graph.py`.

## Deploy to SDK website

Library docs are auto-generated to `doc-pages` branch for every PR merged in `master`. The SDK website periodically
fetches the docs from `doc-pages`.
