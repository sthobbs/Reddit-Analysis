# -*- coding: utf-8 -*-
"""
Created on Mon Sep 14 18:28:59 2015
This program creates a MySQL database named db2, it fills with 100 tables
then fills those tables with data scraped off of reddit. It's currently set
to scrape reddit every 10 minutes. Leave this programming running for a while
to accumulate data, then use my R code 'Reddit Data Analysis.R' for real time
data analysis.

@author: Steve
"""

from urllib2 import Request, urlopen
from time import sleep
import json
import MySQLdb
from datetime import datetime

# MySQL database and table names
dbname='db2' # database name
common_table_name='post_rank' # tables will be named post_rank1,...etc.


# Connect to MySQL
con = MySQLdb.connect(host='localhost',user='root',passwd='')
cursor = con.cursor()

#cursor.execute('drop database db2;') # uncomment to delete db2

# Checks if database already exists, if not, then creates it 
database_exists=False
cursor.execute('show databases;')
for (database_name,) in cursor:
    if database_name==dbname:
        database_exists=True
if not database_exists:
    cursor.execute('create database '+dbname+';')


# Check if the 100 tables already exist, if not then create them
cursor.execute('use '+dbname+';')
for i in range(1,101):
    tblname=common_table_name+str(i) #post_ranki
    table_exists=False    
    cursor.execute('show tables;')
    for (table_name,) in cursor:     
        if table_name==tblname:
            table_exists=True
    if not table_exists:
        cursor.execute('create table '+tblname+'(\
        mysql_id int(11) unsigned auto_increment primary key not null,\
        date_time varchar(30) not null,\
        time_int int(11) not null,\
        domain varchar(50) not null,\
        subreddit varchar(50) not null,\
        score int(10) not null,\
        name varchar(9) not null,\
        num_comments int(11) not null);')

 
 # Close connection
con.commit() 
cursor.close()


# Get json data off of a url
# 2 second delay to comply with reddit rules
def get_json_data(URL,head,delay=2):
    '''Pretty generic call to urllib2.'''
    sleep(delay) # ensure we don't GET too frequently or the API will block us
    request = Request(URL, headers=head)
    try:
        response = urlopen(request)
        data = response.read()
    except:
        sleep(delay+5)
        response = urlopen(request)
        data = response.read()
    return data


# Process and extract the specific data I want
def process_data(url,num_posts):
    json_data=get_json_data(URL=url+'.json?limit='+str(num_posts),head=headers)
    decoded = json.JSONDecoder().decode(json_data)
    trimmed_data = [x['data'] for x in decoded['data']['children'] ]
    data = [ [ x['domain'], x['subreddit'], x['score'], x['name'],
              x['num_comments'], ] for x in trimmed_data ]
    return data

# scrape top 100 posts off reddit
# timeint is an integer which specifies the iteration number
# num_posts=100 is the number of posts to scrape off the top
def scrape_and_store(url,timeint,num_posts):
    data=process_data(url,num_posts)
    d=str(datetime.today()) # current date and time
    con = MySQLdb.connect(host='localhost',user='root',passwd='wiqpur',db=dbname)
    cursor = con.cursor()
    for i in range(num_posts):
        tblname=common_table_name+str(i+1)
        cursor.execute('insert into '+tblname+'(date_time, time_int,\
        domain, subreddit, score, name,num_comments) values\
        ("'+d+'", '+str(timeint)+', "'+str(data[i][0])+'",\
         "'+str(data[i][1])+'", '+str(data[i][2])+', "'+str(data[i][3])+'",\
         '+str(data[i][4])+');')
    con.commit() 
    cursor.close()

url='https://www.reddit.com/'
headers = {'User-agent':'top posts info scraper'}


def continuous_scraper(url,num_posts,delay=600):
    j=1
    while True:
        scrape_and_store(url,j,num_posts)
        sleep(delay-3)
        j=j+1

    
continuous_scraper(url,100,delay=600)


   
 
#### Sources:
# https://unsupervisedlearning.wordpress.com/2012/08/26/weekend-project-reddit-comment-scraper-in-python/
