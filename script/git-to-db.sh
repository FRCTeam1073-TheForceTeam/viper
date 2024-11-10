#!/bin/bash

set -e

for site in local.data/*/
do
	cd "$site"
	if [ -d .git ]
	then
		VIPER_DB_SITE="${site%/}"
		export VIPER_DB_SITE="${VIPER_DB_SITE##*/}"
		echo "CLEANING: $site"
		git checkout .
		git clean -d -f -x .
		echo "UPDATING $site"
		git pull
		cd ../..
		echo "DELETING: $VIPER_DB_SITE"
		./script/db-delete-site.pl
		echo "IMPORTING: $site"
		./script/db-import-site.sh "$site"
		cd $site
	fi
	cd ../..
done
