#!/bin/sh
set -e

if [ `whoami` == 'www-data' ]
then
    export HOME=/var/www
fi

git rev-parse HEAD
