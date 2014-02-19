 ((Tag.find(:all).collect{|aa| aa.name}).group_by{|elem| elem}.select{|key,val| val.length > 1}.map{|key,val| key}).sort.collect do |dup_tag|
  tag = Tag.find_all_by_name(dup_tag)
  if tag.count == 3
    if tag.first.articles.count > tag.second.articles.count
       if not tag.second.site_ids.blank? and not tag.first.site_ids.blank?
           puts "#{tag.first.id}--->#{[tag.second.id]}"
          end
          end
         if tag.second.articles.count > tag.third.articles.count
       if not tag.third.site_ids.blank? and not tag.second.site_ids.blank?
             
           tag.second.site_ids.collect do |site_id|
           if not tag.second.site_ids.include?(site_id)
                      site  =  Site.find(site_id)
                  ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{tag.second.id} where tag_id = #{tag.third.id} and data_proxy_id = #{site.data_proxy_id}")
           else
       site  =  Site.find(site_id) 
   ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site.data_proxy_id}' and tag_id = '#{tag.third.id}'")
                                
                    end
           puts "#{tag.second.id}--->#{[tag.third.id]}"
           end
          end
          end
     end
end
