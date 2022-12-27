# webscout

## Installation on Linux (Raspberry Pi)

1. Use git to clone the code
1. Install (see `scripts/install.sh`)
   - Apache
   - Perl
   - Perl modules
1. Configure Apache (`/etc/apache2/conf/`)
   - Set `DocumentRoot` to the `www/` directory of the code
   - Enable `AllowOverride All`
1. Give the web server permission (user/group `www-data`) to write to `www/data/`
1. Restart Apache (`sudo service apache2 restart`)


A DHCP server is also configured on the Raspberry Pi to serve IP addresses to the tablets on the private LAN. The Raspberry Pi is configured with its own static IP address (in our case, 10.73.10.73). A web browser is launched on each scouting tablet, and this IP address is entered as the URL.

## Other documentation

 - [README](../README.md)
 - [Recommended hardware](doc/hardware.md)
 - [Development Environment with Docker](doc/docker-install.md)
