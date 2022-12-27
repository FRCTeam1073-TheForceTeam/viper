#!/bin/bash

set -e

if [ -e local.conf ]
then
    source ./local.conf
else
    cp ./script/example.conf ./local.conf
    echo "Created local.conf file"
    echo "Please edit it and re-run this script"
    exit 1
fi

if [ "z$STATIC_IP" == "z" ]
then
    echo "No static IP configured."
    exit 0
fi

if [ "z$DHCP_RANGE" == "z" ]
then
    echo "No DHCP range configured."
    exit 0
fi

if [ ! -e /etc/dhcp/dhcpd.conf ]
then
    "Could not find expected file: /etc/dhcp/dhcpd.conf"
    exit 1
fi

if [ ! -e orig/etc.dhcp.dhcpd.conf ]
then
    "Could not find expected file: orig/etc.dhcp.dhcpd.conf"
    exit 1
fi

if  grep -q $STATIC_IP /etc/dhcp/dhcpd.conf
then
    sudo cp -v orig/etc.dhcp.dhcpd.conf /etc/dhcp/dhcpd.conf
    sudo service isc-dhcp-server stop || true
    sudo systemctl disable isc-dhcp-server || true
fi
