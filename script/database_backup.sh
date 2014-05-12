cd /home/ruby
mkdir -p database_rsync_backup
export PGPASSWORD=postgres
/usr/bin/pg_dump -Upostgres -p5432 -hlocalhost cybermedia_new > /home/ruby/database_rsync_backup/cybermedia_new.sql 

