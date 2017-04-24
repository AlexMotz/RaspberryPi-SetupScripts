#!/bin/bash

echo "Revert | Chrony -> NTP | Tool"

# ---------- Check if user is root ----------
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi
# -------------------------------------------

echo "** Stopping Chrony Daemon - Removing Config Files **"
systemctl stop chrony
rm -f /etc/chrony/chrony.conf
rm -f /etc/chrony/chrony.keys
echo


echo "** Installing NTP **"
apt-get install ntp -y
echo "** NTP Install Complete **"

date 021700001996
echo "Time Set To: $(date)"
