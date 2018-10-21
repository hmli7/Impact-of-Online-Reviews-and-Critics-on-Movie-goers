#coding=utf-8
import urllib2
import re  # 正则表达式
import csv
import time
import os
import Crget
import socket
import datetime
scriptpath = os.getcwd()
Parentpath = os.path.dirname(scriptpath)#得到脚本文件的母文件夹
source = open(os.path.join(Parentpath,'Data Source\MovienIndex\MovieIndex.csv'),'r')
#source = open('D:\Data Analysis\Graduation Project\Data Source\MovienIndex\MovieIndex.csv','r')
#target = open('D:\Data Analysis\Graduation Project\Data\Critics.csv', 'a') # 设置写入文件
record = open(os.path.join(Parentpath,'Data\Record.csv'), 'a+')#保存成功扒取的电影记录
target = open(os.path.join(Parentpath,'Data\Critics.txt'), 'a') # 设置写入文件
failfile = open(os.path.join(Parentpath,'Data\Critics_FailPage.csv'), 'a')
headers_value={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'}

box = source.readlines()
records = record.readlines()
startPageBox = records[-1].split(",")
startPage = int(startPageBox[-3])#从record文件中找到最后的记录，并设置爬虫起始页
pageInd = startPage
timeout = 600
for line in box[startPage+4:]:
    item=line.split(",")
    print len(item)
    if len(item)>3:
        movie = str(','.join(item[1:-1]))
    else:
        movie = str(item[1])
    mID = str(item[-1][:-1])
    print movie, mID
    break

