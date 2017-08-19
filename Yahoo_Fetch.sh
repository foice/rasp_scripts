#!/bin/bash
#
# forked from a yahoo stock info plugin by http://srinivas.gs by >Srinivas Gorur-Shandilya
#
debug=false
# specify which stocks you want to monitor here
stock[0]="EURCHF=X"
stock[1]="EURUSD=X"
stock[2]="USDCHF=X"

archive="archive"


debug_print(){
   if [ $debug ]; then echo $1; fi 
}

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
  if [ -f "$1" ]; then
    if [[ $(find "$1" -mtime +1 -print) ]]; then
    #if [[ $(find "$1" -mtime +1 -print) ]]; then
      #echo "File $1 exists and is older than 1 day"
      echo 1
    else
      echo 0 
    fi
  else 
    echo 0
  fi 
}

check_dst_sydney() {
  if ( [[ `check_oneday_old sydney.xml` == 1 ]] || [ ! -f sydney.xml ] ); then
    key=`get_key`
    wget -O sydney.xml "http://api.timezonedb.com/v2/get-time-zone?key="$key"&format=xml&by=zone&zone=Australia/Sydney"
  fi
  echo `less sydney.xml | grep -o \<dst\>.*\</dst\> | grep -o \>.*\< | cut -c 2`
}

check_dst_ny() {
  if ( [[ `check_oneday_old ny.xml` == 1 ]] || [ ! -f ny.xml ] ); then
    key=`get_key`
    wget -O ny.xml "http://api.timezonedb.com/v2/get-time-zone?key="$key"&format=xml&by=zone&zone=America/New_York"
  fi
  echo `less ny.xml | grep -o \<dst\>.*\</dst\> | grep -o \>.*\< | cut -c 2`
}

get_entry() {
 proxylen=$(cat "$1" | wc -l)	
 proxyid=$[ ( $RANDOM % $proxylen ) + 1 ]
 proxy=`awk -v r=$proxyid ' NR==r {print} ' "$1"`
 #if it is a proxy try to ping it before considering it valid
 echo $proxy
}

check_quote(){
	words=`echo "$1" | wc -w`
	#echo $1 has $words words >> log 
	re='^[0-9]+([.][0-9]+)?$'
	if ([[ $words -eq 1 ]] &&  [[ "$1" =~ $re ]]); then
		echo 1
	else 
		echo 0
	fi
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
  #echo "will write files right before "$(($nycloses+1)) 
  if [[ $weekday != "6" ]]; then # is not saturday
    if  ! ([ $weekday == "0" ] && [ $time -lt $sidneyopens ]) ; then #is not sunday before Sydney opens at 9:00 PM GMT (October to April)
      if  ! ([ $weekday == "5" ] && [ $time -gt $(($nycloses+1)) ]) ; then #is not friday after New York closes at 10:00 PM GMT (April to October). Adding one minute to allow write of archive on Friday.
        shuffle

        # we get stock quotes from Yahoo
        s='http://download.finance.yahoo.com/d/quotes.csv?s=stock_symbol&f=l1'

        n=${#stock[@]}
        n=$((n-1))
        for (( c=0; c<=n; c++ ))
        do
              output_file=$output_file_stub"${stock[$c]}"
	      ### GET QUOTE
	      quote=''
	      while [[ $(check_quote "$quote") == 0 ]]; do	
	      	proxy=$(get_entry proxies.list); #debug_print $proxy
	     	useragent=$(get_entry user_agent.list); #debug_print "$useragent"
              	quote=$(curl -m 15 -x $proxy -A "$useragent" -s $(echo ${s/stock_symbol/${stock[$c]}}) ); #debug_print "quote: $quote ."
	      done
	      debug_print "final quote: $quote `date -u`"
              ### WRITE QUOTE
	      echo -n $(date) >> $output_file;  #no new line -n
              echo -n "  " >> $output_file;
              echo -n ", " >> $output_file; echo $quote >> $output_file; 
              ### UPLOAD TO DB
	      if [ $RANDOM -gt $((32767*95/100)) ]; then
                action="YahooData_Dropbox_Upload.sh upload $output_file ${output_file##*/}"
                #echo $action
                $action >> dblog
              fi

	      # echo $( check_oneday_old lastwrite_"${stock[$c]}" )	

              if ( [[ $( check_oneday_old lastwrite_"${stock[$c]}" ) == 1 ]] || [ ! -f lastwrite_"${stock[$c]}" ] ); then
                if [ $time -gt $nycloses ]; then
                  echo "NY closed at "$nycloses". Writing today's rates."
                  echo $(date -u) >> lastwrite_"${stock[$c]}"
                  if [ ! -d ./$archive ]; then
                    mkdir -v $archive;
                  fi
                  final_file_name=$output_file"_"$(date +%F)
                  mv -v $output_file $final_file_name
                  YahooData_Dropbox_Upload.sh upload $final_file_name "$archive""/""${final_file_name##*/}"
                  mv -v $final_file_name ./$archive
                fi
              fi
        done
      fi
    fi
  fi
  sleep 5;
done
