#!/usr/bin/env python3
#encoding:utf-8
from __future__ import print_function
from bs4 import BeautifulSoup
import urllib.request
import sys

def search_meaning(word):
	url = 'https://ejje.weblio.jp/content/' + word
	html = urllib.request.urlopen(url).read().decode('utf-8')
	soup = BeautifulSoup(html, 'html.parser')
	table = soup.find_all('span', 'content-explanation')
	return table[0].get_text()

def main():
    argc = len(sys.argv)
    if(argc < 1):
        sys.exit(1)
    meaning = search_meaning(sys.argv[1]).split('、')
    meaning[0] = meaning[0].replace("\n                ","")
    for i in meaning:
        print(i, end=',')
if __name__ == '__main__':
	main()

