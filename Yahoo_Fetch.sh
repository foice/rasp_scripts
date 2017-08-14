#!/bin/bash
#
# yahoo stock info plugin
# much simpler than stock plugin, no API key required
# by http://srinivas.gs
#
# <bitbar.title>Stock price</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Srinivas Gorur-Shandilya</bitbar.author>
# <bitbar.author.github>sg-s</bitbar.author.github>
# <bitbar.desc>Customizable stock price display </bitbar.desc>


# specify which stocks you want to monitor here
stock[0]="EURCHF=X"
stock[1]="EURUSD=X"
stock[2]="CHFUSD=X"

archive="archive"

get_key(){
  echo `cat key.conf`
}

# this function is to shuffle the elements of an array in bash
shuffle() {
   local i tmp size max rand
   size=${#stock[*]}
   max=$(( 32768 / size * size ))
   for ((i=size-1; i>0; i--)); do
      while (( (rand=RANDOM) >= max )); do :; done
      rand=$(( rand % (i+1) ))
      tmp=${stock[i]} stock[i]=${stock[rand]} stock[rand]=$tmp
   done
}

check_oneday_old() {
  if [[ $(find "$1" -mtime +1 -print) ]]; then
    #echo "File $1 exists and is older than 1 day"
    echo 1
  fi
  echo 0
}

check_dst_sydney() {
  if ([ `check_oneday_old sydney.xml` == 1 ] || [ ! -f sydney.xml ]); then
    key=`get_key`
    wget -O sydney.xml "http://api.timezonedb.com/v2/get-time-zone?key="$key"&format=xml&by=zone&zone=Australia/Sydney"
  fi
  echo `less sydney.xml | grep -o \<dst\>.*\</dst\> | grep -o \>.*\< | cut -c 2`
}

check_dst_ny() {
  if ([ `check_oneday_old ny.xml` == 1 ] || [ ! -f ny.xml ]); then
    key=`get_key`
    wget -O ny.xml "http://api.timezonedb.com/v2/get-time-zone?key="$key"&format=xml&by=zone&zone=America/New_York"
  fi
  echo `less ny.xml | grep -o \<dst\>.*\</dst\> | grep -o \>.*\< | cut -c 2`
}

# log to disk
output_file_stub=`pwd -L`"/history_"

if [ ! -f key.conf ]; then
  echo "file key.conf is missing"
  exit
fi
  # ************************ #
  # MAIN LOOP, INFINITE LOOP #
  # ************************ #

while [[ 1 -gt 0 ]]; do

  dst_sydney=`check_dst_sydney`
  dst_ny=`check_dst_ny`

  #echo $dst_sydney "in Sydney"
  #echo $dst_ny "in NY"

  weekday=`date -u '+%w'`
  time=`date -u '+%H%M'`
  sidneyopens=$((2200-100*$dst_sydney))
  nycloses=$((2200-100*$dst_ny))

  #echo "Sidney opens at "$sidneyopens
  #echo "NY closes at "$nycloses
  if [[ $weekday != "6" ]]; then # is not saturday
    if  ! ([ $weekday == "0" ] && [ $time -lt $sidneyopens ]) ; then #is not sunday before Sydney opens at 9:00 PM GMT (October to April)
      if  ! ([ $weekday == "5" ] && [ $time -gt $nycloses ]) ; then #is not friday after New York closes at 10:00 PM GMT (April to October)
        shuffle

        # we get stock quotes from Yahoo
        s='http://download.finance.yahoo.com/d/quotes.csv?s=stock_symbol&f=l1'

        n=${#stock[@]}
        n=$((n-1))
      # TODO add a break at a given time of the day and move the previous file to archive
        for (( c=0; c<=n; c++ ))
        do
        	#echo -n ${stock[$c]}; echo -n ":"; curl -s `echo "${s/stock_symbol/${stock[$c]}}"`
              output_file=$output_file_stub"${stock[$c]}"
            	echo -n $(date) >> $output_file;  #no new line -n
              echo -n "  " >> $output_file;
              #echo -n ${stock[$c]} >> $output_file;
              echo -n ", " >> $output_file; curl -s $(echo ${s/stock_symbol/${stock[$c]}}) >> $output_file;
              if ([ $( check_oneday_old lastwrite_"${stock[$c]}" ) == 1 ] || [ ! -f lastwrite_"${stock[$c]}" ]); then
                if [ $time -gt $nycloses ]; then
                  echo "NY closed at "$nycloses". Writing today's rates."
                  echo $(date -u) >> lastwrite_"${stock[$c]}"
                  if [ ! -d ./$archive ]; then
                    mkdir -v $archive;
                  fi
                  mv -v $output_file $output_file"_"$(date +%F)
                  mv -v $output_file"_"$(date +%F) ./$archive
                fi
              fi
        done
      fi
    fi
  fi
  sleep 5;
done
