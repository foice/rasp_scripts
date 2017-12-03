#!/usr/bin/env python
import urllib2  # urllib2 is used to fetch url(s) via urlopen()
from bs4 import BeautifulSoup# when importing Beautiful Soup don't add 4.
from datetime  import datetime # contains functions and classes for working with dates and times, separately and together
import argparse


def DEBUG():
	return False

def get_symbol(_CHFEUR):
	quote_page = 'https://www.bloomberg.com/quote/'+_CHFEUR+':CUR'
	if DEBUG(): t1 = datetime.now()
	page  = urllib2.urlopen(quote_page)
	soup = BeautifulSoup(page, "html.parser")
	if DEBUG(): name_store = soup.find('div', attrs={'class' : 'ticker'})
	if DEBUG(): name=name_store.text
	price_store = soup.find('div', attrs={'class': 'price'})
	price = price_store.text
	if DEBUG(): t2 = datetime.now()
	if DEBUG(): total = t2 -t1
	return price

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-s', '--symbol', default="", help="symbol to fetch")
	args = parser.parse_args()
    ###################################
	s=args.symbol
	res=get_symbol(str(s))
	print res

if __name__ == '__main__':
	main()
