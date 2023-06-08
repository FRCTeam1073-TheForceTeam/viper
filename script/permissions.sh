#!/bin/bash

set -e

if which sudo &> /dev/null
then
	mkdir -p www/data
	# The web server needs to write to this directory
	sudo chown -R `whoami`:www-data www/data/
	sudo chmod -R ug+rw www/data/
	# Set it so that new files in that directory
	# use the same group user and permissions
	# as the directory itself
	find  www/data/ -type d -exec sudo chmod u-s,u+x,g+sx {} \;

	dir=`pwd`
	while [ "z$dir" != "z" ]
	do
		sudo chmod a+x "$dir"
		dir="${dir%/*}"
	done
fi
