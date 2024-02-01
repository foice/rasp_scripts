#!/bin/bash
#host=192.168.114.200
subnet=6
host=192.168.$subnet.1
sl=10
temp=30
if [ ! -z "$1" ]
then
	temp=$1
fi

DEFAULT="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
UNDERLINE="\033[4m"
BLINK="\033[5m"
REVERSE="\033[7m"
HIDDEN="\033[8m"

BOLD_C="\033[22m"
UNDERLINE_C="\033[24m"
BLINK_C="\033[25m"
REVERSE_C="\033[27m"
COLOR_C="\033[29m"

BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

BLACK_B="\033[40m"
RED_B="\033[41m"
GREEN_B="\033[42m"
YELLOW_B="\033[43m"
BLUE_B="\033[44m"
MAGENTA_B="\033[45m"
CYAN_B="\033[46m"
WHITE_B="\033[47m"


echo -e $GREEN"Will keep T=$temp °C$DEFAULT"





isnum() { awk -v a="$1" 'BEGIN {print (a == a + 0)}'; }


#echo test of number $(isnum "23.6")

get_temperature_from_wttrin() {
	curl --max-time 15 wttr.in | head -4 | tail -1 > t
	bytes=`stat -c %s t`
	if [ $bytes -gt 0 ]
	then
		local current_temperature=$(more t | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g'  | cut -f3 -d"." | tr -d " " |   cut -f1 -d"(" )  #cut -c1-2)
		echo "Going from weather: $current_temperature"
		wttrin_temperature=$current_temperature
	fi
}


get_temperature_from_zigbee() {
 # try to get tempearture from HomeAssistant Logs
        local filetemperature="/home/homeassistant/.homeassistant/temperature_desk.csv"
        local lastlog=`stat -c %Y $filetemperature`
        local now=`date +%s`
        let age=$now-$lastlog
        echo "File age is $age seconds"
        if [ $age -lt 2400 ]  #40 minutes
        then
                local current_temperature=$(tail -1 /home/homeassistant/.homeassistant/temperature_desk.csv | cut -f2 -d",")
                echo "Temperature from $filetemperature : $current_temperature"
	else
		echo "file is too old (age grater than 2400 seconds)"
	fi
	#outout
	local res=$(isnum "$current_temperature") 
        if [ "$res" == "1" ] ; then
		echo -e $current_temperature 'is a number (Zigbee)'
		zigbee_temperature=$current_temperature
	else
		echoi -e $current_temperature 'is not a number (Zigbee)'
	fi
}

get_temperature_from_callup() {
	#trying to read call-up log
	local lastlog=`stat -c %Y /home/pi/temperature.log`
	local now=`date +%s`
	let age=$now-$lastlog
	echo "File age is $age seconds"
	if [ $age -lt 2400 ]  #40 minutes
	then
		local current_temperature=`less /home/pi/temperature.log | grep Appending | tail -1 | cut -f2 -d":" | cut -f2 -d","` # | cut -f1 -d"."`	
		echo "Temperature from callup: $current_temperature ($age seconds ago)"
	fi
	local res=$(isnum "$current_temperature") 
        if [ "$res" == "1" ] ; then
		echo $current_temperature 'is a number (Call-up)'
		callup_temperature=$current_temperature
	else
		echo $current_temperature 'is not a number (Call-up)'
	fi
}



get_temperature_from_wifi() {
	echo "try to get temperature from WLAN direct connection to the ESP8266" 
	~/rasp_scripts/connect_wlanX.sh -i wlan0 -s $subnet 
	# -q quiet
	# -c nb of pings to perform
	ping -q -c5 $host  > /dev/null
	 
	if [ "$?" -eq "0" ]
	then
		echo "Host is reachable, sleeping $sl"
		sleep $sl
		local url="$host"/last_temp.csv
		echo "URL $url"
		wget -d --tries=4 --read-timeout=3 -O "last" "$host"/last_temp.csv 
		#curl -L -C - -o "last" $url  #"$host"/last_temp.csv
		#lynx -source $url > last  
		local current_temperature=$(cat last | cut -f2 -d"," | cut -f1 -d".")
		echo "Temperature from $host : $current_temperature"
		wifi_temperature=$current_temperature
	fi
}



if [ -n "$debug" ]; then 
get_temperature_from_wttrin
if [ -n "$wttrin_temperature" ]; then
    echo -e $GREEN "wttr.in available: "$wttrin_temperature $DEFAULT
else
    echo -e $RED "wttr.in not available" $DEFAULT
fi
fi



if [ -n "$debug" ]; then 
get_temperature_from_callup
if [ -n "$callup_temperature" ]; then
    echo -e $GREEN "Callup available: "$callup_temperature $DEFAULT
else
    echo -e $RED "Callup not available" $DEFAULT
fi
fi



if [ -n "$debug" ]; then 
get_temperature_from_zigbee
if [ -n "$zigbee_temperature" ]; then
    echo -e $GREEN "Zigbee available: "$zigbee_temperature $DEFAULT
else
    echo -e $RED "Zigbee not available" $DEFAULT
fi
fi



if [ -n "$debug" ]; then 
#get_temperature_from_wifi
if [ -n "$wifi_temperature" ]; then
    echo -e $GREEN "Wifi available: "$wifi_temperature $DEFAULT
else
    echo -e $RED "Wifi not available" $DEFAULT
fi
fi


while [ 1 -ge 0 ]
do

get_temperature_from_zigbee
if [ -n "$zigbee_temperature" ]; then
        echo -e $GREEN "Zigbee available: "$zigbee_temperature $DEFAULT
	reading=$zigbee_temperature
else
	echo -e $RED "Zigbee not available" $DEFAULT
	get_temperature_from_callup
	if [ -n "$callup_temperature" ]; then
	        echo -e $GREEN "Callup available: "$callup_temperature $DEFAULT
		reading=$callup_temperature
	else
	        echo -e $RED "Callup not available" $DEFAULT
		get_temperature_from_wttrin
		if [ -n "$wttrin_temperature" ]; then
			echo -e $GREEN "wttr.in available: "$wttrin_temperature $DEFAULT
			reading=$wttrin_temperature
		else
		         echo -e $RED "wttr.in not available" $DEFAULT
			 echo "No reading available ... assuming temperature is 30 degrees"
			 reading=30
		fi
	fi
fi

current_temperature=$reading 

echo "The current temperature is $current_temperature °C"

if (( $(bc -l <<<"$current_temperature >= $temp") )); then
#if [ $current_temperature -ge $temp  ]
#then
	echo "Need to switch ON" # if temperature >  threshold then switch on
	irsend SEND_ONCE achaier on
fi
if (( $(bc -l <<<"$current_temperature < $temp") )); then
#if [ $current_temperature -lt $temp  ]
#then
	echo "Need to switch OFF" # if temperature <  threshold then switch off
	irsend SEND_ONCE achaier off
fi

sleep 600 # sleep 10 minutes

done

if [ 0 -ge 1  ]; then 

while [ 1 -ge 0 ]
do
	# try to get tempearture from HomeAssistant Logs
	filetemperature="/home/homeassistant/.homeassistant/temperature_desk.csv"
	lastlog=`stat -c %Y $filetemperature`
	now=`date +%s`
	let age=$now-$lastlog
	echo "File age is $age seconds"
	if [ $age -lt 2400 ]  #40 minutes
	then
		current_temperature=$(tail -1 /home/homeassistant/.homeassistant/temperature_desk.csv | cut -f2 -d",")		
		echo "Temperature from $filetemperature : $current_temperature"
		
	else
		echo "try to get temperature from WLAN direct connection to the ESP8266" 
		~/rasp_scripts/connect_wlanX.sh -i wlan0 -s $subnet 
		# -q quiet
		# -c nb of pings to perform
		ping -q -c5 $host  > /dev/null
		 
		if [ $? -eq 0 ]
		then
			echo "Host is reachable, sleeping $sl"
			sleep $sl
			url="$host"/last_temp.csv
			echo "URL $url"
			wget -d --tries=4 --read-timeout=3 -O "last" "$host"/last_temp.csv 
			#curl -L -C - -o "last" $url  #"$host"/last_temp.csv
			#lynx -source $url > last  
			current_temperature=$(cat last | cut -f2 -d"," | cut -f1 -d".")
			echo "Temperature from $host : $current_temperature"
		else
			#trying to read call-up log
			lastlog=`stat -c %Y /home/pi/temperature.log`
			now=`date +%s`
			let age=$now-$lastlog
			echo "File age is $age seconds"
			if [ $age -lt 2400 ]  #40 minutes
			then
				current_temperature=`less /home/pi/temperature.log | grep Appending | tail -1 | cut -f2 -d":" | cut -f2 -d","` # | cut -f1 -d"."`	
				echo "Temperature from callup: $current_temperature ($age seconds ago)"
			else
				curl --max-time 15 wttr.in | head -4 | tail -1 > t		
				bytes=`stat -c %s t`
				if [ $bytesize -gt 0 ]
				then
					current_temperature=$(more t | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g'  | cut -f3 -d"." | tr -d " " | cut -c1-2)
					echo "Going from weather: $current_temperature"
				else
					echo "No reading available ... assuming temperature is 30 degrees"
					current_temperature=30
				fi
			fi
		fi
	fi	
	echo "The current temperature is $current_temperature °C"

	if (( $(bc -l <<<"$current_temperature >= $temp") )); then
	#if [ $current_temperature -ge $temp  ]
	#then
		echo "Need to switch ON" # if temperature >  threshold then switch on
		irsend SEND_ONCE achaier on
	fi
	if (( $(bc -l <<<"$current_temperature < $temp") )); then
	#if [ $current_temperature -lt $temp  ]
	#then
		echo "Need to switch OFF" # if temperature <  threshold then switch off
		irsend SEND_ONCE achaier off 
	fi

	sleep 600 # sleep 10 minutes
done
fi
