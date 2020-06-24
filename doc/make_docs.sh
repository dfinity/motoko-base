#!/usr/bin/env bash
set -euo pipefail

rm -rf _out
mkdir -p _out
../bin/mo-doc --source ../src --output _out/adoc --format adoc
../bin/mo-doc --source ../src --output _out/html --format html
