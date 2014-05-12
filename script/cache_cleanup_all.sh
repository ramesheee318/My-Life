set -xv

LOCKFILE=/tmp/cache_cleanup.lock
LOG=/tmp/cache_cleanup.log

if [ ! -f /tmp/cache_cleanup.lock ]; then
        touch  $LOCKFILE
        nice ruby /opt/ruby/CMS/CMS_Admin/script/runner CacheCleanup.expire -eproduction >> /opt/ruby/CMS/cache_cleanup.log
        rm  $LOCKFILE
        else
                date >> $LOG
                echo "Cache clean up script trying to execute while already running" >> $LOG
fi

