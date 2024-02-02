#!/bin/bash

set -e

mkdir -p www/data
cp script/data-htaccess www/data/.htaccess
DB_SETTINGS_COUNT=`grep -cE '^MYSQL_(HOST|PORT|DATABASE|USER|PASSWORD)=\".+\"' local.conf` || true
if [ $DB_SETTINGS_COUNT -ge 5 ]
then
	echo >> www/data/.htaccess
	echo 'RewriteEngine on' >> www/data/.htaccess
	echo 'RewriteRule \/?(?:data\/)?((?:[0-9]+\/)?[^\/]+\.(?:csv|json|jpg))$ /file.cgi?file=$1' >> www/data/.htaccess
fi
