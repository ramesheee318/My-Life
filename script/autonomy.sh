#!/bin/bash
AUTONOMYPORT=`netstat -ntlup 4000 | awk '$6 == "LISTEN" && $4 ~ "\4000"'| awk '{print $4}'`
if [ "$AUTONOMYPORT" != "" ]
then
#    echo "Port is being used"
#    echo "$AUTONOMYPORT"
else
PROCESSDATE=`date  +%d:%b:%Y:%S`
REPORTLOG="$HOME/autonomy_stop_status.log"
echo "Autonomy Port is stoped $PROCESSDATE" >> $REPORTLOG
cd /opt/autonomy/dre/
echo "Autonomy Port is started $PROCESSDATE" >> $REPORTLOG
fi

