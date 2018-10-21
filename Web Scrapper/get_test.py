#coding=utf-8
import urllib2
import re  # 正则表达式
import csv
import time
import os
import Crget
scriptpath = os.getcwd()
Parentpath = os.path.dirname(scriptpath)#得到脚本文件的母文件夹
target = open(os.path.join(Parentpath,'Data\\test.csv'), 'a') # 设置写入文件
target2 = open(os.path.join(Parentpath,'Data\\test2.csv'), 'a') # 设置写入文件
target3 = open(os.path.join(Parentpath,'Data\\test3.txt'), 'a') # 设置写入文件

pagecontents = open(os.path.join(Parentpath,'Data\\CodePattern.html'), 'r').read()
con_top = '<div class="row review_table_row"> <div class="col-xs-8"> <div class="col-sm-7 col-xs-16 critic_img"> <img class="critic_thumb fullWidth" src="https://resizing.flixster.com/1R_BDYWl5_GlkwkCTbHr2rgoGtw=/72x72/v1.YzsxNjUyO2c7MTcxNzc7MjA0ODszODszOQ" width="50px"/> </div><div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> <div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div></div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/richard-corliss/" class="unstyled bold articleLink">Richard Corliss</a> <br/> <em class="subtle">TIME Magazine</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> August 31, 2008</div> <div class="review_desc"> <div class="the_review"> The year\'s most inventive comedy.</div> <div class="small subtle"> <a href="http://www.time.com/time/magazine/article/0,9171,983768-1,00.html" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div>'
con_non_top = '<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/gary-wolcott/" class="unstyled bold articleLink">Gary Wolcott</a> <br/> <em class="subtle">Tri-City Herald</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> October 3, 2009</div> <div class="review_desc"> <div class="the_review"> The two films and the 10-minute intermission run just over 3 hours, bit much for the little ones who find sitting still that long agonizing.</div> <div class="small subtle"> <a href="http://www.tri-cityherald.com/1190/story/739582.html" target="_blank"rel="nofollow">Full Review</a> | Original Score: 5/5</div> </div> </div> </div> </div>'
con_non_cName = '<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <br/> <em class="subtle">Film4</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> March 10, 2008</div> <div class="review_desc"> <div class="the_review"> A children\'s film that has real staying power.</div> <div class="small subtle"> <a href="http://www.channel4.com/film/reviews/film.jsp?id=109502" target="_blank"rel="nofollow">Full Review</a> | Original Score: 5/5</div> </div> </div> </div> </div>'
con_rotten = '<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/jordan-raup/" class="unstyled bold articleLink">Jordan Raup</a> <br/> <em class="subtle">The Film Stage</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small rotten"></div> <div class="review_area"> <div class="review_date subtle small"> October 31, 2016</div> <div class="review_desc"> <div class="the_review"> The strangest thing about [Marvel\'s] latest feature is that all of these characters come across utterly bored with their vocations.</div> <div class="small subtle"> <a href="https://thefilmstage.com/reviews/review-doctor-strange/" target="_blank"rel="nofollow">Full Review</a> | Original Score: C+</div> </div> </div> </div> </div>'
con_non_score = '<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> <div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div></div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/richard-corliss/" class="unstyled bold articleLink">Richard Corliss</a> <br/> <em class="subtle">TIME Magazine</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> August 31, 2008</div> <div class="review_desc"> <div class="the_review"> The year\'s most inventive comedy.</div> <div class="small subtle"> <a href="http://www.time.com/time/magazine/article/0,9171,983768-1,00.html" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div>'
con_non_full = '<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/jeanne-aufmuth/" class="unstyled bold articleLink">Jeanne Aufmuth</a> <br/> <em class="subtle">Palo Alto Weekly</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> May 14, 2003</div> <div class="review_desc"> <div class="the_review"> A film of such striking individuality and uncompromising precocity that I left the theater thrilled with the knowledge that I had just witnessed cinematic history.</div> <div class="small subtle"> | Original Score: 4/4</div> </div> </div> </div> </div>'
conList = ['<div class="row review_table_row"> <div class="col-xs-8"> <div class="col-sm-7 col-xs-16 critic_img"> <img class="critic_thumb fullWidth" src="https://resizing.flixster.com/1R_BDYWl5_GlkwkCTbHr2rgoGtw=/72x72/v1.YzsxNjUyO2c7MTcxNzc7MjA0ODszODszOQ" width="50px"/> </div><div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> <div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div></div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/richard-corliss/" class="unstyled bold articleLink">Richard Corliss</a> <br/> <em class="subtle">TIME Magazine</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> August 31, 2008</div> <div class="review_desc"> <div class="the_review"> The year\'s most inventive comedy.</div> <div class="small subtle"> <a href="http://www.time.com/time/magazine/article/0,9171,983768-1,00.html" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div>'
,'<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/gary-wolcott/" class="unstyled bold articleLink">Gary Wolcott</a> <br/> <em class="subtle">Tri-City Herald</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> October 3, 2009</div> <div class="review_desc"> <div class="the_review"> The two films and the 10-minute intermission run just over 3 hours, bit much for the little ones who find sitting still that long agonizing.</div> <div class="small subtle"> <a href="http://www.tri-cityherald.com/1190/story/739582.html" target="_blank"rel="nofollow">Full Review</a> | Original Score: 5/5</div> </div> </div> </div> </div>'
,'<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <br/> <em class="subtle">Film4</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> March 10, 2008</div> <div class="review_desc"> <div class="the_review"> A children\'s film that has real staying power.</div> <div class="small subtle"> <a href="http://www.channel4.com/film/reviews/film.jsp?id=109502" target="_blank"rel="nofollow">Full Review</a> | Original Score: 5/5</div> </div> </div> </div> </div>'
,'<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/jordan-raup/" class="unstyled bold articleLink">Jordan Raup</a> <br/> <em class="subtle">The Film Stage</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small rotten"></div> <div class="review_area"> <div class="review_date subtle small"> October 31, 2016</div> <div class="review_desc"> <div class="the_review"> The strangest thing about [Marvel\'s] latest feature is that all of these characters come across utterly bored with their vocations.</div> <div class="small subtle"> <a href="https://thefilmstage.com/reviews/review-doctor-strange/" target="_blank"rel="nofollow">Full Review</a> | Original Score: C+</div> </div> </div> </div> </div>'
,'<div class="row review_table_row"> <div class="col-xs-8"> <div class="col-sm-7 col-xs-16 critic_img"> <img class="critic_thumb fullWidth" src="https://resizing.flixster.com/1R_BDYWl5_GlkwkCTbHr2rgoGtw=/72x72/v1.YzsxNjUyO2c7MTcxNzc7MjA0ODszODszOQ" width="50px"/> </div><div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> <div class="small" style="color:#3A9425"><span class="glyphicon glyphicon-star"></span> Top Critic</div></div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/richard-corliss/" class="unstyled bold articleLink">Richard Corliss</a> <br/> <em class="subtle">TIME Magazine</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> August 31, 2008</div> <div class="review_desc"> <div class="the_review"> The year\'s most inventive comedy.</div> <div class="small subtle"> <a href="http://www.time.com/time/magazine/article/0,9171,983768-1,00.html" target="_blank"rel="nofollow">Full Review</a> </div> </div> </div> </div> </div>'
,'<div class="col-sm-4 col-xs-8 top_critic col-sm-push-13"> </div> <div class="col-sm-13 col-xs-24 col-sm-pull-4 critic_name"> <a href="/critic/jeanne-aufmuth/" class="unstyled bold articleLink">Jeanne Aufmuth</a> <br/> <em class="subtle">Palo Alto Weekly</em> </div> </div> <div class="col-xs-16 review_container"> <div class="review_icon icon small fresh"></div> <div class="review_area"> <div class="review_date subtle small"> May 14, 2003</div> <div class="review_desc"> <div class="the_review"> A film of such striking individuality and uncompromising precocity that I left the theater thrilled with the knowledge that I had just witnessed cinematic history.</div> <div class="small subtle"> | Original Score: 4/4</div> </div> </div> </div> </div>']

