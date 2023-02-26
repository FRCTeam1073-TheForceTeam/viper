#!/bin/sh

set -e

if [ -e /usr/bin/perl ]
then
	PERL=/usr/bin/perl
elif [ -e /c/xampp/perl/bin/perl.exe ]
then
	PERL=C:/xampp/perl/bin/perl.exe
else
	echo "Could not find perl installation"
	exit 1
fi

for src in `find cgi/ -name *.cgi`
do
	dst=${src/cgi/www}
	dstdir=${dst%/*}
	mkdir -p "$dstdir"
	if [ "$PERL" == "/usr/bin/perl" ]
	then
		rm -f "$dst"
		ln "$src" "$dst"
	else
		sed -E "s|^#!/usr/bin/perl|#!$PERL|g" "$src" > "$dst"
	fi
	chmod a+x "$dst"
done
