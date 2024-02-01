#!/bin/bash 
export PATH=/usr/bin/:$PATH

python_path="/usr/local/opt/python-3.7.0/bin/"
if [ -n "$1" ]
then 
python_path="$1"
fi

echo python_path will be "$1"
cd /home/pi/tempMonitorRunner/
"$python_path"python3 PlotMaker.ipynb.autosave.py --path='/home/pi/tempMonitor/'
cd
