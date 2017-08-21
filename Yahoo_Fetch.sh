#!/bin/bash
#
# forked from a yahoo stock info plugin by http://srinivas.gs by >Srinivas Gorur-Shandilya
#
debug=false
# specify which stocks you want to monitor here
stock[0]="EURCHF=X"
stock[1]="EURUSD=X"
stock[2]="USDCHF=X"


archive="archive" # folder in which to put the prvious days logs
output_file_stub=`pwd -L`"/history_" # beginning part of the filename to save the daily log; beware it has its full path at the beginning! 

########################################################################
######################### function declarations ########################
########################################################################

debug_print(){
   if [ "$debug" = true ]; then 
   	if [[ ! "$2" == '' ]]; then
   		if [ $debug ]; then echo $1 >> $2 ; fi 
   	else
		echo $1;  
	fi
   fi
}

get_key(){  # get a key for the timedb server API
  echo `cat key.conf`
}


have_torsocks(){ # check if the system has torsocks installed
 torpath=`which torsocks`
 if [ $torpath != '' ]; then
  echo 1
 else 
  echo 0
 fi
}


shuffle() { # this function is to shuffle the elements of an array in bash
   local i tmp size max rand
   size=${#stock[*]}
   max=$(( 32768 / size * size ))
   for ((i=size-1; i>0; i--)); do
      while (( (rand=RANDOM) >= max )); do :; done
      rand=$(( rand % (i+1) ))
      tmp=${stock[i]} stock[i]=${stock[rand]} stock[rand]=$tmp
   done
}

check_oneday_old() { # check if the first argument is a file more than 1 day old
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

get_entry() { # get a random entry from $1 and if it contains : then check it be an open port on that host
 active=0
 while [ $active -eq 0 ]; do
	proxylen=$(cat "$1" | wc -l)	
	proxyid=$[ ( $RANDOM % $proxylen ) + 1 ]
  	proxy=`awk -v r=$proxyid ' NR==r {print} ' "$1"`
  	#if it is a proxy try to ping it before considering it valid
  	ip=$(echo $proxy | cut -f1 -d":")
  	port=$(echo $proxy | cut -f2 -d":")
	debug_print $ip":"$port nmap.log; 
  	if [[ "$port" != "$proxy" ]]; then  # a second field existed and cut retuned it in $port
   		active=`nmap -p $port $ip  | tail -1 | cut -f2 -d "(" | cut -f1 -d" "`
  	else 
   		active=1 
  	fi
  done 	
  echo $proxy
}

check_quote(){ # check that is a valid float number
	words=`echo "$1" | wc -w`
	#echo $1 has $words words >> log 
	re='^[0-9]+([.][0-9]+)?$'
	if ([[ $words -eq 1 ]] &&  [[ "$1" =~ $re ]]); then
		echo 1
	else 
		echo 0
	fi
}


get_quote(){	# get symbol $1 from from Yahoo Finance
	s='https://download.finance.yahoo.com/d/quotes.csv?s=stock_symbol&f=l1'
	symbol="$1"
	_url=$( echo ${s/stock_symbol/$symbol} ) 
	debug_print "Attempting  $_url" quotelog
	
	_quote=''
	while [[ $(check_quote "$_quote") == 0 ]]; do
			
		if [ $havetorsock ]; then
			debug_print "routed on tor at $(date -u)" routelog
			_quote=$(torsocks curl -m 15 -s "$_url" ); #debug_print "quote: $quote ."
		else
			_proxy=$(get_entry proxies.list); #debug_print $proxy
			_useragent=$(get_entry user_agent.list); #debug_print "$useragent"
			_quote=$(curl -m 15 -x "$_proxy" -A "$_useragent" -s "$_url" ); #debug_print "quote: $quote ."
			debug_print "routed on proxy $_proxy at $(date -u)" routelog
		fi
		done
	echo "$_quote"
}

write_quote(){  # write value $1 to file $2 		
	_quote="$1"
	_output_file="$2"
	echo -n $(date) >> "$_output_file";  #no new line -n
	echo -n "  " >> "$_output_file";
	echo -n ", " >> "$_output_file"; echo "$_quote" >> "$_output_file"; 
}

########################################################################
#################### 	end of function declarations ###################
########################################################################


havetorsock=`have_torsocks`
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


        n=${#stock[@]}
        n=$((n-1))
        for (( c=0; c<=n; c++ ))
        do
              output_file=$output_file_stub"${stock[$c]}"
	      ### GET QUOTE
	      quote=$( get_quote ${stock[$c]} );  debug_print "got a quote: $quote `date -u`"
              ### WRITE QUOTE
	      write_quote "$quote" "$output_file"; debug_print "$quote -> $output_file"
              ### UPLOAD TO DB
	      if [ $RANDOM -gt $((32767*95/100)) ]; then
                action="YahooData_Dropbox_Upload.sh upload $output_file ${output_file##*/}"; debug_print "$action"
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
  sleep 1;
done
