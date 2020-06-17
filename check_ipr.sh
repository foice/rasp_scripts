#!/bin/bash
test=`ip r | wc -l`
test=`ip r | grep  default | grep eth0 | wc -l`
if [ $test -gt 0 ]; then
	echo "ip r has a default route foe eth0. Needs to be removed"
	/home/pi/rasp_scripts/wifi-to-eth-route.sh
        echo "corrected routings at $(date)" >> ~/wifi-to-eth-route.log	
fi
