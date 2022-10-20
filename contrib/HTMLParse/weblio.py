#!/usr/bin/env python2
#encoding:utf-8
from __future__ import print_function
from bs4 import BeautifulSoup
import urllib2
import sys

def search_meaning(word):
	url = 'https://ejje.weblio.jp/content/' + word
	html = urllib2.urlopen(url).read().decode('utf-8')
	soup = BeautifulSoup(html, 'html.parser')
	table = soup.findAll('td', 'content-explanation')
	return table[0].get_text().encode('utf-8')

def main():
    argc = len(sys.argv)
    if(argc < 1):
        sys.exit(1)
    meaning = search_meaning(sys.argv[1]).split('、')
    for i in meaning:
        print(i, end=',')
if __name__ == '__main__':
	main()

