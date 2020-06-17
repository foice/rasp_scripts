#!/bin/bash
cd /home/pi/tempMonitor
/home/pi/rasp_scripts/fetch_temperature.py
cd /home/pi
/home/pi/rasp_scripts/dropbox_uploader.sh upload tempMonitor/ .
