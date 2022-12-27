# webscout

## Hardware

Because WiFi hotspots are disallowed near the field, it is best to run this application with wired ethernet.
The scouting server runs on any device with a Linux, Apache, and Perl stack. Any device running a web browser can serve as a scouting device. The following energy efficient hardware that can last all day on a single charge:

- 1 Raspberry Pi Model 3
- 1 8-port ethernet switch (powered by 5V USB)
- 6 Samsung Galaxy Tablets
- 7 Ethernet cables
- 6 Ethernet/USB adapters
- 1 12V USB power supply (4 amp)
- 1 robot battery

The scouting tablets are connected to the ethernet adapters, which allows them to be connected to the 8-port switch. The Raspberry Pi is also connected to the switch. The Raspberry Pi is powered on, and then the tablets are powered up.

## Other documentation

 - [README](../README.md)
 - [Installing on Linux (Like a Raspberry Pi)](doc/linux-install.md)
 - [Development Environment with Docker](doc/docker-install.md)
