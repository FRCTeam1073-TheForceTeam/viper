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
	if [ -f "$file" ]
	then
		if echo $file | grep -vEq '(\.(yaml|yml|svg|md|png|jpg|json)$)|jquery|\.min\.' && grep -Eq $'^\t* ' "$file"
		then
			grep -EHn $'^\t* ' "$file"
			status=1
		fi
	fi
done

if [ $status -ne 0 ]
then
	echo "ERROR: found spaces used as indentation"
fi

exit $status
