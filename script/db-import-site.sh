#!/bin/bash

dir=$1

if [ "z$dir" == "z" ]
then
	echo "No directory for site specified."
	exit 1
fi

if [ ! -d $dir ]
then
	echo "Not a directory: $dir"
	exit 1
fi
dir=${dir%/}
export VIPER_DB_SITE=${dir##*/}
echo $VIPER_DB_SITE

./script/db-import-file.pl $dir/*.* $dir/*/*.*
