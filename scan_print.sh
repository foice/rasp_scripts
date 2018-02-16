#!/bin/bash
source /home/pi/b
echo "Acquisisco l'immagnie"
/home/pi/rasp_scripts/scan_image.py
echo "Stampo la copia"
lpr -P HP_LaserJet_1000 output_file 
echo "Attendere 1 minuto"
sleep 60
