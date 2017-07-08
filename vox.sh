#!/bin/bash

while [ 1 ]
do 
#Remove temp file just incase
tempfile=temp.mp3
rm -rf $tempfile

#Listen for audio and record
sox -d $tempfile silence 1 0.1 1% 1 0:0:5 1%

#Check if temp.mp3 is greater than 800 bytes so we don't get blank recordings added to the
#database, if the file is below 800 bytes remove the file and restart.
for i in $tempfile ; do
   b=`stat -c %s "$i"`
   if [ $b -ge 800 ] ; then

      NAME=`date +%Y-%m-%d_%H-%M-%S`
      TIME=`date +%H:%M:%S`
      FILENAME=./Recordings/$NAME.mp3
      #FILEWWW=Recordings/$NAME.mp3
      mv $tempfile $FILENAME
      cd Recordings
      dropbox_uploader.sh upload $NAME.mp3 $NAME.mp3 && rm -v $NAME.mp3
      cd ..
      rm -rf $tempfile

      #mysql --host=localhost --user=root --password=pass database << EOF
      #insert into recordings (id,time,filename,active,status) values('NULL','$TIME','$FILEWWW','1','1');
      #EOF

  else
      rm -rf $tempfile
      echo 'No sound detected, Restarting...'
  fi
  sleep 0.25
done
done
