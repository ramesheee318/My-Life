site=Site.find_by_short_name("broking")
articles = site.articles.find(:all,:conditions=>{:is_draft => false},:page=>{:size=>1000,:auto=>true}) 
articles.each do |article|
  article.publish 
end
