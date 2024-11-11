#!/bin/bash

set -e

season="$1"

if [ "z$season" == "z" ]
then
	echo "Expected season as argument eg 2024"
	exit 1
fi

if ! echo "$season" | grep -Eq '^20[0-9]{2}(-[0-9]{2})?$'
then
	echo "Expected season to match ^20[0-9]{2}(-[0-9]{2})?$"
	exit 1
fi

if [ ! -d www/$season ]
then
	echo "Directory not found: www/$season"
	exit 1
fi

( grep -oE '(scout|aggregate)\.[a-z_]+\b' www/$season/aggregate-stats.js | sed -E 's/(scout|aggregate)\.//g'; ack -i '\<(?:input|textarea)[^\>]+\>' www/$season/scout.html | grep -oE "name\\s*=\\s*[\\'\\\"]?([A-Za-z0-9\\-_]+)[\\'\\\"]?\\b" | sed 's/name=//g') | sort | uniq | while read var
do
	if ! grep -Eq "^\s*$var\s*\:\s*\{" www/$season/aggregate-stats.js
	then
		type="%"
		if echo $var | grep -qE '(min|max|fastest|slowest|most|least|best|worst)'
		then
			type="minmax"
		elif echo $var | grep -qE '(score|place|shot|shoot|foul|count)'
		then
			type="avg"
		elif echo $var | grep -qE '(created|modified)'
		then
			type="datetime"
		elif echo $var | grep -qE '(scouter|comments|match|team)'
		then
			type="text"
		fi
		name=`echo "$var" | sed 's/_/ /g' | sed 's/.*/\u&/'`
		echo -e "$var:{\n    name: '$name',\n    type: '$type'\n},"
	fi
done
