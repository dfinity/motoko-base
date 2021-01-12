# Use like so (from the `motoko-base/` directory):
# python3 doc/module_nav.py > doc/modules/lib-nav.adoc

import glob
import os

names = []

for file in glob.glob("src/**/*.mo", recursive=True):
  module = os.path.splitext(os.path.basename(file))[0];
  names.append(module);

names.sort();
print("* xref:stdlib-intro.adoc[Motoko Base Library]")
for name in names:
    print(f"** xref:./{name}.adoc[{name}]")
