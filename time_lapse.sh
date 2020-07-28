#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H%M")

cd /home/pi/Recordings/
/usr/bin/raspistill  -w 1280 -h 960 -o /home/pi/Recordings/$DATE.jpg
/home/pi/bin/dropbox_uploader.sh upload $DATE.jpg .
cd
