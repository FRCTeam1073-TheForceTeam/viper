#!/bin/bash

set -e

mkdir -p www/data
cp script/data-htaccess www/data/.htaccess
if ! grep -qE 'MYSQL_[A-Z]+=\"\"' local.conf
then
	echo >> www/data/.htaccess
	echo 'RewriteEngine on' >> www/data/.htaccess
	echo 'RewriteRule \/?(?:data\/)?((?:[0-9]+\/)?[^\/]+\.(?:csv|json|jpg))$ /file.cgi?file=$1' >> www/data/.htaccess
fi
