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
    sleep_download_time = 95 + len(con)/2
    print "# sleeping: " + str(sleep_download_time)
    time.sleep(sleep_download_time) #这里时间自己设定
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
    return pagenumber

def get_review(con):
    # 正则表达式需要改！
    pattern = re.compile('<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> .*?</div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> .*?<br/> <em class="subtle">.*?</em> </div> </div> <div class="col-xs-16 review_container"> <div class=".*?"></div> <div class="review_area"> <div class="review_date subtle small"> .*?</div> <div class="review_desc"> <div class="the_review"> .*?</div> <div class="small subtle"> <a href=".*?" target="_blank"rel="nofollow">.*?</div> </div> </div> </div> </div>',re.S)
    pattern2 = re.compile('(<div class="row review_table_row">.*?</div> </div> </div> </div> </div>)')
    reviews = re.findall(pattern2,con)
    return reviews

def get_cID(con):
    cIDpattern = re.compile('<a href="/critic/(.*?)/"', re.S)
    cID = re.findall(cIDpattern,con)
    if len(cID) == 0:
        return 'Null'
    else:
        return '"' + str(cID[0]) + '"'
#<a href="/critic/gary-wolcott/"
def get_cName(con):
#class="unstyled bold articleLink">Gary Wolcott</a>
    cNamepattern = re.compile('class="unstyled bold articleLink">(.*?)</a>', re.S)
    cName = re.findall(cNamepattern,con)
    if len(cName) == 0:
        return 'Null'
    else:
        return '"' + str(cName[0]) + '"'

def get_comName(con):
#<em class="subtle">Tri-City Herald</em>
    comNamepattern = re.compile('<em class="subtle">(.*?)</em>', re.S)
    comName = re.findall(comNamepattern,con)
    if len(comName) == 0:
        return 'Null'
    else:
        return '"' + str(comName[0]) + '"'

def get_tomatoLogo(con):
#<div class="review_icon icon small fresh"></div>
    tomatoLogopattern = re.compile('<div class="review_icon icon small (.*?)"></div>', re.S)
    tomatoLogo = re.findall(tomatoLogopattern,con)
    if len(tomatoLogo) == 0:
        return 'Null'
    else:
        return tomatoLogo[0]

def get_topCritic(con):
#<div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div></div>
    topCriticpattern = re.compile('<div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div>', re.S)
    topCriticpattern2 = re.compile('Top Critic', re.S)
    top_critic = re.findall(topCriticpattern2,con)
    if len(top_critic) == 0:
        return '0'
    else:
        return '1'

def get_date(con):
#<div class="review_date subtle small"> August 31, 2008</div>
    datepattern = re.compile('<div class="review_date subtle small"> (.*?)</div>', re.S)
    date = re.findall(datepattern,con)
    if len(date) == 0:
        return 'Null'
    else:
        return '"'+str(date[0])+'"'

def get_origScore(con):#有问题如何使输入csv的数据不变格式
#<div class="small subtle"> <a href="http://www.tri-cityherald.com/1190/story/739582.html" target="_blank"rel="nofollow">Full Review</a> | Original Score: 5/5</div>
#</a> | Original Score: 5/5</div>
# <div class="small subtle"> <a href="http://www.time.com/time/magazine/article/0,9171,983768-1,00.html" target="_blank"rel="nofollow">Full Review</a> </div>
    origScorepattern = re.compile('<div class="small subtle">.*?Original Score: (.*?)</div>', re.S)
    origScore = re.findall(origScorepattern,con)
    if len(origScore) == 0:
        return 'Null'
    else:
        return '"'+str(origScore[0])+'"'

def get_link(con):
#<a href="http://www.tri-cityherald.com/1190/story/739582.html" target="_blank"rel="nofollow">Full Review</a>
# <div class="small subtle"> | Original Score: 4/4</div>
    linkpattern = re.compile('<div class="small subtle"> <a href="(.*?)".*?>Full Review</a>.*?</div>', re.S)
    link = re.findall(linkpattern,con)
    if len(link) == 0:
        return 'Null'
    else:
        return str('"'+link[0]+'"')

def get_comment(con):
# <div class="the_review"> The year\'s most inventive comedy.</div>
# <div class="the_review"> </div>    
    commentpattern = re.compile('<div class="the_review">(.*?)</div> ', re.S)
    comment = re.findall(commentpattern,con)
    if comment[0] == ' ':
        return 'Null'
    else:
        return str('"'+str(comment[0]).replace('''"''' , '''#@#''')+'"')#防止评论中出现引号，因此将文中引号改为#@#

# def set_movie_format(con):
#     return str('"'+str(comment[0]).replace('''"''' , '''#@#''')+'"')#防止评论中出现引号，因此将文中引号改为#@#








