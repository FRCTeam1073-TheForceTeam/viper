#!/bin/sh

set -e

if which apt &> /dev/null
then
	# Install software
	sudo apt-get install -y \
		apache2 \
		apache2-utils \
		git \
		imagemagick \
		libcgi-pm-perl \
		libfile-flock-perl \
		libfile-slurp-perl \
		libfile-touch-perl \
		libhtml-escape-perl \
		libjson-pp-perl \
		libmime-base64-perl \
		perl \
		;
fi
