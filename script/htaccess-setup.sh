#!/bin/bash

set -e

mkdir -p www/data

cp script/www-htaccess www/.htaccess
cp script/data-htaccess www/data/.htaccess
DB_SETTINGS_COUNT=`grep -cE '^MYSQL_(HOST|PORT|DATABASE|USER|PASSWORD)=\".+\"' local.conf` || true
if [ $DB_SETTINGS_COUNT -ge 5 ]
then
	echo >> www/.htaccess
	echo 'RewriteRule ^\/?local(?:\.background)?\.(js|css|png)$ /file.cgi?file=local.$1' >> www/.htaccess
	echo 'RewriteRule ^\/?background\.png$ /file.cgi?file=background.png' >> www/.htaccess
	echo 'RewriteRule ^\/?logo\.png$ /file.cgi?file=logo.png' >> www/.htaccess

	echo >> www/data/.htaccess
	echo 'RewriteEngine on' >> www/data/.htaccess
	echo 'RewriteRule ^\/?(?:data\/)?((?:[0-9]+\/)?[^\/]+\.(?:csv|json|jpg))$ /file.cgi?file=$1' >> www/data/.htaccess
else
	echo >> www/.htaccess
	echo 'RewriteCond %{DOCUMENT_ROOT}/local.background.png -f' >> www/.htaccess
	echo 'RewriteRule ^\/?background\.png$ /local.background.png' >> www/.htaccess
	echo >> www/.htaccess
	echo 'RewriteCond %{DOCUMENT_ROOT}/local.logo.png -f' >> www/.htaccess
	echo 'RewriteRule ^\/?logo\.png$ /local.logo.png' >> www/.htaccess
	echo >> www/.htaccess
	echo 'RewriteCond %{DOCUMENT_ROOT}/local.css !-f' >> www/.htaccess
	echo 'RewriteRule ^\/?local\.css$ /empty.css' >> www/.htaccess
	echo >> www/.htaccess
	echo 'RewriteCond %{DOCUMENT_ROOT}/local.js !-f' >> www/.htaccess
	echo 'RewriteRule ^\/?local\.js$ /empty.js' >> www/.htaccess
fi
