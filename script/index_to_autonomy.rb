logger = Logger.new("#{RAILS_ROOT}/log/index_to_autonomy")
start_time=Time.sr_now
logger.debug("Time taken for Index to search engine #{start_time}")
sites = [Site.find 2]
sites.each do |site|
  articles = site.articles.find(:all,:order=>"publish_date desc",:page=>{:size=>1000,:auto=>true})
  articles.each do |article|
    article.index_to_search_engine
  end  
end
end_time=Time.sr_now
logger.debug("Time taken for Index to search engine #{end_time}")
logger.debug("Time taken for Index to search engine #{end_time-start_time}")