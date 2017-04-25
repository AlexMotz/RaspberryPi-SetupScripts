#!/bin/bash

echo "Chrony - TimeSync Server | Setup"

# ----------------- Check if user is root ----------------
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

# ------- Check if system is connected to Internet -------
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
        echo "Success | System is Connected to Internet"
else
        echo "FAIL | System is not Connected to Internet"
        echo "Terminating - TimeSync Client Setup"
        exit 1
fi
# --------------------------------------------------------

echo "** System - Update and Upgrade **"
apt-get update
apt-get upgrade -y


echo "** Stopping NTP Daemon**"
NTP_SYS_PATH='/etc/init.d/ntp'
$NTP_SYS_PATH stop


echo "** Installing Chrony **"
apt-get install chrony -y
echo "** Chrony Install Complete **"


echo "noSYNC | Current SetTime: $(date)"


echo "** Creating Chrony TimeSync Client Config File **"
CHRONY_CONFIG_FILE_PATH='/etc/chrony/chrony.conf'

# ---------- Begin Config File ----------
cat > $CHRONY_CONFIG_FILE_PATH << EOF
driftfile /var/lib/chrony/chrony.drift

logdir /var/log/chrony
log measurements statistics tracking

local stratum 8
manual

allow

smoothtime 400 0.01
rtcsync

EOF
# ----------- End Config File -----------


chmod 644 $CHRONY_CONFIG_FILE_PATH


# --------- Set timezone to UTC ---------
echo "Etc/UTC" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata


echo "** Restarting Chrony... **"
systemctl restart chrony
echo "** Chrony Started! **"
echo

echo "NTP Server <-> Client"
sleepTime="0.1"
echo -ne 'Syncing [#         ]\r'
sleep $sleepTime
echo -ne 'Syncing [##        ]\r'
sleep $sleepTime
echo -ne 'Syncing [###       ]\r'
sleep $sleepTime
echo -ne 'Syncing [####      ]\r'
sleep $sleepTime
echo -ne 'Syncing [#####     ]\r'
sleep $sleepTime
echo -ne 'Syncing [######    ]\r'
sleep $sleepTime
echo -ne 'Syncing [#######   ]\r'
sleep $sleepTime
echo -ne 'Syncing [########  ]\r'
sleep $sleepTime
echo -ne 'Syncing [######### ]\r'
sleep $sleepTime
echo -ne 'Syncing [##########]\r'
echo -ne '\n'
echo
echo

echo "SYNC | Datetime: $(date)"
echo
echo "--------------------------------------------------"
echo

chronyc sources

echo
echo "--------------------------------------------------"
echo

chronyc tracking

echo
echo "Chrony Server | Setup Complete!"
