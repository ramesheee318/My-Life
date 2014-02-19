
class LatestMostRead
def self.calculate_most_read(site_short_name,*filename)
      articles_count = {}
      site=Site.find_by_short_name(site_short_name)
      sections=site.sections.collect{|s| Regexp.escape(s.alias_name)}.join("|")
      sources=site.sources.collect{|s| Regexp.escape(s.alais_name)}.join("|")
      logger = Logger.new("#{Rails.root}/log/most_read.log")
      logger.error("Start time ==> #{Time.sr_now}")
      begin
        filename.each do |log_file|
          #puts "log file --> #{log_file}"
          input = IO.popen("tac #{log_file}","r")
          input.each do |line|
#         puts "#{line}"
           line=~/^\d+\.\d+\.\d+\.\d+\s-\s-\s\[(.+)\].*/i
            if line.match(/^\d+\.\d+\.\d+\.\d+\s-\s-\s\[(.+)\].*\/(#{sources})\/(#{sections})\/(\d+)\/[^\/]+\sHTTP.*"\s200.*/i)
              article_id =$4.strip.to_i
              articles_count[article_id] = ( articles_count[article_id] ) ?  articles_count[article_id]+1 : 1 if article_id
            end
          end
          input.close_read if not input.closed?
        end
        most_read = (articles_count.sort{|a,b| b[1]<=>a[1]}).slice(0..20)
        most_read_new = Hash[most_read]
        upto_sevendays_back = (Time.now - 2.month).strftime("%Y-%m-%d 00:00:00")
        today = Time.now.strftime("%Y-%m-%d 23:59:59")
        site.articles.scoped(:conditions=>["most_read >? and publish_date <?",0,"#{upto_sevendays_back}"]).update_all(:most_read=>0)
          most_read_old = {}
          site.articles.scoped(:conditions=>['most_read > 0']).collect{|a| most_read_old[a.id] = 0 }
         most_read_old.merge(most_read_new).sort_by{|k,v| -v.to_i}.collect do |a| #loop#
          if article = Article.find(:first,:conditions =>["id =? and publish_date >=? and publish_date <=?",a[0],"#{upto_sevendays_back}","#{today}"]) #condition#
            Article.update_all("most_read=#{a[1]}","id=#{a[0]}") if site.get_property('most_read_per_day').blank?
            MostReadPerHour.create(:data_proxy_id=>site.data_proxy_id,:article_id=>a[0],:most_read_count=>a[1])
            puts ("artcile #{a[0]} has  been read by #{a[1]}") #if site.get_property('most_read_per_day').blank?
            logger.error("artcile #{a[0]} has  been read by #{a[1]}") if site.get_property('most_read_per_day').blank?
          end  #condition#
         end #loop#  
        rescue => e
        logger.error( "error in reading #{e}")
      end
      logger.error("End time ==> #{Time.sr_now}")
    end
end
