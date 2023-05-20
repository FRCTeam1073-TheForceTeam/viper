#!/bin/bash

set -e

if which apt &> /dev/null
then
	# When changing this list of installed software
	# PLEASE ALSO UPDATE the similar list in Dockerfile
	sudo apt-get install -y \
		apache2 \
		apache2-utils \
		git \
		imagemagick \
		libcgi-pm-perl \
		libdbi-perl \
		libfile-flock-perl \
		libfile-slurp-perl \
		libfile-touch-perl \
		libhtml-escape-perl \
		libjpeg-turbo-progs \
		libjson-pp-perl \
		libmime-base64-perl \
		libwww-perl \
		perl \
		simple-revision-control \
		;
fi
