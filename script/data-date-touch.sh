#!/bin/bash
set -e

for file in www/data/*.event.csv
do
	enddate=`grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}$' "$file"`
	event="${file##*/}"
	event="${event%%.*}"
	for efile in www/data/$event.*.csv
	do
		modified=`date -r "$efile" "+%Y-%m-%d"`
		diffSeconds=$(($(date -d "$enddate" +%s) - $(date -d "$modified" +%s)))
		diffSeconds=${diffSeconds##-}
		if [ $diffSeconds -gt 604800 ] # One week
		then
			echo "Setting $efile to modified at $enddate instead of $modified"
			touch -d "$enddate" "$efile"
		fi
	done
done

for file in www/data/*.csv
do
	eventYear="${file##*/}"
	eventYear="${eventYear:0:4}"
	modified=`date -r "$file" "+%Y"`
	if [ "$eventYear" != "$modified" ]
	then
		echo "Setting $file to modified at $eventYear-01-01 instead of $modified"
		touch -d "$eventYear-01-01" "$file"
	fi
done