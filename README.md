# webscout

This is a web-based scouting app designed and used by FRC Team 1073, the Force Team. It is documented on the team website: https://www.frc1073.org/scouting-app

This scouting app uses a Raspberry Pi as the web-server, connected via ethernet to 6 scouting tablets. The tablets can be ordinary laptops, and even the Raspberry Pi web-server could be a laptop. We chose to use the Raspberry Pi and the tablets because they are more energy efficient and can last all day with one charge.

The scouting hardware layout consists of:

- 1 Raspberry Pi Model 3
- 1 8-port switch
- 6 Samsung Galaxy Tablets
- 7 Ethernet cables
- 6 micro-USB-to-Ethernet adapters
- 1 12V-to-120V power inverter
- 1 robot battery

The scouting tablets are connected to the ethernet adapters, which allows them to be connected to the 8-port switch. The Raspberry Pi is also connected to the switch. The Raspberry Pi is powered on, and then the tablets are powered up.

This software is installed on the Raspberry Pi running Ubuntu with apache2. Apache2 is configured with CGI support, and the default DocumentRoot of /var/www/html is used. /var/www/cgi-bin is configured as the 'cgi-bin' directory in apache2. The source tree for each scouting system starts at 'www', which matches /var/www. Thus, you can tar up a copy of the 'www' directory and unpack it in /var/ on the Pi (and vice versa when developing on the Pi). 

A DHCP server is also configured on the Raspberry Pi to serve IP addresses to the tablets on the private LAN. The Raspberry Pi is configured with its own static IP address (in our case, 10.73.10.73). A web browser is launched on each scouting tablet, and this IP address is entered as the URL.

This software provides the ability to scout individual robots in an FRC match and gather the data into CSV files, which can be imported into Excel or Tableau for post-analysis. The software also provides an 'Analysis' page where it calculates an Offensive Performance Rating (OPR) for each robot and sorts the teams into a very simple "pick list". Finally, the software provides a 'Match Prediction' page where teams with existing scouting data can be selected into 'red' and 'blue' alliances to compete against each other, and the software will add up the current 'OPR' of each team on each alliance and "predict" the final score of the match. 


# Software Design

This software design is based on executable "CGI" scripts that can parse URL input and produce or "print" simple HTML output. The initial design of the HTML scouting pages were created and evaluated with a browser, and then Perl scripts were written to "print" the same HTML output. Then the URL links and argument parsing code was added to make the pages interactive.

The images used in the scouting web pages are either screenshots taken from the FRC Game Manual, or simple images created with Microsoft Paint. This design can support any type of scripting language, such as javascript or python scripts, so anyone can contribute new webpages using whatever programming language that they are comfortable using.

In fact, starting with the 2022 'Rapid React' scouting app, the 'Analysis' webpage is written in javascript so that it can be loaded onto a tablet, unplugged from the network, and used by the field representative during the Alliance selection process.
