#!/usr/bin/env python3
#encoding:utf-8
import urllib.parse
import sys
def main():
    with open(sys.argv[1]) as f: 
        print(urllib.parse.unquote(f.readline()).rstrip(), end="")
if __name__ == '__main__':
    main()
