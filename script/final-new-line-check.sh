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
	if echo $file | grep -vEq '(\.(svg|png|jpg)$)|empty|jquery|\.min\.' && [[ $(tail -c1 "$file" | wc -l) -eq 0 ]]
	then
		echo "$file does not end in a new line"
		status=1
	fi
done
exit $status
