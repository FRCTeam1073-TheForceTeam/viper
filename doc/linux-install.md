# Viper Installation on Linux (Raspberry Pi)

1. Use git to clone the code
1. Navigate to the viper directory on the command line
1. Run the installation script: `./script/install.sh`
   - It will start by installing software dependencies (like Apache).
   - Then it will create a configuration file: `local.conf`.
   - See the [example configuration file](../script/example.conf) for a preview.
1. Edit the configuration: `nano local.conf`
   - Most of the defaults are probably fine to start with.
   - Use the documentation comments for guidance about any setting you want to change.
1. Run the installation script again to finish up the installation: `./script/install.sh`
1. The webserver should be up and running, so you should be able to visit it: `http://localhost/` (The URL may differ depending on your chosen configuration options.)

The installation script is idempotent. That means it can be run multiple times and it will only change the things that need to be changed. If you change the configuration, rerun the installation script to apply the new configuration.

The main installation script does nothing other than call other scripts that each do a smaller piece of the installation. You can call these individual scripts one at a time if you want to have more control over the installation process.

## Files changed

The installation will touch a number of files.

 - `/etc/apache2/sites-available/viper.conf`: Apache configuration
 - `/etc/apache2/viper.auth`: User names and passwords for web app access (If you specified user names in the configuration.)
 - `/etc/netplan/50-cloud-init.yaml`: Network configuration. (If you chose a static IP address in the configuration.) A backup of the original file is kept in `./orig/`.
 - `/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg`: Disable auto network configuration. (If you chose a static IP address in the configuration.)
 - `/etc/dhcp/dhcpd.conf` DHCP server configuration. (If you chose a static IP address and DHCP address range in the configuration.)  A backup of the original file is kept in `./orig/`.

 ## DHCP

 Once the static IP address and DHCP server are enabled, the scouting server allows devices to connect to it rather than trying to connect to the wider internet. To temporarily remove the static IP and DHCP server configuration you can run:  `./script/static-ip-disable.sh && ./script/dhcp-disable.sh`

 Then you can have it connect to the wider internet again for software updates or other purposes.  The static IP and DHCP server configuration can be re-applied by rerunning the installation script.

## Other documentation

 - [README](../README.md)
 - [Recommended hardware](hardware.md)
 - [Installing on Windows with XAMPP](windows-install.md)
 - [Development Environment with Docker](docker-install.md)
 - [Translation and Internationalization](translation.md)
