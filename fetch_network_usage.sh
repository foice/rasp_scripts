#!/bin/bash
today=`date +%Y_%d_%m`
cd /home/pi/ipfm_logs/
dropbox_uploader.sh upload $today ./ipfm_logs/
dropbox_uploader.sh upload subnet/"$today" ./ipfm_logs/subnet/
cd
