#!/bin/sh

set -e

./script/software-install.sh
./script/permissions.sh
./script/apache-config.sh
./script/static-ip-enable.sh
./script/dhcp-enable.sh

