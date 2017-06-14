#! /bin/bash
# This script is designed to generate some JSON data to store in SOLR
# USAGE:
#
# [usr@node]$ bash twitter-gen.sh TWEET_NUMBER SOLR/HDFS
#
#


# NUMBER OF TWEETS TO GENERATE
TWEET_NUM=$1
TWEETS_FILENAME=$2

if [ -z $TWEETS_FILENAME ]
then

	TWEETS_FILENAME="tweets.txt"

fi

TWEETS_FILENAME_JSON="$TWEETS_FILENAME.json"

declare -a keywords=(
		"\$MSFT"
		"\$GOOG"
		"\$DELL"
		"\$AAPL"
		"\$ORCL"
		"\$AMZN"
		"\$INTC"
		"\$AMD"
)
# LENGTH = 8

declare -a months=(
		"Jan"
		"Feb"
		"Mar"
		"Apr"
		"May"
		"Jun"
		"Jul"
		"Aug"
		"Sep"
		"Oct"
		"Nov"
		"Dec"
)
# LENGTH = 12

declare -a days=(
		"Sun"
		"Mon"
		"Tue"
		"Wed"
		"Thu"
		"Fri"
		"Sat"
)
# LENGTH = 12

declare -a languages=(
		"en"
		"en"
		"en"
		"und"
		"el"
		"sv"
		"es"
		"en"
		
)
# LENGTH = 8

declare -a timezones=(
		"Pacific Time (US & Canada)"
		"Pacific Time (US & Canada)"
		"Pacific Time (US & Canada)"
		"Eastern Time (US & Canada)"
		"Eastern Time (US & Canada)"
		"Eastern Time (US & Canada)"
		"Eastern Time (US & Canada)"
		"Eastern Time (US & Canada)"
		"Eastern Time (US & Canada)"
		"Greenland"
		"Central Time (US & Canada)"
		"Quito"
		"Amsterdam"
		"Rome"
		"Belgrade"
		"Ljubljana"
		"Arizona"
)
# LENGTH = 17



declare -a prefixes=(
		"Wow!"
		"That's unfortunate,"
		"I hope"
		"It's good to see that"
		""
		"I think"
		"It's good to see that"
)
# LENGTH = 7

declare -a suffixes=(
		"is really suffering today"
		"is up by 10%!"
		"is going down today"
		"needs to get get a better marketing team"
		"has a great new product coming soon!"
		"has been making great strides in innovation"
		"should probably develop their product more"
)
# LENGTH = 7

declare -a hashtags=(
		"#GoGOOG"
		"#MoneyInTheBank"
		"#BigData"
		"#Hadoop"
		"#disappointed"
		"#MSFTForTheWin"
		"#ORCLisChamp"
		"#BringInTheDough"
		"#CashMoney"
		"#CloudComputing"
)
# LENGTH = 10

declare -a users=(
		"msft_champ"
		"windows_user"
		"appleFanboy22"
		"bigshotCEO"
		"startup_owner11"
		"average_joe"
		"super_stacy"
		"semiconductor_man"
		"amazon_user"
		"bigshotCEO"
		"msft_champ"
)
# LENGTH = 11

# Some variables for filling in data
COUNT=0
YEAR_SECONDS=31536000
MONTH_SECONDS=2628288
DAY_SECONDS=86400

#Need to start off JSON doc.
echo "[ " >> $TWEETS_FILENAME_JSON

# Let's create some tweets
while [ $COUNT -lt $TWEET_NUM ]
do

	KEYWORD_NUM=$(($RANDOM % 8))
	PREFIX_NUM=$(($RANDOM % 7))
	SUFFIX_NUM=$(($RANDOM % 7))
	HASHTAG_NUM=$(($RANDOM % 10))
	USER_NUM=$(($RANDOM % 11))
	LANG_NUM=$(($RANDOM % 8))
	TIMEZONE_NUM=$(($RANDOM % 17))


	USER=${users[$USER_NUM]}
	HASHTAG=${hashtags[$HASHTAG_NUM]}
	SUFFIX=${suffixes[$SUFFIX_NUM]}
	PREFIX=${prefixes[$PREFIX_NUM]}
	KEYWORD=${keywords[$KEYWORD_NUM]}
	LANG=${languages[$LANG_NUM]}
	TIMEZONE=${timezones[$TIMEZONE_NUM]}

	YEAR=$(($RANDOM % 2 + 2014))
	MONTH=$(($RANDOM % 12))
	DAY=$(($RANDOM % 28 + 1))
	HOUR=$(($RANDOM % 24))
	MINUTE=$(($RANDOM % 60))
	SECOND=$(($RANDOM % 60))
	DAYNUM=$(( ($MONTH*30 + $DAY) % 7 ))
	DAYW=${days[$DAYNUM]}
	MONTHNAME=${months[$MONTH]}
	
	

	TIMESTAMP="$DAYW $MONTHNAME $DAY $HOUR:$MINUTE:$SECOND +0000 $YEAR"
	UNIXTIME=$(( (($YEAR*$YEAR_SECONDS)-(1970*$YEAR_SECONDS)) + (($MONTH*$MONTH_SECONDS)) + ($DAY*$DAY_SECONDS) ))
	TWEET_ID="$RANDOM$RANDOM"
	
	TWEET="$PREFIX $KEYWORD $SUFFIX $HASHTAG"
	
	JSON_DATA_LINE="{\"tweet_id\" : \"$TWEET_ID\", \"unixtime\" : \"$unixtime\", \"timestamp\" : \"$TIMESTAMP\", \"lang\" :\"$LANG\",\"user\" :\"$USER\", \"timezone\" :\"$TIMEZONE\", \"tweet_text\" : \"$TWEET\"}"
	DATA_LINE="$TWEET_ID|$UNIXTIME|$TIMESTAMP|$LANG|$USER|$TIMEZONE|$TWEET|$JSON_DATA_LINE"

	# Append to pipe-separated file
	echo "$DATA_LINE" >> $TWEETS_FILENAME
	# Append to the JSON file
	echo "$JSON_DATA_LINE,">> $TWEETS_FILENAME_JSON
	
	((COUNT++))

done

echo "{}\n]" >> $TWEETS_FILENAME_JSON
echo "Tweets finished generating."
echo "POSTing to Solr Index at http://sandbox.hortonworks.com:8983/solr/tweets_shard1_replica1/update"

curl 'http://sandbox.hortonworks.com:8983/solr/tweets_shard1_replica1/update?commit=true' --data-binary @$TWEETS_FILENAME_JSON -H 'Content-type:application/json'

echo "Moving tweets to directory \"/tmp/tweets_staging/\" in HDFS"

sudo -u hdfs hadoop fs -chmod -R 777 /tmp/data/
sudo -u hdfs hadoop fs -mkdir -p /tmp/data/
sudo -u hdfs hadoop fs -chown -R admin /tmp/data/
sudo -u hdfs hadoop fs -chmod -R 777 /tmp/tweets_staging/
sudo -u hdfs hadoop fs -mkdir -p /tmp/tweets_staging/
sudo -u hdfs hadoop fs -chown -R admin /tmp/tweets_staging/
hdfs dfs -copyFromLocal -f tweets.txt /tmp/tweets_staging/$TWEETS_FILENAME
sudo -u hdfs hadoop fs -chown -R admin /tmp/tweets_staging/$TWEETS_FILENAME


echo "Finished moving tweets to HDFS"
echo "Cleaning Up"

rm -f $TWEETS_FILENAME
rm -f $TWEETS_FILENAME_JSON

echo "Finished"












