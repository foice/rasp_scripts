#!/bin/bash

temp=30
if [ ! -z "$1" ]
then
	temp=$1
fi

echo "Will keep T=$temp C"

while [ 1 -ge 0 ]
do
	if [ $(wget -qO- 192.168.114.200/last_temp.csv | cut -f2 -d"," | cut -f1 -d".") -ge $temp  ]
	then
		echo "Need to switch ON" # if temperature >  threshold then switch on
		irsend SEND_ONCE achaier on
	fi
	if [ $(wget -qO- 192.168.114.200/last_temp.csv | cut -f2 -d"," | cut -f1 -d".") -lt $temp  ]
	then
		echo "Need to switch OFF" # if temperature <  threshold then switch off
		irsend SEND_ONCE achaier off 
	fi

	sleep 600 # sleep 10 minutes
done
