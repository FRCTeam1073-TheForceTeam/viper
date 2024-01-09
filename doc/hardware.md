# Hardware for Viper FRC Scouting System

The total cost of all the recommend hardware is around $1200 (as of 2024), three quarters of which is the clients. The system is flexible and will run on a wide variety of hardware, so feel free to make substitutions or reuse hardware you may already own.

## Server

Because WiFi hotspots are disallowed near the field, it is best to run this application with wired ethernet. It will need to run on batteries because there are almost never power outlets in the stands. The scouting server runs on any device with a Linux, Apache, and Perl stack. The following energy efficient hardware that can last all day on a single charge and costs about $300.

 - $40 [Pi Zero W w/ case](https://www.amazon.com/Vilros-Raspberry-Starter-Power-Premium/dp/B0748MPQT4) — Small computer that runs the scouting app
 - $80 [USB Power bank](https://www.amazon.com/gp/product/B08JV4W4NY)  — Can power the system for about a week straight, automatically turns on and off based on whether or not anything is plugged into it.
 - $30 [Charging plug](https://www.amazon.com/gp/product/B08786SHXV) — To plug in the power bank for charging
 - $30 [Travel router](https://www.amazon.com/gp/product/B0777L5YN6) — Manages the network connectivity (DHCP server)
 - $18 [Case](https://www.amazon.com/gp/product/B019BIWJ8W) — Pretty good size for all the server components
 - $9 [Network switch](https://www.amazon.com/Tenda-5-port-100Mbps-Ethernet-TEF1005D/dp/B079JP94QQ) — 5v USB powered
 - $28 (4 @ $7) [USB C to Ethernet](https://www.amazon.com/gp/product/B08JGL51M4) — Plugs into newer tablets, good to have a few
 - $9 [USB Splitter](https://www.amazon.com/gp/product/B09NBVDP5Z) — Splits power to several USB components (the pi, the router, the switch) so that they can all be on one on/off switch
 - $7 [USB On/Off Switch](https://www.amazon.com/gp/product/B07CG2VGWG) — To turn the system off in one button
 - $12 [Micro USB to Ethernet](https://www.amazon.com/Smays-Realtek-Ethernet-compatible-Raspberry/dp/B009XU6N54) — Connects the Pi to the wired network (older tablets may also need these)
 - $13 [5 pack flat ethernet cable, 6 inch](https://www.amazon.com/gp/product/B01HC11V4I) — Flat cables take up little room.  Short cables are good for connecting components within the case
 - $15 [5 pack flat ethernet cable, 4 foot](https://www.amazon.com/gp/product/B01HC11V4I) — Flat cables take up little room, 4 ft cables are for connecting to tablets

## Clients

You need six clients to use the system (one for each robot on the field.)  We recommend Android tablets for clients. If you can't afford the tablets, or want to try the system out before investing, your existing Android phones and laptop computers can work with the system.  Note that Apple iPhones and iPads can't use wired USB ethernet and won't work with the system.

 - $600 (6 @ $100) [Samsung Galaxy Tab with 10.1" screen](https://www.ebay.com/sch/i.html?_nkw=Samsung+Galaxy+Tab+10.1) — Look for ones from the past few years that have USB-C.  Find a listing on ebay that sells many refurbished of the same type and get them all together.
 - $180 (6 @ $30) [Otterbox case](https://www.amazon.com/s?k=otterbox+galaxy+tab+10.1) — Get cases that match your tablets
 - $70 [Hard case](https://www.amazon.com/dp/B08ZVTV2SH) — 18" hard case can hold the tablets and charger
 - $26 [Six port USB charger](https://www.amazon.com/gp/product/B0779D7DFG) — Charge all your tablets at once (with plug for car outlet)
 - $14 (2 @ $7) [5 pack short USB-C cables](https://www.amazon.com/gp/product/B0B3RDHYYR) — Short cables eliminate cord clutter
 - $12 [12v 5A power supply](https://www.amazon.com/ALITOVE-Converter-110-220V-Cigarette-Purifier/dp/B075FPQ2YQ) — To plug the charger into a wall outlet.
 - $7 [Car outlet socket](https://www.amazon.com/gp/product/B01FJ8OXX2) — To attach the charger to a robot battery so that you can charge tablets in the stands
 - $15 [Robot battery connectors](https://www.amazon.com/dp/B0CJ8XR5PN) — To attach the charger to a robot battery so that you can charge tablets in the stands


## Other documentation

 - [README](../README.md)
 - [Installing on Linux (Like a Raspberry Pi)](linux-install.md)
 - [Development Environment with Docker](docker-install.md)
