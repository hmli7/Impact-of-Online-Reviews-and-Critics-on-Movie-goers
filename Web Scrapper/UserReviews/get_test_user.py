#coding=utf-8
import urllib2
import re  # 正则表达式
import csv
import time
import os
import Crget_user
from bs4 import BeautifulSoup
scriptpath = os.getcwd()
Parentpath = os.path.dirname(scriptpath)#得到脚本文件的母文件夹
filepath = os.path.dirname(Parentpath)
# target = open(os.path.join(filepath,'Data\\UserReviewsData\\test.csv'), 'a') # 设置写入文件
# target2 = open(os.path.join(filepath,'Data\\UserReviewsData\\test2.csv'), 'a') # 设置写入文件
pagecontents1 = open(os.path.join(filepath,'Data\\UserReviewsData\\CodePattern.html'), 'r').read()
# pagecontents2 = Crget_user.get_code('https://www.rottentomatoes.com/m/mirrormask/reviews?page=13&type=user&sort=')
reviews = Crget_user.get_review(pagecontents1)
# soup = BeautifulSoup(reviews[3],"lxml")
# print soup
i=0
while i<len(reviews) :
	#cID = Crget_user.get_cID(reviews[i])
	#cName = Crget_user.get_cName(reviews[i])
	rateOrtag = Crget_user.get_rateOrlag(reviews[i])
	#comment = Crget_user.get_comment(reviews[i])
	SR = Crget_user.get_superreviewer(reviews[i])
	print rateOrtag, SR
	#target.write(cName+ ','+cID+ ','+rateOrtag+ ','+comment+ ','+SR+ ','+'\n')
	i+=1
	# item = reviews[i]
 #    target.write(Crget_user.get_cID(item)+',')
 #    target.write(Crget_user.get_cName(item)+',')
 #    target.write(Crget_user.get_comName(item)+',')
 #    target.write(mID+',')
 #    target.write(movie+',')
 #    target.write(Crget_user.get_tomatoLogo(item)+',')
 #    target.write(Crget_user.get_topCritic(item)+',')
 #    target.write(Crget_user.get_date(item)+',')
 #    target.write(Crget_user.get_origScore(item)+',')
 #    target.write('\n')
 #    target2.write(Crget_user.get_cID(item)+',')
 #    target2.write(Crget_user.get_comName(item)+',')
 #    target2.write(mID+',')
 #    target.write(Crget_user.get_link(item)+',')
 #    target2.write(Crget_user.get_comment(item)+',')
 #    target2.write('\n')

#target.write(pagecontents + ',')

#output
"976060126" "Mary%20 M" "ni" "One star for trying to interest people in musical performance forms. This is impossible when the leads can not sing, dance or play. Thank God there was some quality to the jazz. Otherwise, any episode of Glee is a better choice and shorter."
"955430664" "Mike R" "1.0" "China has proven they have the budgets and the scale and the directors to make Hollywood action flicks. But they&#39;ve been unable to portray humanity in any interesting way. I can only assume they see that as more dangerous than mythical dragons."
"956694313" "Ezra S" "4.0" "A little biased by a critics review that was a bit unfavorable but after seeing the movie for myself I find the critics review bollocks as evidenced in the difference between the critic&#39;s score and the user&#39;s score. He claimed the script was lousy and Matt couldn&#39;t decide which accent to use but I found no issues with either. The story is quite unique to me and I thought the the setting, the special effects and the cast fantastic. This is a great action slash sci-fi movie and the icing on the cake, it stars Damon. The fact that its still in theaters is proof its a good movie so treat yourself and enjoy and hope the baddies in this film never come to fruition."
"975897629" "Frank G" "4.5" "My criteria for rating a movie is simple. (1) Did it take me to a place I enjoyed going to for a few hours? (2) Did it do it well? My answers for the Great Wall are &quot;Yes&quot; and &quot;Yes&quot;. It is the recounting of a medieval legend about the real reason the Great Wall of China was built ... to stop a hoard of thousands of dragon type creatures from overrunning the countryside. The wall is manned by hundreds of Chinese, fully clothed in spectacular colorful armor, wielding lots of swords, spears, bows, arrows and gunpowder. In many scenes, those men and women are not CGI, they are the real thing (hundreds of extras were used in the movie). The film is the most expensive ever made in China and was filmed on the actual wall in 4K color. The scenery and cinematography are spectacular. The main characters are Chinese and speak Chinese, which they should be doing. To prevent audiences from watching the whole movie in sub-titles, an English speaking character is introduced (Matt Damon). He plays a mercenary who stumbles into the area just as the creatures are about to attack. A few of the Chinese main characters speak English also, so we get to witness this adventure in comfort. An adventure it is! <br/><br/>The battle scenes are action-packed, the weapons the good guys wield are awesome, the monsters are scary and believable. You like Damon&#39;s character ... he is a hero in the movie and that is fine. I like movies with some decent heroes, don&#39;t you? It is also very refreshing to watch a battle that does not involve some ruthless warriors cutting off other warrior&#39;s heads or driving swords through them. The world has so much man against man violence that it gets disgusting after a while. <br/><br/>This movie is a good adventure. Go see it. You WILL like it!"
"973095903" "Harry W" "ni" "I do not think Matt Damon is that popular in China or Far East like a Tom Cruise is!<br/>Read the plot and it is another of Hollywood&#39;s distorted history, this time with zombie type creatures."
"931920713" "Karen A" "wts" "I saw The Great Wall and I really liked it. Lots of action."
"975072162" "?? ?" "wts" "haven&#39;t seen the movie but looking forward to seeing the work of the best youth author in China."