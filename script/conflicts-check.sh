#!/bin/bash

set -e

files="$@"
if [ $# -eq 0 ]
then
	files=`git ls-files`
fi

if grep -EIq '^(<{5}|>{5})' $files
then
	grep -EI '^(<{5}|>{5})' $files
	echo "Unresolved conflicts should not be committed"
	exit 1
fi
exit 0
