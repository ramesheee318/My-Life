#!/bin/bash
APPLICATIONPATH="/home/ubmkreatio/CMS/Kreatio-Kernel"
DELAYEDJOBPROCESS=`ps -ef | grep   delayed_job | awk '$8 == "delayed_job"' | awk '{print $8}' | uniq` 
FUTUREPORPUSE=``
if [ "$DELAYEDJOBPROCESS" != "delayed_job" ]
then
echo "delayed_job stoped"
cd $APPLICATIONPATH
ruby script/delayed_job start 
echo "delayed_job started"
    exit 1
else
echo "delayed_job running"
fi
