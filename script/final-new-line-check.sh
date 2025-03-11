#!/bin/bash

set -E

status=0
for file in `git ls-files -c | grep -vE '(\.(svg|png|jpg)$)|empty|jquery|\.min\.'`
do
	if [[ $(tail -c1 "$file" | wc -l) -eq 0 ]]
	then
		echo "$file does not end in a new line"
		status=1
	fi
done
exit $status
