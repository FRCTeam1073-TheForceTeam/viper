#!/bin/sh

set -e

# Ensure the data directory exists
# This is where all CSV files with data
# from events get stored
mkdir -p www/data/
# The web server needs to write to this directory
sudo chgrp -R www-data www/data/
sudo chmod -R g+rw www/data/
# Set it so that new files in that directory
# use the same group user and permissions
# as the directory itself
sudo chmod g+s www/data/

sudo apt-get install -y \
    apache2 \
    libcgi-pm-perl \
    libfile-flock-perl \
    libhtml-escape-perl \
    perl \
    ;
