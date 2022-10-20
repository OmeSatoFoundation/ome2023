#!/usr/bin/env python3
#encoding:utf-8
from __future__ import print_function
import sys
import urllib.request
import getopt
from bs4 import BeautifulSoup

all_args = {'print-headers': {'arg': ['', '--print-headers'], 'description': 'ヘッダーの表示'},
            'help': {'arg': ['-h', '--help'], 'description':'ヘルプを表示する'}}
def usage():
    global all_args
    print("{} options".format(sys.argv[0]))
    for k, v in all_args.items():
        print("{} {}: {}".format(v['arg'][0], v['arg'][1], v['description']))
    sys.exit()
def parse_opts():
    global print_with_headers
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'h', ['print-headers', 'help'])
    except getopt.GetoptError as e:
        print(e)
        usage()
    for o, a in opts:
        if o in all_args['print-headers']['arg']:
            print_with_headers = True
        if o in all_args['help']['arg']:
            usage()
print_with_headers = False 
def main():
    #アメダスのウェブページのURL
    url = 'http://tenki.jp/amedas/3/16/44056.html'
    with urllib.request.urlopen(url) as response:
        html=response.read()
    parse_opts()
    soup = BeautifulSoup(html, 'html.parser')
    #print(soup);
    # 最初の<table class="common-list-entries amedas-table-entries"> ... </table>を探す
    table = soup.find_all('table' ,attrs={'class' : 'common-list-entries amedas-table-entries'})[0] 
    # <table class="common-list-entries amedas-table-entries"></table>の中の<tr></tr>を2行分取り出す
    tr = [i for i in table.find_all('tr')[:2]] # ヘッダー、値の２行
    result = []
    for i in tr:
        result.append(i.text.strip())
    # 結果をヘッダーと値に分ける
    headers = [i for i in result[0].splitlines()]
    data    = [i for i in result[1].splitlines()]

    # 表示する
    if print_with_headers:
        print('青梅市のアメダスの記録(10分観測値)')
        for h, d in zip(headers, data):
            print(h,end=' : ')
            print(d,end=':')
    else:
        i = 0
        for d in data:
            if i == 0:
               #d = d.split(' ')[1] #extract time (format for this feild is 'date time')
               pass
            i += 1
            print(d, end=',')
    return 0
if __name__ == '__main__':
    sys.exit(main())
