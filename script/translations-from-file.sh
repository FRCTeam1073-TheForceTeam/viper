#!/bin/bash

set -e

lang=en
file=''

for arg in "$@"
do
	case $arg in
		*.js )
			file=$arg;;
		* )
			lang=$arg;;
	esac
done

if [ "z$file" == "z" ]
then
	echo "No .js file argument specified"
	exit 1
fi

grep "$lang:" "$file" | sed -E "s/^[^']*'//g;s/'.*/\n/g;s/­//g"
