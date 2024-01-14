#!/bin/sh -l
echo "Arg received $1"
echo "Workdir:"
ls -la
echo "$1" > name.txt
echo "Name received" >> $GITHUB_OUTPUT
