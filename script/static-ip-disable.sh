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

if [ ! -e /etc/netplan/50-cloud-init.yaml ]
then
    "Could not find expected file: /etc/netplan/50-cloud-init.yaml"
    exit 1
fi

if [ ! -e orig/etc.netplan.50-cloud-init.yaml ]
then
    "Could not find expected file: orig/etc.netplan.50-cloud-init.yaml"
    exit 1
fi

if  grep -q $STATIC_IP /etc/netplan/50-cloud-init.yaml
then
    sudo cp -v orig/etc.netplan.50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
fi
