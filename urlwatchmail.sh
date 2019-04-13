#!/bin/bash
body=$(/usr/local/bin/urlwatch)

header='To:Roberto Franceschini <roberto.franceschini@uniroma3.it>\nFrom:Roberto Franceschini <franceschini@fis.uniroma3.it>\nSubject: Monitored Web Pages have been updated [urlwatch]\n'


if [ -z "$body" ]
then
      echo " is empty"
else
      echo " is NOT empty"
      echo -e "$header" "\n\n" "$body" | /usr/bin/msmtp --file=/home/pi/.msmtprc -a fisica -- roberto.franceschini@uniroma3.it
fi
