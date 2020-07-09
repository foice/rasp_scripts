#!/bin/bash
cd /home/pi/videoMonitor
NAME=`date +%Y-%m-%d_%H-%M-%S`.jpg
/usr/bin/raspistill -w 640 -h 480 -o $NAME
/home/pi/rasp_scripts/dropbox_uploader.sh upload $NAME ./lapse/$NAME && rm -v $NAME


