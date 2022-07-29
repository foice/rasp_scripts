#!/bin/bash
# **************** INSTALLATION *******************
# crontab -e
# */5 * * * * sudo sh /home/pi/rasp_scripts/check_wifi.sh > /dev/null 2>&1
#=================================================================
# Script Variables Settings
clear
#DEFAULTS
wlan='wlan0'
gateway='192.168.8.1'
alias ifup='/sbin/ifup'
alias ifdown='/sbin/ifdown'
alias ifconfig='/sbin/ifconfig'
strategy="reconnect"
# CHECK IF INPUTS WERE GIVEN
#
while getopts ":g:i:s:" opt; do
  case $opt in
    g) gateway="$OPTARG"
    ;;
    i) wlan="$OPTARG"
    ;;
    s) strategy="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

printf "Argument wlan is %s\n" "$wlan"
printf "Argument strategy is %s\n" "$strategy"
printf "Argument gateway is %s\n" "$gateway"

#=================================================================
#http://www.pihome.eu/2017/10/19/auto-reconnecting-wifi-on-raspberry/
echo "  _____    _   _    _                            "
echo " |  __ \  (_) | |  | |                           "
echo " | |__) |  _  | |__| |   ___    _ __ ___     ___ "
echo " |  ___/  | | |  __  |  / _ \  | |_  \_ \   / _ \ "
echo " | |      | | | |  | | | (_) | | | | | | | |  __/"
echo " |_|      |_| |_|  |_|  \___/  |_| |_| |_|  \___|"
echo " "
echo "    S M A R T   H E A T I N G   C O N T R O L "
echo "*************************************************************************"
echo "* PiHome is Raspberry Pi based Central Heating Control systems. It runs *"
echo "* from web interface and it comes with ABSOLUTELY NO WARRANTY, to the   *"
echo "* extent permitted by applicable law. I take no responsibility for any  *"
echo "* loss or damage to you or your property.                               *"
echo "* DO NOT MAKE ANY CHANGES TO YOUR HEATING SYSTEM UNTIL UNLESS YOU KNOW  *"
echo "* WHAT YOU ARE DOING                                                    *"
echo "*************************************************************************"
echo
echo "                                                           Have Fun - PiHome" 
date
echo " - Auto Reconnect Wi-Fi Status for $wlan Script Started ";
echo

# Only send two pings, sending output to /dev/null as we don't want to fill logs on our sd card. 
# If you want to force ping from your wlan0 you can connect next line and uncomment second line 
ping -c2 ${gateway} > /dev/null # ping to gateway from Wi-Fi or from Ethernet
# ping -I ${wlan} -c2 ${gateway} > /dev/null # only ping through Wi-Fi 

# If the return code from ping ($?) is not 0 (meaning there was an error)
if [ $? != 0 ]
then
    if [ "$strategy" == "reboot" ] 
	then
	echo "gateway $gateway is not responding. we are going to reboot in 2 minutes"
	sudo shutdown -r 2  
    fi
    if [ "$strategy" == "reconnect" ]
	then
        # Restart the wireless interface
    	ifdown --force $wlan
	ifup $wlan
	sleep 5
	ifup $wlan
    fi
fi
ping -I ${wlan} -c2 ${gateway} > /dev/null
date
echo 
echo " - Auto Reconnect Wi-Fi Status for $wlan Script Ended ";
