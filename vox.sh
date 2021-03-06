#!/bin/bash
threshold=$1

if [[ "$1" == "" ]]; then
threshold="1"
fi

while [ 1 ]
do 
#Remove temp file just incase
tempfile=temp.mp3
rm -rf $tempfile

#Listen for audio and record
#sox -d $tempfile silence 1 0.1 0.1% 1 0:0:5 0.1%
sox -d $tempfile silence 1 5 "$threshold"% 1 0:00:02 "$threshold"%
# syntax from http://www.linuxquestions.org/questions/linux-software-2/vox-recorder-and-audio-timer-recorder-598535/
# rec recording.wav silence 1 5 2% 1 0:00:02 2%

#Check if temp.mp3 is greater than 800 bytes so we don't get blank recordings added to the
#database, if the file is below 800 bytes remove the file and restart.
for i in $tempfile ; do
   b=`stat -c %s "$i"`
   if [ $b -ge 800 ] ; then

      NAME=`date +%Y-%m-%d_%H-%M-%S`.mp3
      TIME=`date +%H:%M:%S`
      FILENAME=./Recordings/$NAME
      #FILEWWW=Recordings/$NAME.mp3
      mv $tempfile $FILENAME
      cd Recordings
      dropbox_uploader.sh upload $NAME $FILENAME && rm -v $NAME
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
