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

tc() { set ${*,,} ; echo ${*^} ; }

( grep -E 'breakout:\s*\[' www/$season/aggregate-stats.js | grep -oE '[a-z0-9]+_[a-z0-9_]+'; grep -oE '(scout|aggregate)\.[a-z0-9_]+\b' www/$season/aggregate-stats.js | sed -E 's/(scout|aggregate)\.//g'; ack -i '\<(?:input|textarea)[^\>]+\>' www/$season/scout.html | grep -oE "name\\s*=\\s*[\\'\\\"]?([A-Za-z0-9\\-_]+)[\\'\\\"]?\\b" | sed 's/name=//g') | grep -vE '^old$'| sort | uniq | while read var
do
	if ! grep -Eq "^\s*$var\s*\:\s*\{" www/$season/aggregate-stats.js
	then
		type="%"
		if echo $var | grep -qE '(min|max|fastest|slowest|most|least|best|worst)'
		then
			type="minmax"
		elif echo $var | grep -qE '(collect|score|place|shot|shoot|foul|count)'
		then
			type="avg"
		elif echo $var | grep -qE '(created|modified)'
		then
			type="datetime"
		elif echo $var | grep -qE '(scouter|comments|match|team)'
		then
			type="text"
		fi
		name=`echo "$var" | sed -E 's/_/ /g;s/.*/\L&/; s/[a-z]*/\u&/g;s/^Tele (.*)/\1 in Teleop/g;s/^Auto (.*)/\1 in Auto/;s/Place\b/Placed/g;s/Drop\b/Dropped/g;s/Collect\b/Collected/g;'`
		echo -e "\t$var:{\n\t\ten: '$name',\n\t\ttype: '$type'\n\t},"
	fi
done
