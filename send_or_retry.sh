subject="[PoggioPi] Temperature and Humidity"
recipient="foice.news@gmail.com"

if [ -n "$1" ]
then
subject="$1"
fi

if [ -n "$2" ]
then
recipient="$2"
fi

sent=0

while [ $sent -le 0 ]
do
    /usr/bin/mutt -s "$subject" -a /home/pi/tempMonitorRunner/temperature.png -a /home/pi/tempMonitorRunner/humidity.png -- "$recipient" < /dev/null && sent=1
    if [ $sent -eq 1  ]
    then 
	echo "sent"
    else
	echo "not yet sent"
	sleep 10
    fi
done
