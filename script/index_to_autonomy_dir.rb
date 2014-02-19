s=Site.find_by_short_name("ireviews")
s.directory_listings.each do |dir|
dir.index_to_search_engine
end

