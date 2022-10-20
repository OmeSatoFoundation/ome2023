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
    url = 'http://zip.cgis.biz/xml/zip.php?zn=' + urllib.parse.quote(sys.argv[1])
    html=urllib.request.urlopen(url)
    soup = BeautifulSoup(html, 'xml')
    value = soup.find_all('value')
    result = dict()
    for v in value:
        result.update(v.attrs)
    print(result['state'], end=',')
    print(result['city'], end=',')
    print(result['address'], end=',')

if __name__ == '__main__':
    main()

