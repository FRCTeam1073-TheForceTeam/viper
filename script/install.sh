#!/bin/sh

set -e

./script/software-install.sh
./script/permissions.sh
./script/apache-config.sh
