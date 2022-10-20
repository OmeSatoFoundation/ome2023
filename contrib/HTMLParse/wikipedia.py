#!/usr/bin/env python3
#encoding:utf-8
from __future__ import print_function
from bs4 import BeautifulSoup
import sys
    
import urllib.request
import urllib
import urllib.parse
def main():
    argc = len(sys.argv)
    argv = sys.argv
    if argc != 2:
        sys.exit(1)
    word =urllib.parse.quote(argv[1])
    url = "https://ja.wikipedia.org/wiki/" +word
    try:
        html=urllib.request.urlopen(url)
    except urllib.error.URLError as e:
        print(e)
        sys.exit(1)
    soup = BeautifulSoup(html, 'html.parser')
    #print(soup)
    ps = soup.find_all('p')
    for p in ps:
        print(p.get_text(), end=',')
if __name__ == '__main__':
    main()

