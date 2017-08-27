while true; do 
	voltage=`gpio -g read 35`
	if [ $voltage -eq 0 ]; then
		sudo wall "Voltage is low. Do something!" 
	fi
	sleep 60 
done
