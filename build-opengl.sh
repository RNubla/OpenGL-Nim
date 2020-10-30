#!/bin/bash
echo "Building $1 from $2"
nim c -d:mingw --out:$1 $2.nim