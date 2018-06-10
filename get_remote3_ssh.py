#!/usr/bin/env python3

import requests
import httplib2
from urllib.request import urlopen
from json import dumps
import getpass
import json
from utils import *
import argparse
import os
jsl = os.environ['JSONLOGINS']

apiMethod="https://"
apiServer="api.remot3.it"
apiVersion= "/apv/v23.5"

def get_key(field='key'):
    _log_d = filejson2dictionary(jsl+'/remot3.json')
    developerKey="\""+_log_d[field]+"\""
    return developerKey

def get_token():

    developerkey=get_key()
    developerkey=get_key()


    pw = getpass.getpass()

    #url = "https://api.remot3.it/apv/v23.5/user/login"
    url = apiMethod + apiServer + apiVersion +"/user/login"

    payload = "{ \"username\": " + get_key(field="username") + ", \"password\":\"" + pw + "\" }"
    headers = {
        'developerkey': developerkey,
        'content-type': "application/json",
        'cache-control': "no-cache"
        }
    #print(headers)
    #
    response = requests.request("POST", url, data=payload, headers=headers)
    response_dict = json.loads(response.text)
    print(response_dict['token'])
    return response_dict['token']

def get_devices_list(token):

    developerkey=get_key()

    deviceListURL = apiMethod + apiServer + apiVersion + "/device/list/all"
    content_type_header = "application/json"

    deviceListHeaders = {
                    'Content-Type': content_type_header,
                    'developerkey': developerkey,
                    'token': token,
                }
    httplib2.debuglevel     = 0
    http                    = httplib2.Http()


    response, content = http.request( deviceListURL,
                                          'GET',
                                          headers=deviceListHeaders)
    dict_connected = json.loads(content)
    return dict_connected

def proxyConnect(UID, token):
    httplib2.debuglevel     = 0
    http                    = httplib2.Http()
    content_type_header     = "application/json"

  # this is equivalent to "whatismyip.com"
  # in the event your router or firewall reports a malware alert
  # replace this expression with your external IP as given by
  # whatismyip.com

    #_log_d = filejson2dictionary('/Users/roberto/json_logins/remot3.json')
    #developerKey="\""+_log_d['key']+"\""
    developerKey=get_key()


    my_ip = urlopen('http://ip.42.pl/raw').read()
    print(my_ip)

    proxyConnectURL = apiMethod + apiServer + apiVersion + "/device/connect"
    proxyHeaders = {
                'Content-Type': content_type_header,
                'developerkey': developerKey,
                'token': token
            }

    proxyBody = {
                'deviceaddress': UID,
                'hostip': str(my_ip,"utf8"),
                'wait': "true"
            }

    response, content = http.request( proxyConnectURL,
                                          'POST',
                                          headers=proxyHeaders,
                                          body=dumps(proxyBody),
                                       )
    try:
        data = json.loads(content)["connection"]["proxy"]
        fields = data.split(":")
        host=fields[1].replace("/","")
        print("ssh -l pi "+host+" -p "+fields[2])
    except KeyError:
        print("Key Error exception!")
        print(content)


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--piname", default="RPi-Roberto-SSH", help="Service name to be searches for")
    args = parser.parse_args()

    piname=args.piname

    token = get_token()
    dict_connected = get_devices_list(token)

    print ([ d['devicealias']+' '+d['deviceaddress']for d in dict_connected["devices"] if d['devicestate'] == "active" ])

    UIDs = [ d['deviceaddress'] for d in dict_connected["devices"] if d['devicestate'] == "active" and d['devicealias'] == piname  ]

    proxyConnect(str(UIDs[0]), token)
