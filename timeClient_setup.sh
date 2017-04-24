#!/bin/bash

echo "Chrony - TimeSync Client | Setup"

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

echo "** System - Edit Repo Source List **"
DEB_REPO_SOURCE_LIST='/etc/apt/sources.list'
# ---------- Begin Config File ----------
cat > $DEB_REPO_SOURCE_LIST << EOF
deb http://archive.raspbian.org/raspbian jessie main contrib non-free rpi
EOF
# ----------- End Config File -----------


echo "** System - Update and Upgrade **"
apt-get update
apt-get upgrade -y


echo "** Stopping NTP Daemon**"
NTP_SYS_PATH='/etc/init.d/ntp'
$NTP_SYS_PATH stop
# apt-get --purge remove ntp -y


echo "** Installing Chrony + Dependencies **"

apt-get install libtomcrypt0 -y
apt-get install libtommath0 -y
apt-get install timelimit -y
apt-get install chrony -y

echo "** Chrony Install Complete **"

echo "noSYNC | Current SetTime: $(date)"


echo "** Creating Chrony TimeSync Client Config File **"
CHRONY_CONFIG_FILE_PATH='/etc/chrony/chrony.conf'

# ---------- Begin Config File ----------
cat > $CHRONY_CONFIG_FILE_PATH << EOF
server 192.168.1.1 iburst offline

driftfile /var/lib/chrony/chrony.drift

logdir /var/log/chrony
log measurements statistics tracking

makestep 1.0 3

EOF
# ----------- End Config File -----------

chmod 644 $CHRONY_CONFIG_FILE_PATH


# ------ Begin Appdend PPPD Config ------
PPPD_CONFIG_UP="/etc/ppp/ip-up"
PPPD_CONFIG_DOWN="/etc/ppp/ip-down"

echo "chronyc online" >> $PPPD_CONFIG_UP
echo "chronyc offline" >> $PPPD_CONFIG_DOWN
# ------- End Appdend PPPD Config -------

echo "** Restarting Chrony... **"
systemctl restart chrony
echo "** Chrony Started! **"
echo

echo "NTP Server <-> Client"
sleepTime="0.4"
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
echo "Chrony | Setup Complete!"
