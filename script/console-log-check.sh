#!/bin/bash

set -e

files="$@"
if [ $# -eq 0 ]
then
	files=`git ls-files`
fi

status=0

for file in $files
do
	if echo $file | grep -vE 'jquery|\.min\.' | grep -Eq '\.js$' && grep -Eq '^\s*console\.log' "$file"
	then
		grep -EHn '^\s*console\.log' "$file"
		status=1
	fi
done

if [ $status -ne 0 ]
then
	echo "ERROR: found console.log debugging"
fi

exit $status
