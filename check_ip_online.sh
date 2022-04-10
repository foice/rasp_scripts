gateway="$1"
# If you want to force ping from your wlan0 you can connect next line and uncomment second line
ping -c2 ${gateway} > /dev/null # ping to gateway from Wi-Fi or from Ethernet
# ping -I ${wlan} -c2 ${gateway} > /dev/null # only ping through Wi-Fi

# If the return code from ping ($?) is not 0 (meaning there was an error)
if [ $? != 0 ]
then
	echo "{ \"online\": 0}" > "$gateway"
else
	echo "{ \"online\": 1}" > "$gateway"

fi
