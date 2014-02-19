class DupTest
def self.greater
logger = Logger.new("#{RAILS_ROOT}/log/duplicate_tag_update_site_ags.log") 
((Tag.find(:all).collect{|aa| aa.name}).group_by{|elem| elem}.select{|key,val| val.length > 1}.map{|key,val| key}).sort.collect do |dup_tag|
tag = Tag.find_all_by_name(dup_tag)

      if tag.count >= 2
        array = []
        tag.collect{|t| "#{t.articles.count}"}.sort.collect do |art|
          array << art.to_i
        end
        greatethentag = []

        tag.each do |each_tag|
          greatethentag <<  each_tag.id if each_tag.articles.count == array.sort[-1]
        end
        tag_ary =[]
        tag.each do |each_tag|
          array_new = array.sort - [array.sort[-1]]
          array_new.each do |art_count|
            tag_ary <<  each_tag.id if each_tag.articles.count == art_count
            (0...tag.collect{|t| "#{t.articles.count}"}.sort.count).each do |element|
            tag_array = tag_ary.uniq.to_a
          tag_array.each do |tag_id|
          if not (Tag.find "#{tag_id}").blank?
              if ((Tag.find "#{tag_id}").articles.count) == array.sort[element] and ((Tag.find "#{tag_id}").site_ids.count) < ((Tag.find "#{greatethentag[0].to_s.to_i}").site_ids.count) 
#                if (Tag.find "#{tag_id}").articles.count < array.sort[-1]
                (Tag.find "#{tag_id}").site_ids.collect do |site_id|
                                      site_tag = Tag.find(greatethentag[0].to_s.to_i).site_ids
                                        if not site_tag.include?(site_id)
                                 
site  =  Site.find(site_id)
#debugger
puts "#{[tag_id]}--->#{greatethentag[0].to_s.to_i}"
#                                        logger.info("#{[tag_id]}--->#{greatethentag[0].to_s.to_i}")
                                        ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag[0].to_s.to_i} where tag_id = #{tag_id} and data_proxy_id = #{site.data_proxy_id}")
                                        else
puts "----------------------------------------"
#                                        logger_de2.info("delete from sites_tags where data_proxy_id = '#{site_id}' and tag_id = '#{tag_id}'")
                                        ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id}' and tag_id = '#{tag_id}'")
                                         end
                                       end
 #               end
                end
                end
          
          end
          end
          end
        end
      end
    end
end

def self.two
logger = Logger.new("#{RAILS_ROOT}/log/duplicate_tag_update_site_ags.log")
 ((Tag.find(:all).collect{|aa| aa.name}).group_by{|elem| elem}.select{|key,val| val.length > 1}.map{|key,val| key}).sort.collect do |dup_tag|
  tag = Tag.find_all_by_name(dup_tag)
  
  if tag.count == 2
    if tag.first.articles.count == tag.second.articles.count

      if not tag.second.site_ids.blank? and not tag.first.site_ids.blank?
        if  tag.second.site_ids.count > tag.first.site_ids.count

          tag.first.site_ids.collect do |site_id|
        if not tag.second.site_ids.include?(site_id)
              site  =  Site.find(site_id)
              ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{tag.second.id} where tag_id = #{tag.first.id} and data_proxy_id = #{site.data_proxy_id}")
                else
            ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site.data_proxy_id}' and tag_id = '#{tag.first.id}'")   
         end
          end
        end
        
        if tag.first.site_ids.count > tag.second.site_ids.count
#debugger
          tag.second.site_ids.collect do |site_id|
    if not first.site_ids.include?(site_id)
              site  =  Site.find(site_id)
              ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{tag.first.id} where tag_id = #{tag.second.id} and data_proxy_id = #{site.data_proxy_id}")
       else
         ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site.data_proxy_id}' and tag_id = '#{tag.second.id}'")
            end
          end
        end
        
      end
      
    end
  end
end
end

end
