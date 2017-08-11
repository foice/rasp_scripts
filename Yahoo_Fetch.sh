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

# log to disk
output_file_stub=`pwd -L`"/history_"

while [[ 1 -gt 0 ]]; do

  weekday=`date -u '+%w'`
  time=`date -u '+%H%M'`
  if [[ $weekday != "6" ]]; then # is not saturday
    if  ! ([ $weekday == "0" ] && [ $time -lt 2100 ]) ; then #is not sunday before Sydney opens at 9:00 PM GMT (October to April)
      if  ! ([ $weekday == "5" ] && [ $time -gt 2200 ]) ; then #is not friday after New York closes at 10:00 PM GMT (April to October)
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
              echo -n ", " >> $output_file; curl -s `echo ${s/stock_symbol/${stock[$c]}}` >> $output_file;
        done
      fi
    fi
  fi
  sleep 5;
done
