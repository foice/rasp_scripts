#!/bin/bash

temp=30
if [ ! -z "$1" ]
then
	temp=$1
fi

echo "Will keep T=$temp °C"

while [ 1 -ge 0 ]
do
 
# -q quiet
# -c nb of pings to perform
ping -q -c5 192.168.114.200  > /dev/null
 
	if [ $? -eq 0 ]
	then
		echo "Host is reachable"
		current_temperature=$(wget -qO- 192.168.114.200/last_temp.csv | cut -f2 -d"," | cut -f1 -d".")
	else
		curl wttr.in | head -4 | tail -1 > t		
		current_temperature=$(more t | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g'  | cut -f3 -d"." | tr -d " " | cut -c1-2)
		echo "Going from weather"
	fi
	
	echo "The current temperature is $current_temperature °C"

	if [ $current_temperature -ge $temp  ]
	then
		echo "Need to switch ON" # if temperature >  threshold then switch on
		irsend SEND_ONCE achaier on
	fi
	if [ $current_temperature -lt $temp  ]
	then
		echo "Need to switch OFF" # if temperature <  threshold then switch off
		irsend SEND_ONCE achaier off 
	fi

	sleep 600 # sleep 10 minutes
done
