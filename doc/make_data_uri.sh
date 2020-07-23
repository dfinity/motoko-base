#!/usr/bin/env bash
mimetype=$(file -bN --mime-type "$1")
content=$(base64 -w0 < "$1")
echo "data:$mimetype;base64,$content"