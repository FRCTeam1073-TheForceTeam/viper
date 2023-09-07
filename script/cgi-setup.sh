#!/bin/bash

set -e

if [ -e /c/xampp/perl/bin/perl.exe ]
then
	PERL=C:/xampp/perl/bin/perl.exe
elif [ -e /usr/bin/perl ]
then
	PERL=/usr/bin/perl
else
	echo "Could not find perl installation"
	exit 1
fi

base=`pwd`

find www -name '*.cgi' -exec rm {} \;

for src in `find cgi/ -name *.cgi`
do
	dst="${src/cgi/www}"
	dstdir="${dst%/*}"
	mkdir -p "$dstdir"

	if [ "$PERL" == "/usr/bin/perl" ]
	then
		dstfile=${dst##*/}
		srcdir="${src%/*}/"
		srcrel=`echo "$srcdir" | sed -E 's|[^/]+/|../|g'`
		cd "$dstdir"
		ln -fs "$srcrel$src" "$dstfile"
		cd "$base"
	else
		sed -E "s|^#!/usr/bin/perl|#!$PERL|g" "$src" > "$dst"
	fi
	chmod a+x "$dst"
done
