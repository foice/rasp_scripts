#!/bin/bash
cd /home/pi/Scanner/
find . -type f -exec /home/pi/Dropbox-Uploader/dropbox_uploader.sh -f /home/pi/.dropbox_uploader upload {} {} \;
cd -
