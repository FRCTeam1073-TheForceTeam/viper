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

mkdir -p orig/
if [ ! -e orig/etc.dhcp.dhcpd.conf ]
then
	cp -v /etc/dhcp/dhcpd.conf orig/etc.dhcp.dhcpd.conf
fi

STATIC_SUBNET="${STATIC_IP%.*}.0"
if ! grep -q $STATIC_IP /etc/dhcp/dhcpd.conf
then
	echo "script/etc.netplan.50-cloud-init.yaml --> /etc/dhcp/dhcpd.conf"
	sed -E "s/STATIC_IP/$STATIC_IP/g;s/STATIC_SUBNET/$STATIC_SUBNET/g;s/DHCP_RANGE/$DHCP_RANGE/g" script/etc.dhcp.dhcp.conf | sudo tee /etc/dhcp/dhcpd.conf > /dev/null
	sudo systemctl enable isc-dhcp-server || true
	sudo service isc-dhcp-server restart
fi
