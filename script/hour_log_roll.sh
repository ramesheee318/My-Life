# !/bin/bash
#set -xv
echo "process hour log"
BIN=`basename $0`
DATE=`date +%H`
INLOGS=/home/ruby/logs  ### uncomment on 10-may-2012 for site based hour log report please uncomment the bleow line if not working properly
#INLOGS=/home/ruby/nginx_site_logs  ## this is for nginx
#OUTLOGS=/home/ruby/one_hour_logs ## please ucomment in case of apache
OUTLOGS=/home/ruby/one_hour_nginx_logs   ## this is for nginx
FILENAME=$1
HOST=`hostname -s`
LOGFILE=/home/ruby/hour_log_status.log
echo "$FILENAME"
echo "start process hour log $DATE" >> $LOGFILE

if [ -z $1 ]; then
	echo "$BIN <Log filename>|ALL to process all files ending in access_log in logs dirs" 
	exit 99
fi
#echo "start process before loop $DATE" >> $LOGFILE

#if [ $1 == 'ALL' ]; then
	#for LOG in $INLOGS/*access_log; do    ##please uncoment for apache access
	#for LOG in $INLOGS/*.access.log; do    ## this is for nginx log     		
	 for LOG in $INLOGS/access2-*-access.log; do    ## this is for site based nginx log edited at 10-may-2012 uncommeted above lines if not working properly
		BASE=`basename $LOG`
#	        echo $LOG >> $LOGFILE
#	 	echo $BASE >> $LOGFILE
		cat $LOG |  awk -F\: '$2 ~ /'$DATE'/ { print $0 }' > $OUTLOGS/$BASE.1HR.$HOST
#	echo "middele of process hour log" >> $LOG
	done
#else
#	if [ -f $INLOGS/$FILENAME ]; then
#	cat $INLOGS/$FILENAME | awk -F\: '$2 ~ /'$DATE'/ { print $0 }' > $OUTLOGS/$FILENAME.1HR.$HOST
#	else
#		echo "$INLOGS/$FILENAME does not exist"
#		exit 98
#	fi
#fi
echo "end process hour log $DATE" >> $LOGFILE