reviews = Crget.get_review(pagecontents)
i=0
while i<len(reviews) :
	# con = conList[i]
	# cID = Crget.get_cID(reviews[i])
	# cName = Crget.get_cName(reviews[i])
	# comName = Crget.get_comName(reviews[i])
	# tomatoLogo = Crget.get_tomatoLogo(reviews[i])
	# topCritic = Crget.get_topCritic(reviews[i])
	# date = Crget.get_date(reviews[i])
	# origScore = Crget.get_origScore(reviews[i])
	# link = Crget.get_link(reviews[i])
	# comment = Crget.get_comment(reviews[i])
	#print comName, cID, cName, comName, tomatoLogo, topCritic, date, origScore, link
	#print comName
	
	#target3.write(comName+ ',' + '\n')
	item = reviews[i]
	target3.write(Crget.get_cID(item)+',')
	target3.write(Crget.get_cName(item)+',')
	target3.write(Crget.get_comName(item)+',')
	#target3.write(mID+',')
	#target3.write(movie+',')
	target3.write(Crget.get_tomatoLogo(item)+',')
	target3.write(Crget.get_topCritic(item)+',')
	target3.write(Crget.get_date(item)+',')
	target3.write(Crget.get_origScore(item)+',')
  	target3.write('\n') 
    # target2.write(Crget.get_cID(item)+',')
    # target2.write(Crget.get_comName(item)+',')
    # target2.write(mID+',')
    # target.write(Crget.get_link(item)+',')
    # target2.write(Crget.get_comment(item)+',')    
    # target2.write('\n')
	i+=1

