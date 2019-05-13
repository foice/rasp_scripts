#!/bin/bash
body=$(/usr/local/bin/urlwatch)

header='To:Roberto Franceschini <roberto.franceschini@uniroma3.it>\nFrom:Roberto Franceschini <franceschini@fis.uniroma3.it>\nSubject: Monitored Web Pages have been updated [urlwatch]\n'


if [ -z "$body" ]
then
	echo " no changes in any webpage"
        # refresh the passphrase in the cache
	cd /run/user/$(id -u)
	# make the tmpfs folder 
	gpgtmp=gpgtmp
	mkdir $gpgtmp
	chmod 0700 $gpgtmp
	cd $gpgtmp
	/usr/bin/gpg --quiet --for-your-eyes-only --no-tty --decrypt /home/pi/.mail/.msmtp-credentials.gpg | /usr/bin/gpg --encrypt -r 3149BB87487375139BBF8FBB5A0CB586D3DA04 > ll.gpg
	/usr/bin/srm ll.gpg
	cd
else
	echo "Changes found in some webapge!"
	echo -e "$header" "\n\n" "$body" | /usr/bin/msmtp --file=/home/pi/.msmtprc -a fisica -- $(cat /home/pi/rasp_scripts/urlwatch.recipient )
fi
