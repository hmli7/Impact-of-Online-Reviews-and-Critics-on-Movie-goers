#coding=utf-8
import urllib2
import re  # 正则表达式
import csv
import time
import os
import Crget_user
import socket
import datetime
scriptpath = os.getcwd()
Parentpath = os.path.dirname(scriptpath)#得到脚本文件的母文件夹
filepath = os.path.dirname(Parentpath)
source = open(os.path.join(filepath,'Data Source\MovienIndex\MovieIndex2-00-11_Del-1+repeat - 2.csv'),'r')
#source = open('D:\Data Analysis\Graduation Project\Data Source\MovienIndex\MovieIndex.csv','r')
#target = open('D:\Data Analysis\Graduation Project\Data\Critics.csv', 'a') # 设置写入文件
record = open(os.path.join(filepath,'Data\\UserReviewsData\\UserReviewRecords - 2.csv'), 'a+')#保存成功扒取的电影记录
target = open(os.path.join(filepath,'Data\\UserReviewsData\\UserReviews - 2.txt'), 'a') # 设置写入文件
target2 = open(os.path.join(filepath,'Data\\UserReviewsData\\UserTable - 2.txt'), 'a') # 设置写入文件
failfile = open(os.path.join(filepath,'Data\\UserReviewsData\\UserReviews_FailPage - 2.csv'), 'a')
headers_value1={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'}
headers_value2={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'}

box = source.readlines()
records = record.readlines()
startPageBox = records[-1].split(",")
startPage = int(startPageBox[-3])#从record文件中找到最后的记录，并设置爬虫起始页；由于电影名中有逗号，所以倒数取值
pageInd = startPage
timeout = 600
while 1:
    socket.setdefaulttimeout(timeout)#这里对整个socket层设置超时时间。后续文件中如果再使用到socket，不必再设置
    try:
        for line in box[startPage:]:
            pageInd+=1
            item=line.split(",")
            if len(item)>3: #如果部分电影名称中有逗号
                movie = str(','.join(item[1:-1]))
            else:
                movie = str(item[1])
            mID = str(item[-1][:-1])
            RMovieURL = 'https://www.rottentomatoes.com/m/' + mID
            RReviewURL = RMovieURL + '/reviews'
            RAudienceURL = RReviewURL + '/?type=user'
            print pageInd, movie, mID
            #ini_request = urllib2.Request(RReviewURL, headers=headers_value)  #访问网站，header防止250错误
            #ini_response = urllib2.urlopen(ini_request)
            #ini_content = ini_response.read()#.decode('GB2312')
            page=0
            docnumber_count=0
            max_page=Crget_user.whole_pagenumber(RAudienceURL)
            if max_page == 0: #若无评论页则记录并跳过
                #获得当前时间
                now = datetime.datetime.now()  #这是时间数组格式
                #转换为指定的格式:
                otherStyleTime = now.strftime("%Y-%m-%d %H:%M:%S")
                record.write(mID + ','  + str(pageInd) + ',' + otherStyleTime + ',' + '0' +'\n')#完成该电影所有页面扒取之后记录该电影到record文件
                print "# No critic exists……"
                continue
            #time.sleep(10)
            #raw_input( )
            print 'AmountOfPages = ' + str(max_page)
            #os.system("pause")
            while page < max_page:
                page=page+1
                #https://www.rottentomatoes.com/m/logan_2017/reviews/?type=user
                #https://www.rottentomatoes.com/m/logan_2017/reviews/?page=2&type=user&sort=
                pageurl=str(RReviewURL+"?page="+str(page)+"&type=user&sort=")
                failtime=0
                while 1:
                    try:
                        print '-'*60
                        print '# Loading: ' + pageurl
                        print '-Finished ' + str(page) + '/' + str(max_page) + ' pages of this movie'
                        print '-Still have ' + str(3377-pageInd) +'/3377 movies to go'
                        content=Crget_user.get_code(pageurl)
                        failtime=10
                    except:
                        print "## fail"
                        failtime= failtime+1
                        if failtime==10:
                            #获得当前时间
                            now = datetime.datetime.now()  #这是时间数组格式
                            #转换为指定的格式:
                            otherStyleTime = now.strftime("%Y-%m-%d %H:%M:%S")
                            failfile.write(otherStyleTime+',')
                            failfile.write("page"+',')
                            failfile.write(mID+',')
                            failfile.write(pageurl+',')
                            failfile.write('\n')
                            print "## failure"
                    if failtime >= 10:
                        break
                    #request = urllib2.Request(pageurl, headers=headers_value)  #访问网站，header防止250错误
                    #response = urllib2.urlopen(request, timeout=100)  # 得到网页源代码
                #content = response.read()# .decode('GB2312')
                #pattern = re.compile('<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> .*?</div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> .*?<br/> <em class="subtle">.*?</em> </div> </div> <div class="col-xs-16 review_container"> <div class=".*?"></div> <div class="review_area"> <div class="review_date subtle small"> .*?</div> <div class="review_desc"> <div class="the_review"> .*?</div> <div class="small subtle"> <a href=".*?" target="_blank"rel="nofollow">.*?</div> </div> </div> </div> </div>',re.S)
                #<a href="/critic/greg-maki/" class="unstyled bold articleLink">Greg Maki</a> <br/> <em class="subtle">Star-Democrat (Easton, MD)</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> July 21, 2016</div> <div class="review_desc"> <div class="the_review"> ... A perfectly acceptable addition to the franchise.</div> <div class="small subtle"> <a href="http://www.stardem.com/blogs/moviereview/article_531f25cb-bd5c-5451-917b-6cdda5c48634.html" target="_blank"rel="nofollow">Full Review</a> | Original Score: B</div> </div> </div> </div> </div>
                #<a href="/critic/tara-thorne/" class="unstyled bold articleLink">Tara Thorne</a> <br/> <em class="subtle">The Coast (Halifax, Nova Scotia)</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> July 21, 2016</div> <div class="review_desc"> <div class="the_review"> The movie is very funny, but Holtzmann? She's the real otherworldly force here.</div> <div class="small subtle"> <a href="http://www.thecoast.ca/halifax/dear-kate-mckinnon/Content?oid=5522612" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div> 
                #<div class="row review_table_row"> <div class="col-xs-8"> <div class="col-sm-7 col-xs-16 critic_img"> <img class="critic_thumb fullWidth" src="https://resizing.flixster.com/1R_BDYWl5_GlkwkCTbHr2rgoGtw=/72x72/v1.YzsxNjUyO2c7MTcxNzc7MjA0ODszODszOQ" width="50px"/> </div> <div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> <div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div></div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/richard-corliss/" class="unstyled bold articleLink">Richard Corliss</a> <br/> <em class="subtle">TIME Magazine</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> August 31, 2008</div> <div class="review_desc"> <div class="the_review"> The year's most inventive comedy.</div> <div class="small subtle"> <a href="http://www.time.com/time/magazine/article/0,9171,983768-1,00.html" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div>
                print "## Start scrap"
                #line = re.findall(pattern,content)
                line = Crget_user.get_review(content)
                print "## Start printinfo"
                for item in line:
                    docnumber_count = docnumber_count+1
                    target.write(Crget_user.get_cID(item)+',')
                    target.write(Crget_user.get_date(item)+',')
                    target.write(mID+',')
                    target.write(Crget_user.get_rateOrlag(item)+',')
                    target.write(Crget_user.get_comment(item)+',')
                    target.write(Crget_user.get_cName(item)+',')
                    target.write('\n')

                    target2.write(Crget_user.get_cID(item)+',')
                    target2.write(Crget_user.get_cName(item)+',')
                    target2.write(Crget_user.get_superreviewer(item)+',')
                    target2.write(pageurl+',')
                    target2.write('\n')
            #获得当前时间
            now = datetime.datetime.now()  #这是时间数组格式
            #转换为指定的格式:
            otherStyleTime = now.strftime("%Y-%m-%d %H:%M:%S")
            record.write(mID + ',' + str(pageInd) + ',' + otherStyleTime + ',' + '1' +'\n')#完成该电影所有页面扒取之后记录该电影到record文件
            print "Successfully finished"
                #cID,cName,comName,mID,movie,tomatoLogo,topCritic,date,origScore,link

    except (urllib2.HTTPError) as err:
        print 'HTTPError = ' + str(err)
        #获得当前时间
        now = datetime.datetime.now()  #这是时间数组格式
        #转换为指定的格式:
        otherStyleTime = now.strftime("%Y-%m-%d %H:%M:%S")
        failfile.write(otherStyleTime+',')
        failfile.write("HTTPError"+',')
        failfile.write(mID+',')
        succNum = str(pageInd - startPage - 1)
        failfile.write(succNum+',')
        failfile.write(str(err)+',')
        failfile.write('\n')

    except (urllib2.URLError) as err:
        print 'URLError = ' + str(err)
        print 'Reason = ' + str(err.reason)
        #获得当前时间
        now = datetime.datetime.now()  #这是时间数组格式
        #转换为指定的格式:
        otherStyleTime = now.strftime("%Y-%m-%d %H:%M:%S")         
        failfile.write(otherStyleTime+',')
        failfile.write("URLError"+',')
        failfile.write(mID+',')
        succNum = str(pageInd - startPage - 1)
        failfile.write(succNum+',')
        failfile.write(str(err)+',')
        failfile.write('\n')
    if timeout <= 400:
        timeout += 20
    else:
        print ("Website exp……")
        break

