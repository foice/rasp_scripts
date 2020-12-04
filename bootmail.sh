#!/bin/bash
#sleep 180

line="Subject: $(/bin/hostname) Pi has Rebooted on $(/bin/date -u) [bot]"
echo "$line"  | /usr/bin/msmtp --file=/home/pi/.msmtprc -- foice.news@gmail.com
echo "$line" >> /home/pi/reboots.log 
sleep 30
