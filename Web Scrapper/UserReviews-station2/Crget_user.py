#coding=utf-8
import urllib2
import re  # 正则表达式
import csv
import time
import os
import ssl
headers_value1={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'}
headers_value2={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'}

def get_code(con):
    #sleep_download_time = 1
    sleep_download_time = 20 + len(con)/2
    print "# sleeping: " + str(sleep_download_time)
    # time.sleep(sleep_download_time) #这里时间自己设定
    request = urllib2.Request(con, headers=headers_value1)  #访问网站，header防止250错误
    response = urllib2.urlopen(request, timeout=600)  # 得到网页源代码
    content = response.read()
    response.close()
    return content

def whole_pagenumber(con):
    content = get_code(con)
    pagenumberpattern=re.compile('<span class="pageInfo">Page 1 of (.*?)</span>')
    pagenumberlist=re.findall(pagenumberpattern,content)
    if len(pagenumberlist) == 0:
        pagenumber = 0
    else:
        pagenumber = int(pagenumberlist[1])
        if pagenumber > 51:#网站最多显示51页audience reviews
            pagenumber = 51
    return pagenumber

def get_review(con):
    #pattern = re.compile('<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> .*?</div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> .*?<br/> <em class="subtle">.*?</em> </div> </div> <div class="col-xs-16 review_container"> <div class=".*?"></div> <div class="review_area"> <div class="review_date subtle small"> .*?</div> <div class="review_desc"> <div class="the_review"> .*?</div> <div class="small subtle"> <a href=".*?" target="_blank"rel="nofollow">.*?</div> </div> </div> </div> </div>',re.S)
    pattern2 = re.compile('(<div class="row review_table_row">.*?</div> </div> </div>)')
    reviews = re.findall(pattern2,con)
    return reviews

def get_cID(con):
    cIDpattern = re.compile('<a class="bold unstyled articleLink" href="/user/id/(.*?)/">', re.S)
    cID = re.findall(cIDpattern,con)
    if len(cID) == 0:
        return 'Null'
    else:
        return '"' + str(cID[0]) + '"'
#<a class="bold unstyled articleLink" href="/user/id/956694313/"><span style="word-wrap:break-word"> Ezra S</span> </a>"
def get_cName(con):
##<a class="bold unstyled articleLink" href="/user/id/956694313/"><span style="word-wrap:break-word"> Ezra S</span> </a>"

    cNamepattern = re.compile('<span style="word-wrap:break-word"> (.*?)</span>', re.S)
    cName = re.findall(cNamepattern,con)
    if len(cName) == 0:
        return 'Null'
    else:
        return '"' + str(cName[0]) + '"'
def get_superreviewer(con):
#<div class="col-sm-7 col-xs-9 top_critic col-sm-push-13 superreviewer"> <div style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Super Reviewer</div> </div>
    SRpattern = re.compile('<div style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Super Reviewer</div>', re.S)
    SR = re.findall(SRpattern,con)
    if len(SR) == 0:
        return str(0)
    else:
        return str(1)

def get_date(con):
#<span class="fr small subtle">February 22, 2017</span>
    datepattern = re.compile('<span class="fr small subtle">(.*?)</span>', re.S)
    date = re.findall(datepattern,con)
    if len(date) == 0:
        return 'Null'
    else:
        return '"'+str(date[0])+'"'

def get_rateOrlag(con):#有问题如何使输入csv的数据不变格式;将main中的get_origScore换成这个函数
###star or not interested
#type 1: 4stars:<span style="color:#F1870A" class="fl"> <span class="glyphicon glyphicon-star"></span><span class="glyphicon glyphicon-star"></span><span class="glyphicon glyphicon-star"></span><span class="glyphicon glyphicon-star"></span></span>

#type 2: 4.5 stars:<span style="color:#F1870A" class="fl"> <span class="glyphicon glyphicon-star"></span><span class="glyphicon glyphicon-star"></span><span class="glyphicon glyphicon-star"></span><span class="glyphicon glyphicon-star"></span>&frac12;</span>

#type 3: not interested:<img src="https://d2a5cgar23scu2.cloudfront.net/static/images/rating/ni.png"/>

#type 4: want to see:<img src="https://d2a5cgar23scu2.cloudfront.net/static/images/rating/wts.png"/>

    rateIntpattern = re.compile('(glyphicon glyphicon-star)', re.S)
    rateDecpattern = re.compile('(&frac12)', re.S)
    lagpattern = re.compile('<img src="https://d2a5cgar23scu2.cloudfront.net/static/images/rating/(.*?).png"/>', re.S)

    rateIntpanel = re.findall(rateIntpattern,con)
    rateDecpanel = re.findall(rateDecpattern,con)
    lag = re.findall(lagpattern,con)
    if len(rateIntpanel) == 0 & len(rateDecpanel) == 0:
        if len(lag) == 0:
            return 'Null'
        else:
            return '"'+str(lag[0])+'"'
    else:
        return '"'+str(len(rateIntpanel)+0.5*len(rateDecpanel))+'"'



def get_comment(con):
#<div class="user_review" style="display:inline-block; width:100%"> <div class="scoreWrapper"><span class="40"></span></div> A little biased.</div>
    commentpattern = re.compile('<div class="user_review" style="display:inline-block; width:100%"> <div class="scoreWrapper">.*?</span></div> (.*?)</div>', re.S)
    comment = re.findall(commentpattern,con)
    # if comment[0] == ' ':
    if len(comment) == 0:
        return 'Null'
    else:
        return str('"'+str(comment[0]).replace('''"''' , '''#@#''')+'"')#防止评论中出现引号，因此将文中引号改为#@#


# def get_comment(con):
# # <div class="the_review"> The year\'s most inventive comedy.</div>
# # <div class="the_review"> </div>    
#     commentpattern = re.compile('<div class="the_review">(.*?)</div> ', re.S)
#     comment = re.findall(commentpattern,con)
#     if comment[0] == ' ':
#         return 'Null'
#     else:
#         return str('"'+str(comment[0]).replace('''"''' , '''#@#''')+'"')#防止评论中出现引号，因此将文中引号改为#@#







