#!/bin/bash
body=$(/usr/local/bin/urlwatch)
recipient=$(cat /home/pi/rasp_scripts/urlwatch.recipient )
sender=$(cat /home/pi/rasp_scripts/urlwatch.sender )
header="To:$recipient\\nFrom:$sender\\nSubject: Monitored Web Pages have been updated [urlwatch]\\n"
echo -e "$header"

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
	echo cat "$body" >> /home/pi/urlwatch_content.log
	echo "Will email $recipient from $sender"
	echo -e "$header" "\n\n" "$body" | /usr/bin/msmtp --file=/home/pi/.msmtprc -a default -- "$recipient"
fi
