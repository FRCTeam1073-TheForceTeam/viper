#!/bin/bash

set -e

if [ -e local.conf ]
then
	source ./local.conf
else
	./script/local-conf.sh
fi

if [ "z$STATIC_IP" == "z" ]
then
	echo "Not enabling static IP: no static IP configured."
	exit 0
fi

if [ ! -e /etc/netplan/50-cloud-init.yaml ]
then
	echo "Could not find expected file: /etc/netplan/50-cloud-init.yaml"
	exit 1
fi

mkdir -p orig/
if [ ! -e orig/etc.netplan.50-cloud-init.yaml ]
then
	cp -v /etc/netplan/50-cloud-init.yaml orig/etc.netplan.50-cloud-init.yaml
fi

if [ ! -e /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg ]
then
	sudo cp -v script/etc.cloud.cloud.cfg.d.99-disable-network-config.cfg /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
fi

STATIC_GATEWAY="${STATIC_IP%.*}.1"

if ! grep -q $STATIC_IP /etc/netplan/50-cloud-init.yaml
then
	echo "script/etc.netplan.50-cloud-init.yaml --> /etc/netplan/50-cloud-init.yaml"
	sed -E "s/STATIC_IP/$STATIC_IP/g;s/STATIC_GATEWAY/$STATIC_GATEWAY/g" script/etc.netplan.50-cloud-init.yaml | sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null
fi
