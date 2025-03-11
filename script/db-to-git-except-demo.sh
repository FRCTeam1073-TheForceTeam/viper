#!/bin/bash

set -e

VERBOSE=1
QUIET="--quiet"
COMMIT=1

for arg in "$@"
do
	case $arg in
		"-q"|"--quiet" )
		VERBOSE=0
		QUIET="--quiet";;
		"-v"|"--verbose")
		VERBOSE=1
		QUIET="";;
		"--nocommit" )
		COMMIT=0;;
		* )
		echo "Unknown argument $arg"
		exit 1;;
esac
done

verboseCommand(){
	if [ "$VERBOSE" -eq 1 ]
	then
		"$@"
	else
		"$@" > /dev/null
	fi
}

veryVerboseCommand(){
	if [ "z$QUIET" == "z" ]
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

		verboseCommand echo "CLEANING: $site"
		git checkout $QUIET .
		git clean -d -f -x $QUIET .
		verboseCommand echo "UPDATING: $site"
		git pull $QUIET

		if [[ "$site" == *demo* ]]
		then
			cd ../..
			verboseCommand echo "DELETING: $VIPER_DB_SITE"
			./script/db-delete-site.pl
			verboseCommand echo "IMPORTING: $site"
			veryVerboseCommand ./script/db-import-site.sh "$site"
			cd "$site"
		else
			verboseCommand echo "REMOVING FILES $site"
			rm -f *.csv *.png *.js *.css */*.*
			verboseCommand echo "EXPORTING $site"
			cd ../..
			veryVerboseCommand ./script/db-export-site.pl "$site"
			cd "$site"
			if [ -z "$(git status --porcelain)" ]
			then
				verboseCommand echo "NOTHING TO COMMIT: $site"
			else
				verboseCommand echo "COMMITING $site"
				git add --all .
				if [ "$COMMIT" -eq 0 ]
				then
					verboseCommand git status
					echo "DID NOT COMMIT $site"
				else
					git commit $QUIET . -m 'exported from site'
					git push $QUIET
				fi
			fi
		fi
	fi
	cd ../..
done
