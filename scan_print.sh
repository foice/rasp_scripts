#!/bin/bash
source /home/pi/b
echo "Acquisisco l'immagnie"
/home/pi/rasp_scripts/scan_image.py -o temp.jpg 
echo "Stampo la copia"
lpr -P HP_LaserJet_1000 temp.jpg 
echo "Attendere 1 minuto"
sleep 60
