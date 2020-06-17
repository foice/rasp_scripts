#!/bin/bash
today=`/bin/date +%Y_%d_%m`
cd /home/pi/ipfm_logs/
/home/pi/rasp_scripts//dropbox_uploader.sh  upload $today ./ipfm_logs/
/home/pi/rasp_scripts//dropbox_uploader.sh upload subnet/"$today" ./ipfm_logs/subnet/
cd
