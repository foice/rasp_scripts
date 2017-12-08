sleep 180

line="Subject: Pi has Rebooted on $(date -u) "
echo "$line"  | msmtp -- foice.news@gmail.com
echi "$line" >> ~/reboots.log 
