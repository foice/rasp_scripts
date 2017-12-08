#!/bin/bash
#sleep 180

line="Subject: Pi has Rebooted on $(date -u) [bot]"
echo "$line"  | /usr/bin/msmtp --file=/home/pi/.msmtprc -- foice.news@gmail.com
echo "$line" >> /home/pi/reboots.log 
sleep 30
