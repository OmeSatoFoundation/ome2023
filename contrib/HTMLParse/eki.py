#!/usr/bin/env python3
#encoding:utf-8
#使用したAPIはHeart Rails Expressです
#https://express.heartrails.com/api.html

from __future__ import print_function
from bs4 import BeautifulSoup
import urllib.request
import sys
import urllib
import urllib.parse
def search_meaning(keido,ido):
	keido =urllib.parse.quote(keido)
	ido =urllib.parse.quote(ido)
	url = 'http://express.heartrails.com/api/xml?method=getStations&x='+keido+'&y='+ido
	html = urllib.request.urlopen(url)
	soup = BeautifulSoup(html, "xml")
	for i in  soup.find_all('station'):
		name = i.find('name').string
		line = i.find('line').string
		print(name+','+line)
	return 0

def main():
	argc = len(sys.argv)
	argv = sys.argv
	search_meaning(argv[1],argv[2])
	return 0
    
if __name__ == '__main__':
	main()
