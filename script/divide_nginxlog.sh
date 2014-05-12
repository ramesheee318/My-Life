cd /home/ruby/logs
SITENAME=$1
SOURCENAME=$2
INLOGFILE=/home/ruby/logs/nginx.access.log
OUTLOGS=/home/ruby/nginx_site_logs
if [ -z $1 ]; then
	echo "please pass the site short name"
	exit 99
fi
if [ -z $2 ]; then
        echo "please pass the site source name"
        exit 99
fi

SITEFILENAME=$OUTLOGS/$SITENAME.access.log
#echo $SITENAME.acess.log
#echo $SITEFILENAME
`grep -r "$SOURCENAME" $INLOGFILE > $SITEFILENAME`
/home/ruby/script/hour_log_roll.sh $SITENAME.access.log
