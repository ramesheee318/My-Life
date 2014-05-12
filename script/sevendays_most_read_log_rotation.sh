#! /bin/shi

LOGS="/home/ubm/logs1"
OUPS="/home/ubm/one_hour_nginx_logs"
DATE="+%d\\/%b\\/%Y"
HOST=`hostname -s`
PROCESSDATE=`date  +%d:%b:%Y:%S`
REPORTLOG="/home/ubm/one_hour_nginx_logs/sevendays_most_read_log_status.log"
#`echo 0 > $OUP`
echo "start process most read hour log $PROCESSDATE" >> $REPORTLOG
echo "start process most read hour log $PROCESSDATE"
for LOG in $LOGS/mostread-*-access.log; do
BASE=`basename $LOG`
# Last 7 days from today #
`echo 0 > $OUPS/$BASE.1HR.$HOST`
for i in `seq 0 6`
do
SUBSTRACTIONLOOP=`date --date="-$i day" $DATE`
#echo "$SUBSTRACTIONLOOP"
#cat $LOG |  awk '/$SUBSTRACTIONLOOP/ { print $0 }' 
cat $LOG | awk /$SUBSTRACTIONLOOP/   >> $OUPS/$BASE.1HR.$HOST

echo "====> $OUPS/$BASE.1HR.$HOST"
done
done
echo "end process most read hour log $PROCESSDATE"
echo "end process most read hour log $PROCESSDATE" >> $REPORTLOG
echo "  * * * * * " >> $REPORTLOG

