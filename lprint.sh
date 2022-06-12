#!/bin/bash 
scp  "$1" pi@192.168.1.146:
name=$(basename "$1")
echo $name 
ssh  pi@192.168.1.146  "lp   -d HP_LaserJet_Professional_P1102  \"$name\""
