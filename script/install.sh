#!/bin/sh

set -e

./script/local-conf.sh
./script/software-install.sh
./script/db-schema.pl
./script/htaccess-setup.sh
./script/cgi-setup.sh
./script/permissions.sh
./script/apache-config.sh
./script/static-ip-enable.sh
./script/dhcp-enable.sh
