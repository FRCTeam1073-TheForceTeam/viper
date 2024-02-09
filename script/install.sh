#!/bin/sh

set -e

./script/local-conf.sh
./script/software-install.sh
DB_SETTINGS_COUNT=`grep -cE '^MYSQL_(HOST|PORT|DATABASE|USER|PASSWORD)=\".+\"' local.conf` || true
if [ $DB_SETTINGS_COUNT -ge 5 ]
then
	./script/db-schema.pl
fi
./script/htaccess-setup.sh
./script/cgi-setup.sh
./script/permissions.sh
./script/apache-config.sh
./script/static-ip-enable.sh
./script/dhcp-enable.sh
