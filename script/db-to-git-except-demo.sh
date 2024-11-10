#!/bin/bash

set -e

VERBOSE=1
QUIET=""

for arg in "$@"
do
	case $arg in
		"-q" )
		   VERBOSE=0
		   QUIET="--quiet";;
		"--quiet" )
		   VERBOSE=0
		   QUIET="--quiet";;
		* )
		   echo "Unknown argument $arg"
		   exit 1;;
   esac
done

verboseCommand(){
	if [ $VERBOSE -eq 1 ]
	then
		"$@"
	else
		"$@" > /dev/null
	fi
}

for site in local.data/*/
do
	cd "$site"
	if [ -d .git ]
	then
		VIPER_DB_SITE="${site%/}"
		export VIPER_DB_SITE="${VIPER_DB_SITE##*/}"

		verboseCommand echo "UPDATING $site"
		git pull $QUIET
		git checkout $QUIET .

		if [[ "$site" == *demo* ]]
		then
			verboseCommand echo "CLEANING: $site"
			git clean -d -f -x $QUIET .
			cd ../..
			verboseCommand echo "DELETING: $VIPER_DB_SITE"
			./script/db-delete-site.pl
			verboseCommand echo "IMPORTING: $site"
			verboseCommand ./script/db-import-site.sh "$site"
		else
			verboseCommand echo "REMOVING FILES $site"
			rm -f *.csv *.png *.js *.css */*.*
			verboseCommand echo "EXPORTING $site"
			cd ../..
			verboseCommand ./script/db-export-site.pl "$site"
		fi

		cd "$site"
		if [ -z "$(git status --porcelain)" ]
		then
			verboseCommand echo "NOTHING TO COMMIT: $site"
		else
			verboseCommand echo "COMMITING $site"
			git add --all .
			git commit $QUIET . -m 'exported from site'
			git push $QUIET
		fi
	fi
	cd ../..
done
