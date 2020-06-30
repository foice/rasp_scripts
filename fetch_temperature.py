#!/usr/bin/env python3
import urllib.request
import pandas as pd 
import urllib
import os
from socket import timeout
import logging 
from urllib.error import HTTPError, URLError
import socket
from termcolor import colored

os.system("/home/pi/rasp_scripts/arp2hostname.sh > .arp ")
arp=pd.read_csv('.arp',sep='\s+',names=["ip","mac","hostname"])
hosts=pd.read_csv('~/known_macs',sep='\s+',names=["1","2","3","mac","long_hostname"])
# print(arp)
arp=arp[arp["hostname"]==arp["hostname"]  ]
print(arp)

for hostName in arp["hostname"].unique(): 
	if 'ESP-' in hostName:
		print(colored( 'downloading data for '+hostName,'green'))
		IP=arp[ arp["hostname"]==hostName ]['ip'].unique()
		IP=IP[0]
		mac=arp[ arp["hostname"]==hostName ]['mac'].unique()
		mac=mac[0]
		long_hostname=hosts[ hosts["mac"]==mac ]['long_hostname'].unique()[0]
		print('IP: '+IP," (",mac,":"+long_hostname+")")
		url="http://"+IP+"/temp.csv"
		file_name=long_hostname+"_"+IP+".csv"
		print('URL:',url)
		print('file:',file_name)
		try:
			with urllib.request.urlopen(url,timeout=300) as response, open(file_name, 'wb') as out_file:
				data = response.read() # a `bytes` object
				out_file.write(data)
		except ConnectionResetError:
			logging.error('ConnectionResetError:')
		except HTTPError as error:
			logging.error('Data not retrieved because %s\nURL: %s', error, url)
		except URLError as error:
			if isinstance(error.reason, socket.timeout):
				logging.error('socket timed out - URL %s', url)
			else:
				logging.error('some other error happened')
		else:
			logging.info('Access successful.')
