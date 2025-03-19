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
	if [ -f "$file" ] && echo $file | grep -vE 'empty|jquery|(\.min\.)' | grep -Eq '\.(js|pl|pm|cgi)$' && ! grep -q 'use strict' "$file"
	then
		echo "No 'use strict': $file"
		status=1
	fi
	if [ -f "$file" ] && echo $file | grep -Eq '\.(sh)$' && ! grep -qE '^#?set -e$' "$file"
	then
		echo "No 'set -e': $file"
		status=1
	fi
done

if [ $status -ne 0 ]
then
	echo "ERROR: not all files specify strict"
fi

exit $status
