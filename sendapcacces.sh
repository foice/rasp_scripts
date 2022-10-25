email_recipient=$1
status=$2
echo "Subject: $HOSTNAME UPS status message: $2" | cat - $(apcaccess | tr -d ":" > ~/apc.log) ~/apc.log    | /usr/bin/msmtp --file=/home/pi/.msmtprc -a fisica -- "$email_recipient" 
