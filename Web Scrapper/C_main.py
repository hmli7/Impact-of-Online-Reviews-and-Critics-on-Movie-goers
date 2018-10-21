#coding=utf-8
import urllib2
import re  # 正则表达式
import csv
import time
import os
import critic_get
source = open('D:\Data Analysis\Graduation Project\Data Source\MovienIndex\MovieIndex.csv','r')
target = open('D:\Data Analysis\Graduation Project\Data\Critics.csv', 'a') # 设置写入文件
failfile = open('D:\Data Analysis\Graduation Project\Data\Critics_FailPage.csv', 'w')
headers_value={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36'}

for line in source:
    item=line.split(",")
    movie = str(item[1][:-1])
    mID = str(item[2][:-1])
    RMovieURL = 'https://www.rottentomatoes.com/m/' + mID 
    RReviewURL = RMovieURL + '/reviews/'
    RAudienceURL = RReviewURL + '?type=user'
    print RMovieURL
    print RReviewURL
    print RAudienceURL
    ini_request = urllib2.Request(RReviewURL, headers=headers_value)  #访问网站，header防止250错误
    ini_response = urllib2.urlopen(ini_request)
    ini_content = ini_response.read()#.decode('GB2312')
    page=0
    docnumber_count=0
    max_page=whole_pagenumber(RReviewURL)#有问题啊有问题
    #time.sleep(10)
    #raw_input( )
    print max_page
    #os.system("pause")
    while page < max_page:
        page=page+1
        pageurl=RMovieURL+"?page="+str(page)+"&sort="
        failtime=0
        while 1:
            try:
                print pageurl
                response=get_code(pageurl)
                failtime=10
            except:
                failtime= failtime+1
                if failtime==10:
                    failfile.write('"'+movie+'",')
                    failfile.write('"'+pageurl+'",')
                    failfile.write('\n')
                    print "failure"
            if failtime >= 10:
                break
            #request = urllib2.Request(pageurl, headers=headers_value)  #访问网站，header防止250错误
            #response = urllib2.urlopen(request, timeout=100)  # 得到网页源代码
        content = response.read()# .decode('GB2312')
        pattern = re.compile('<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> .*?</div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> .*?<br/> <em class="subtle">.*?</em> </div> </div> <div class="col-xs-16 review_container"> <div class=".*?"></div> <div class="review_area"> <div class="review_date subtle small"> .*?</div> <div class="review_desc"> <div class="the_review"> .*?</div> <div class="small subtle"> <a href=".*?" target="_blank"rel="nofollow">.*?</div> </div> </div> </div> </div>',re.S)
        #<a href="/critic/greg-maki/" class="unstyled bold articleLink">Greg Maki</a> <br/> <em class="subtle">Star-Democrat (Easton, MD)</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> July 21, 2016</div> <div class="review_desc"> <div class="the_review"> ... A perfectly acceptable addition to the franchise.</div> <div class="small subtle"> <a href="http://www.stardem.com/blogs/moviereview/article_531f25cb-bd5c-5451-917b-6cdda5c48634.html" target="_blank"rel="nofollow">Full Review</a> | Original Score: B</div> </div> </div> </div> </div>
        #<a href="/critic/tara-thorne/" class="unstyled bold articleLink">Tara Thorne</a> <br/> <em class="subtle">The Coast (Halifax, Nova Scotia)</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> July 21, 2016</div> <div class="review_desc"> <div class="the_review"> The movie is very funny, but Holtzmann? She's the real otherworldly force here.</div> <div class="small subtle"> <a href="http://www.thecoast.ca/halifax/dear-kate-mckinnon/Content?oid=5522612" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div> 
        #<div class="row review_table_row"> <div class="col-xs-8"> <div class="col-sm-7 col-xs-16 critic_img"> <img class="critic_thumb fullWidth" src="https://resizing.flixster.com/1R_BDYWl5_GlkwkCTbHr2rgoGtw=/72x72/v1.YzsxNjUyO2c7MTcxNzc7MjA0ODszODszOQ" width="50px"/> </div> <div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> <div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div></div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/richard-corliss/" class="unstyled bold articleLink">Richard Corliss</a> <br/> <em class="subtle">TIME Magazine</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> August 31, 2008</div> <div class="review_desc"> <div class="the_review"> The year's most inventive comedy.</div> <div class="small subtle"> <a href="http://www.time.com/time/magazine/article/0,9171,983768-1,00.html" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div>
        line = re.findall(pattern,content)
        for item in line:
            if has_docurl(item):
                docnumber_count = docnumber_count+1
                target.write('"'+get_docname(item)+'",')
                target.write('"'+department+'",')
                target.write('"'+get_docurl(item)+'",')
                target.write('\n')