#!/bin/bash

set -e

dir=$1

if [ "z$dir" == "z" ]
then
	echo "No directory for site specified."
	exit 1
fi

if [ -d "local.data/$dir" ]
then
	dir="local.data/$dir"
fi

if [ -d "local.data/viper$dir" ]
then
	dir="local.data/viper$dir"
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
