#!/bin/bash

set -E

if git ls-files -c | grep -vE '(\.(yaml|yml|svg|md|png|jpg|json)$)|jquery|\.min\.' |  xargs grep -Eq '^\t* '
then
	git ls-files -c | grep -vE '(\.(yaml|yml|svg|md|png|jpg|json)$)|jquery|\.min\.' |  xargs grep -En '^\t* '
	echo "ERROR: found spaces used as indentation"
	exit 1
fi
exit 0
