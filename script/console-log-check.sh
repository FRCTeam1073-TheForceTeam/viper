#!/bin/bash

set -E

if find . -name *.js | xargs grep -qE '^\s*console\.log'
then
	find . -name *.js | xargs grep -En '^\s*console\.log'
	echo "ERROR: found console.log debugging"
	exit 1
fi
exit 0
