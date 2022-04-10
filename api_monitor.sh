#!/bin/bash
source /home/pi/.bashrc 
export PYTHONPATH=:/home/pi/scriptbelt/python:/home/pi/humanroot/utils/PyLHEanalysis::/home/pi/scriptbelt/python:/home/pi/humanroot/utils/PyLHEanalysis::/home/pi/scriptbelt/python:/home/pi/humanroot/utils/PyLHEanalysis:
cd /mnt/usb/KrakenAPI/
#/home/pi/bin/python3.7   api_fetch_scheduler.py  --keep True & >> /home/pi/api_monitor.service.log 2>&1 
/home/pi/bin/python3.7   api_fetch_scheduler.py   >>   /home/pi/api_monitor.service.log 2>&1   & 
