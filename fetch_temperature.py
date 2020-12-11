#!/usr/bin/env python3
import json
import urllib.request
from bs4 import BeautifulSoup
import pandas as pd 
import urllib
import re
import os
from socket import timeout
import logging 
from urllib.error import HTTPError, URLError
import socket
from termcolor import colored
from pathlib import Path

download_timeout=300

thisIsGateway=False
my_file = Path("/var/lib/dnsmasq/dnsmasq.leases")
if my_file.is_file():
	# file exists
	thisIsGateway=True


def filejson2dictionary(fn):
    with open(fn) as json_data:
        d = json.load(json_data)
    return d

def get_online(ip,field="online"):
    print("reading ", ip)
    _d = filejson2dictionary(ip)
    print(_d)
    online = _d[field]
    return online


def url2filename(url,file_name):
	try:
		with urllib.request.urlopen(url,timeout=download_timeout) as response, open(file_name, 'wb') as out_file:
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

if thisIsGateway:
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
			url2filename(url,file_name)

else:
	os.system(' sudo iwlist wlan0 scan | grep ESSID | grep @ | cut -f2 -d"@"   > .ips ')
	ips=pd.read_csv('.ips',sep='"',names=["ip"],index_col=False )["ip"].to_list()

	manual_host='192.168.6.1'
	os.system("check_ip_online.sh "+manual_host)
	
	online = get_online(manual_host)

	if online == 1:
		print(manual_host," is online") 
		ips+=[manual_host]	

	print("ips:",ips)
	for ip in ips:
		if "0.0.0.0" != ip:
			url="http://"+ip
			print('working on ',ip)
			html = urllib.request.urlopen(url)
			bsh = BeautifulSoup(html.read(), 'html.parser')
			h1=str(bsh.h1)
			name=h1.split('ESP')[0] #.split('<h1>')[0]
			#print(name)
			name=name.split('>')[1]
			name = re.sub(r"\s+", '_', name)
			print(name)
			file_name=name+'_'+str(ip)+'.csv'
			url2filename(url+'/temp.csv',file_name)
