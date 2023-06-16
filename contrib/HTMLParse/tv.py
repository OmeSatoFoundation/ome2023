#!/usr/bin/env python3
#encoding:utf-8
from __future__ import print_function
from bs4 import BeautifulSoup
import sys
import urllib
import urllib.request
import urllib.parse
def getprogram(word):
	word =urllib.parse.quote(word)
	url = 'https://www.tvkingdom.jp/schedulesBySearch.action?stationPlatformId=0&condition.keyword='+word+'&submit=%E6%A4%9C%E7%B4%A2'
	html = urllib.request.urlopen(url)
	soup = BeautifulSoup(html, 'html.parser')
	table = soup.findAll('div', class_='utileList')
	for i in range (0,len(table)):
		table[i]=table[i].get_text()
		table[i]=table[i].replace('\r\n',',')
		table[i]=table[i].replace('\n','')
		table[i]=table[i].replace(' ','')
		print(table[i])
		print('\n')
	return 0
def main():
	argc = len(sys.argv)
	argv = sys.argv
	if argc != 2:
		sys.exit(1)
	getprogram(argv[1])
	return 0

if __name__ == '__main__':
	main()
