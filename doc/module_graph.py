# Requires Python 3 and Graphviz to be installed
#
# Use like so (from the `motoko-base/` directory):
# python3 doc/module_graph.py | dot -Tsvg > module_graph.svg && xdg-open module_graph.svg
#
# If you want to create a shareable link instead:
# python3 doc/module_graph.py | dot -Tsvg > module_graph.svg && doc/make_data_uri.sh module_graph.svg

import subprocess
import glob
from collections import defaultdict

edges = defaultdict(lambda: [])

def list_deps(path):
    if path in edges:
        return
    output = subprocess.run(["bin/moc", "--print-deps", path], stdout=subprocess.PIPE, universal_newlines=True)
    for line in output.stdout.splitlines():
        if line == "mo:prim":
            continue
        dep_path = line.split()[-1]
        edges[path].append(dep_path)
        list_deps(dep_path)

for file in glob.glob("src/**/*.mo", recursive=True):
  list_deps(file)

print("digraph Base {")
for (path, deps) in edges.items():
    for dep_path in deps:
        print(f"  \"{path}\" -> \"{dep_path}\"")
print("}")
