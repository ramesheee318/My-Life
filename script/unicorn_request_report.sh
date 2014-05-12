#!/bin/bash
LOGFILE="/home/ubm/CMS/Admin/log/production.log"
REPORTFILE="$HOME/unicorn_report_log"
egrep -wi --color 'GET|Completed' $LOGFILE | awk '{print $1,""$2,""$3,""$5}' > $REPORTFILE
# (GET\s[".+[a-z0-9_.-i\/]+]?".+?)\d+.\d+.\d+.\d+\n(Completed\s200.*\d+ms)
