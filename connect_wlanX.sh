#!/bin/bash

while getopts ":i:c:s:" opt; do
  case $opt in
    i) wlan_interface="$OPTARG"
    ;;
    c) config_file="$OPTARG"
    ;;
    s) suffix="$OPTARG"
    ;; 
    h) echo "usage bash ~/rasp_scripts/connect_wlanX.sh -i wlan0 -s 6"
    ;;
    \?) echo "availavble options are i:string c:string s:int ; Invalid option -$OPTARG" >&2
    ;;
  esac
done

echo "Interface $wlan_interface"
echo "config file $config_file"
echo "suffix $suffix"


if [ -z $wlan_interface ]
then
    echo "compulsory argument -i <interface> is missing"
    exit
fi

if [ -z $config_file  ]; then
	if [ -z $suffix ]; then
		echo "compulsory argument missing: either -c <config_file_path> or -s <suffix> must be give"
		exit
	fi
fi

if [ -z $config_file  ]
then
	config_file=/etc/wpa_supplicant/wpa_supplicant-"$wlan_interface"-"$suffix".conf
fi

if [ -z $subnet ]
then
	subnet=$(cat "$config_file" | grep ssid | cut -f2 -d"\""  | cut -f1 -d"@"  )
fi


sudo ip link set $wlan_interface down

gateway="192.168."$subnet".1"

interface_file="/var/run/wpa_supplicant"

if [ -f "$interface_file" ]; then
   sudo wpa_cli -p $interface_file -i $wlan_interface terminate
else
	echo $interface_file not found
fi

lock_file="/var/run/wpa_supplicant/wlan0"
if [ -f "$lock_file" ]; then
   sudo rm $lock_file
else
	echo "$lock_file" not found 
fi

pid=$(pidof wpa_supplicant)
if [ -n "$pid" ]
then
	echo "killing $pid"
	sudo kill -9 $pid
else
	echo "wpa_supplicant not found"
fi

#start wpa_supplicant
sudo wpa_supplicant -B -i $wlan_interface -c $config_file  # /etc/wpa_supplicant/wpa_supplicant-$wlan_interface.conf
#wait, just because ... 
sleep 4
#wait, just because ... 
sudo dhcpcd $wlan_interface

sleep 4
# Only send two pings, sending output to /dev/null as we don't want to fill logs on our sd card.
# If you want to force ping from your wlan0 you can connect next line and uncomment second line
ping -c2 ${gateway} > /dev/null # ping to gateway from Wi-Fi or from Ethernet
# ping -I ${wlan} -c2 ${gateway} > /dev/null # only ping through Wi-Fi

pingresult=$?
# If the return code from ping ($?) is not 0 (meaning there was an error)
#if [ $? != 0 ]
if [ $pingresult != 0 ]
then
	echo "could not ping $gateway"
else
	echo "$gateway is in reach"
fi
let tries=0
while  [  $pingresult != 0  -a    $tries -le 10    ]
do
	let tries=tries+1
	ping -c2 ${gateway} > /dev/null # ping to gateway from Wi-Fi or from Ethernet
	pingresult=$?
	echo `date` " -" $tries "-> " "$pingresult"
	sleep 4
done

