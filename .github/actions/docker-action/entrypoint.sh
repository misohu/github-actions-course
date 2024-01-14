#!/bin/sh -l
echo "Arg received $1"
echo "Workdir:"
ls -la
name=$1
echo "$name" > name.txt
echo "$name" >> $GITHUB_OUTPUT
