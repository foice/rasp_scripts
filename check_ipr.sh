test=`ip r | wc -l`
if [ $test == 4 ]; then
	echo "ip r has 4 lines"
	/home/pi/rasp_scripts/wifi-to-eth-route.sh 
fi
