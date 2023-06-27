#!/usr/bin/env bash
set -euo pipefail

rm -rf _out
mkdir -p _out
mo-doc --source ../src --output _out/adoc --format adoc
mo-doc --source ../src --output _out/html --format html
mo-doc --source ../src --output _out/md --format plain
