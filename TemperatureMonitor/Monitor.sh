#!/bin/bash
while [ 0 -le 1 ]
do
	wget -O temp.csv 192.168.114.200/temp.csv
	python3.7 Temperature\ Monitor.py
	sleep 3600
done
