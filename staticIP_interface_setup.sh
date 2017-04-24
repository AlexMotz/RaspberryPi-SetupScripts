#!/bin/bash

echo "Static IP Interface Setup Tool"

# ---------- Check if user is root ----------
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi
# -------------------------------------------
echo

ifconfig

echo
echo -e "Enter Interface Name: \c "
read  INTERFACE_NAME

echo -e "Enter Static IP Address: \c "
read  STATIC_IP

INTERFACE_CONFIG='/etc/network/Interfaces'


line1="\nauto $INTERFACE_NAME"
echo $line1 >> $INTERFACE_CONFIG

line2="iface $INTERFACE_NAME inet static"
echo $line2 >> $INTERFACE_CONFIG

address="address $STATIC_IP"
echo $address >> $INTERFACE_CONFIG


NETMASK="255.255.255.0"
NETWORK="192.168.1.255"
BROADCAST="192.168.1.255"
GATEWAY="192.168.1.1"


echo "netmask $NETMASK" >> $INTERFACE_CONFIG
echo "network $NETWORK" >> $INTERFACE_CONFIG
echo "broadcast $BROADCAST" >> $INTERFACE_CONFIG
echo "gateway $GATEWAY" >> $INTERFACE_CONFIG

echo
echo "Restarting Interface"
ifdown $INTERFACE_NAME
ifdown $INTERFACE_NAME
ifup $INTERFACE_NAME

ifconfig
echo "Setup Complete!"
