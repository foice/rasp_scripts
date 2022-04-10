#!/bin/bash
#recently_modified=$(/usr/bin/find /home/pi/api_monitor.service.log -mmin +90 -print | wc -l)

filename="/home/pi/api_monitor.service.log"

if [ -z "$1" ]
then
      #echo "\$1 is empty"
      minutes=90
else
      minutes="$1"
fi

echo "checking for $minutes minutes"

if [[ $(/usr/bin/find "$filename" -mmin +"$minutes" -print ) ]]; then
  line="File $filename exists and is older than $minutes minutes"
  echo $line
  /usr/bin/mutt -s "$line" -- foice.news@gmail.com < /dev/null
fi
