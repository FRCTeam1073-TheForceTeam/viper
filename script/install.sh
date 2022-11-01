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
    libcgi-pm-perl \
    libfile-flock-perl \
    libhtml-escape-perl \
    perl \
    ;

# Allow git commands to run from the webserver
# Used for generating service worker hash
if [ ! -e /var/www/.gitconfig ]
then
    if [ ! grep -q `pwd` $HOME/ ]
    sudo -u www-data git config --global --add safe.directory `pwd`
fi
