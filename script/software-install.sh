#!/bin/sh

set -e

# Install software
sudo apt-get install -y \
	apache2 \
	apache2-utils \
	git \
	imagemagick \
	libcgi-pm-perl \
	libfile-flock-perl \
	libfile-slurp-perl \
	libhtml-escape-perl \
	libjson-parse-perl \
	libmime-base64-perl \
	perl \
	;
