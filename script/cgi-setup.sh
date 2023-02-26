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
	#find cgi/ -name *.cgi -exec sed -E -i 's|^#!/usr/bin/perl|#!C:/xampp/perl/bin/perl.exe|g' {} \;
	dst=${src/cgi/www}
	sed -E "s|^#!/usr/bin/perl|#!$PERL|g" "$src" > "$dst"
	chmod a+x "$dst"
done
