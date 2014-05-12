#!/bin/bash
PROCESSDATE=`date  +%d:%b:%Y:%S`
REPORTLOG="$HOME/cache_replica_status.log"
touch $REPORTLOG
REPLICAPORT=`ps -ef | grep 54.251.250.32 | awk '$8 == "ruby"'| awk '{print $8}'`
if [ "$REPLICAPORT" != "" ]
then
#    echo "$REPLICAPORT"
else
echo "Cache Replication  stoped $PROCESSDATE" >> $REPORTLOG
cd /home/ruby/Nginx_Replication
ruby myserver_control.rb stop
ruby myserver_control.rb start
echo "Cache Replication starting $PROCESSDATE" >> $REPORTLOG
fi

##
#0 0 * * * sh replication_satuts.sh 
##
