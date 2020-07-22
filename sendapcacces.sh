email_recipient=$1
echo "Subject: UPS message We are on Battery " | cat - $(apcaccess | tr -d ":" > ~/apc.log) ~/apc.log    | /usr/bin/msmtp --file=/home/pi/.msmtprc -a fisica -- "$email_recipient" 
