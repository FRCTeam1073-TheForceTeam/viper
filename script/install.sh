#!/bin/sh

set -e

# Ensure the data directory exists
# This is where all CSV files with data
# from events get stored
mkdir -p www/data/
# The web server needs to write to this directory
sudo chgrp -R www-data www/data/ .git
sudo chmod -R g+rw www/data/ .git
# Set it so that new files in that directory
# use the same group user and permissions
# as the directory itself
find  www/data/ .git -type d -exec sudo chmod ug+s {} \;

sudo apt-get install -y \
	apache2 \
	git \
	libcgi-pm-perl \
	libfile-flock-perl \
	libhtml-escape-perl \
	perl \
	;

sudo chgrp www-data /var/www
sudo chmod g+w /var/www
# Allow git commands to run from the webserver
# Used for generating service worker hash
if [ ! -e /var/www/.gitconfig ] || ! grep -q `pwd` /var/www/.gitconfig
then
	echo Setting up www-data access to this git repository
	sudo -u www-data HOME=/var/www git config --global --add safe.directory `pwd`
fi
