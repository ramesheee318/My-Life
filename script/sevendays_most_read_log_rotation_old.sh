#! /bin/shi
#LOG="/home/ubm/logs1/access2-www.lightreading.in-access.log"
LOG="/home/ubm/nginx_new/nginx/tmp1/logs/kreatio.nginx1.access.log"
OUP="/home/ubm/one_hour_nginx_logs/sevendays_most_read.log"
DATE="+%d\\/%b\\/%Y"
PROCESSDATE=`date  +%F/%T` # +%d:%b:%M:%S:%Y`
REPORTLOG="/home/ubm/one_hour_nginx_logs/sevendays_most_read_log_status.log"
`echo 0 > $OUP`
#echo "$DATE"
echo "start process most read hour log $PROCESSDATE" >> $REPORTLOG
echo "start process most read hour log $PROCESSDATE"
for i in `seq 0 6`
do
SUBSTRACTIONLOOP=`date --date="-$i day" $DATE`
#echo "$SUBSTRACTIONLOOP"
#echo "$LOG"
#cat $LOG |  awk '/$SUBSTRACTIONLOOP/ { print $0 }' 
cat $LOG | awk /$SUBSTRACTIONLOOP/   >> $OUP
#echo "$i"
done
echo "end process most read hour log $PROCESSDATE"
echo "end process most read hour log $PROCESSDATE" >> $REPORTLOG
echo "  * * * * * " >> $REPORTLOG
