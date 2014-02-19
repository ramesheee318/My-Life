((Tag.find(:all).collect{|aa| aa.name}).group_by{|elem| elem}.select{|key,val| val.length > 1}.map{|key,val| key}).collect do |dup_tag|
tag = Tag.find_all_by_name(dup_tag)
        if tag.count == 3
            arry_tag = tag.collect{|t| t.id}
             tag_id =  arry_tag[0]
               greatethentag = arry_tag[1]
  #debugger      
    if ((Tag.find "#{tag_id}").articles.count) == ((Tag.find "#{greatethentag}").articles.count)
#debugger
#   if ((Tag.find "#{tag_id}").articles.count)((Tag.find "#{greatethentag}").articles.count)
if not (Tag.find "#{tag_id}").articles.blank?
                                  (Tag.find "#{tag_id}").articles.collect do |article|
                                     if not (Tag.find "#{greatethentag}").article_ids.include?(article.id)
                                      #logger_up1.info("UPDATE articles_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and article_id = #{article.id}")
                                      ActiveRecord::Base.connection.execute("UPDATE articles_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and article_id = #{article.id}")
                                      #logger_up2.info("UPDATE article_contents_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and article_content_id = #{article.article_contents.last.id}")
                                      ActiveRecord::Base.connection.execute("UPDATE article_contents_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and article_content_id = #{article.article_contents.last.id}")
                                      else
                                      #logger_de1.info("delete from articles_tags where article_id = '#{article.id}' and tag_id = '#{tag_id}'")
                                      ActiveRecord::Base.connection.execute("delete from articles_tags where article_id = '#{article.id}' and tag_id = '#{tag_id}'")
                                      end
                                   end
                                      if not (Tag.find "#{tag_id}").site_ids.blank?
                                      (Tag.find "#{tag_id}").site_ids.collect do |site_id|
                                      site_tag = Tag.find(greatethentag).site_ids
                                        if not site_tag.include?(site_id)
                                        #logger_up3.info("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id}")
                                        ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id}")
                                        else
                                        #logger_de2.info("delete from sites_tags where data_proxy_id = '#{site_id}' and tag_id = '#{tag_id}'")
                                        ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id}' and tag_id = '#{tag_id}'")
                                         end
                                       end
                                      else
                                    # SITE BLANK
                                      end
                                else  #Article BLANK!
                                  if not (Tag.find "#{tag_id}").site_ids.blank?
                                     (Tag.find "#{tag_id}").site_ids.collect do |site_id|
                                       site_tag = Tag.find(greatethentag).site_ids
                                       if not site_tag.include?(site_id)
                                       #logger_up3.info("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id}")
                                       ActiveRecord::Base.connection.execute("UPDATE sites_tags set tag_id = #{greatethentag} where tag_id = #{tag_id} and data_proxy_id = #{site_id}")
                                       else
                                       #logger_de2.info("delete from sites_tags where data_proxy_id = '#{site_id}' and tag_id = '#{tag_id}'")
                                        ActiveRecord::Base.connection.execute("delete from sites_tags where data_proxy_id = '#{site_id}' and tag_id = '#{tag_id}'")
                                       end
                                      end
                                  else
                                    # SITES BLANK
                                  end
                                end
end
end
end

##########################################################
@tag = Tag.find(:all)
for tag in @tag
if tag.entity_type == "Image"
#debugger
t =  Tag.find "#{tag.id}"
ActiveRecord::Base.connection.execute("UPDATE tags set entity_type = 'Article' where id = #{t.id} ")
end
if tag.entity_type.blank?
t =  Tag.find "#{tag.id}"
#debugger
puts "#{t.id}"
ActiveRecord::Base.connection.execute("UPDATE tags set entity_type = 'Article' where id = #{t.id} ")
end
end

