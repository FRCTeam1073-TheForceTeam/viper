#!/bin/sh

set -e

exitStatus=0

if [ ! -e www/local.css ]
then
	echo
	cp -v ./script/example.css ./www/local.css
	echo "Created www/local.css file"
	echo "Please edit it and re-run this script"
	exitStatus=1
fi

if [ ! -e www/local.js ]
then
	echo
	cp -v ./script/example.js ./www/local.js
	echo "Created www/local.js file"
	echo "Please edit it and re-run this script"
	exitStatus=1
fi

if [ ! -e local.conf ]
then
	echo
	cp -v ./script/example.conf ./local.conf
	echo "Created local.conf file"
	echo "Please edit it and re-run this script"
	exitStatus=1
fi

exit $exitStatus
