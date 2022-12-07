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
	libhtml-escape-perl \
	perl \
	;
