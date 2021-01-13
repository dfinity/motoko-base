# Use like so (from the `motoko-base/` directory):
# python3 doc/module_nav.py > doc/modules/lib-nav.adoc

import glob
import os

names = []

for file in glob.glob("src/**/*.mo", recursive=True):
  module = os.path.splitext(os.path.basename(file))[0];
  names.append(module);

def sort_name(name):
    head = name.rstrip('0123456789')
    tail = name[len(head):]
    if tail:
        tail = int(tail)
    else:
        tail = 0
    return (head, tail)
  
names.sort(key=sort_name);
print("* xref:stdlib-intro.adoc[Motoko Base Library]")
for name in names:
    print(f"** xref:./{name}.adoc[{name}]")
