#!/usr/bin/env bash
set -euo pipefail

rm -rf _out
mkdir -p _out
mo-doc --source ../src --output _out/md --format plain
node convert.js _out/md "import VersionSwitcher from '@site/src/components/VersionSwitcher';" "<VersionSwitcher />" --recursive

