# webscout

This is a scouting app designed and used by FRC 1073, The Force Team from Hollis and Brookline, New Hampshire.
It is designed to collect data about each of the robots as they compete in the tournament. 
The data, such as the number of each type of point scored by each bot, is then used to inform alliance selection decisions.
It runs on as a web app on a server that can be taken to events and powered by a battery for use in the stands.

## Usage

The workflow at a tournament is:

1. The lead scouter enters the match schedule for the qualifiers.
2. Six team members connect wired devices (tablets or laptops) and load the scouting page.
3. Once the app is loaded, devices can be disconnected for watching and scouting matches. Data is stored in persistent storage on the client devices as it is collected.
4. After the qualifier matches have been completed, all devices that scouted matches reconnect to the server and upload their data.
5. A device can connect and view the stats page with alliance selection functionality.
6. Once again, that device can be disconnected and used on the field during alliance selection. 
7. Once alliances are selected, the data about that can be entered for further scouting during playoffs and finals.

## Data export

This software stores data in CSV files, which can be imported into Excel or Tableau for post-analysis. 

## Hardware

The scouting server runs on any device with a Linux, Apache, and Perl stack. Any device running a web browser can serve as a scouting device. 1073 chose energy efficient hardware that can last all day on a single charge:

- 1 Raspberry Pi Model 3
- 1 8-port switch
- 6 Samsung Galaxy Tablets
- 7 Ethernet cables
- 6 micro-USB-to-Ethernet adapters
- 1 12V-to-120V power inverter
- 1 robot battery

The scouting tablets are connected to the ethernet adapters, which allows them to be connected to the 8-port switch. The Raspberry Pi is also connected to the switch. The Raspberry Pi is powered on, and then the tablets are powered up.

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

## Development environment

The scouting server can be run for development on pretty much any Windows, Mac, or Linux computer.

1. Use git to clone the code
1. Install `docker-compose` from [docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)
1. Run `docker-compose up` (in the webscout directory)
1. Visit http://localhost:1073/
1. Make code changes.
1. Save code files.
1. Refresh web browser.
