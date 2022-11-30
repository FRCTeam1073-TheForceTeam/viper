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

# Install software
sudo apt-get install -y \
	apache2 \
	git \
	libcgi-pm-perl \
	libfile-flock-perl \
	libhtml-escape-perl \
	perl \
	;

# Enable Apache modules
sudo a2enmod \
	cgid \
	headers \
	rewrite \
	;