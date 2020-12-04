#!/bin/bash 
export PATH=/usr/bin/:$PATH
cd /home/pi/tempMonitorRunner/
/usr/local/opt/python-3.7.0/bin/python3 PlotMaker.ipynb.autosave.py --path='/home/pi/tempMonitor/'
cd
