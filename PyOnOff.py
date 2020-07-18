#!/usr/bin/env python3

import requests
import json
import argparse

_usage='~>python3  PyOnOff.py --value=On --plug=1 --subnet=1 --host=215' 
parser = argparse.ArgumentParser(description='', usage=_usage)


parser.add_argument('--subnet',
                    default='1',
                    help='the subnet')

parser.add_argument('--host',
                    default='215',
                    help='The last part of the IP of the Sonoff')

parser.add_argument('--value',
                    default='',
                    help='The value to set, e.g. On or Off')
parser.add_argument('--plug',
                    default='1',
                    help='Which plug to control')
args = parser.parse_args()

subnet=args.subnet
host=args.host
n=args.plug
value=args.value

set_value=False
if value is not '': 
	set_value=True 	

url='http://192.168.'+str(subnet)+'.'+str(host)+'/cm?cmnd=Power'+str(n)

if set_value:
	url+='%20'+value

print(url)
response = requests.get(url).text
#response = json.loads(requests.get(url).text)
print(response)
