#!/bin/sh

if test -z "$3" ; then
  echo "Usage: $0 <logs directory> <archive directory> <max days>"
  exit 1
fi

if test -d "$1" ; then
  SOURCE="$1"
else
  echo "Invalid directory \"$1\" specified"
  exit 1
fi

if test -d "$2" ; then
  TARGET="$2"
else
  echo "Invalid directory \"$2\" specified"
  exit 1
fi

if test "$3" -gt 0 ; then
  MAXDAYS="$3"
else
  echo "Invalid number of days \"$3\" specified"
  exit 1
fi

DATE=`date +"%Y%m%d-%H%M%S"`
#FILES=`find "$SOURCE" -maxdepth 1 -type f -name \*access_log\*`  ### for apache logs
FILES=`find "$SOURCE" -maxdepth 1 -type f -name \*access.log\*`  ## for nginx

for FILE in $FILES ; do
  NEWFILE="$SOURCE/`basename $FILE .log`-$DATE.log"
  mv "$FILE" "$NEWFILE"
done
# For Gentoo
# /opt/apache/bin/httpd -k graceful
#
# For RHEL
#/sbin/service httpd graceful

## for nginx
/etc/init.d/nginx restart


#apache2ctl graceful

for FILE in $FILES ; do
  NEWFILE="$SOURCE/`basename $FILE .log`-$DATE.log"
  MOVFILE="$TARGET/`basename $FILE .log`-$DATE.log.bz2"
  bzip2 -9 -c "$NEWFILE" > "$MOVFILE"
  rm -f "$NEWFILE"
done

find "$TARGET" -name \*.log.bz2 -mtime +"$MAXDAYS" | xargs rm -f

