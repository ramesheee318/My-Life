require 'xml/libxml'
require 'RMagick'
require 'find'
require 'ruby-debug'
require "application_helper"
require 'calais'
# or 
require 'open_calais'
require 'nokogiri'
require 'json'
require 'logger'

# rails r TagCreateAndUpdate.migration

class TagCreateAndUpdate

 def self.migration
   site = Site.find_by_short_name "itnext"
  n = 0
 site.all_articles.find(:all,:conditions =>["created_by is null"]).each do | article | # nd_in_batches(start: 20, batch_size: 20) .each do | article  |
  ## tags = tag_create(article.content)
   tags = api_tag_popup_manager(article.content)
    xml_tag_ids = []
       if !tags.blank? and tags.each do | each_tag |
               find_tag =  Tag.find_by_name(each_tag.strip)
                if find_tag == nil
                find_tag =  Tag.create(:name => "#{each_tag.strip}",:entity_type => "Article")
                find_tag.save(:validate => false)
                end
                find_tag.data_proxy_ids = find_tag.data_proxy_ids + ["#{site.id}"]  if !find_tag.data_proxy_ids.include?(site.id)
                xml_tag_ids << find_tag.id if find_tag
               unless find_tag
                find_tag =  Tag.create(:name => "#{node.content.strip}",:entity_type => "Article")
                find_tag.save(:validate => false)
                find_tag.data_proxy_ids = find_tag.data_proxy_ids + ["#{site.id}"]  if !find_tag.data_proxy_ids.include?(site.id)
                xml_tag_ids << find_tag.id if find_tag
               logger.info("Tag create in DB #{each_tag.strip}")
               end
      end
    end
    n = 0
    xml_tag_ids.compact.flatten.uniq.each do | tag_id |
      n = n + 1
      if !article.tag_ids.include?(tag_id)
         if !article.tags.find_by_name(Tag.find(tag_id).name)
n = n + 1
puts ">>>>>>>>  count #{n}"
      puts "aaaa"
      article.article_contents.each do | each_article_content | 
      ActiveRecord::Base.connection.execute("insert into articles_tags ( article_id, tag_id ,sequence_number) values (#{article.id} , #{tag_id},#{n})")
      puts "acccc"
      article.article_contents.each do | each_article_content | 
      ActiveRecord::Base.connection.execute("insert into article_contents_tags ( article_content_id, tag_id ,sequence_number) values (#{each_article_content.id} , #{tag_id},#{n})")
      end
      puts ">>>>>>>>>>>>>>>>>>> #{article.id}"
        end
      end
    end
  end
 end


def self.tag_remove_into_article
 site = Site.find_by_short_name "itnext" 
 site.all_articles.find(:all,:conditions =>["created_by is null"]).each do | article |
 if  !article.tag_ids.blank? and article.tag_ids.each do | each_tag |
         article.article_contents.each do | each_article_content | 
         ActiveRecord::Base.connection.execute("delete from article_contents_tags where article_content_id = #{each_article_content.id} and tag_id = #{each_tag}")
         end
 ActiveRecord::Base.connection.execute("delete from articles_tags where article_id = #{article.id} and tag_id = #{each_tag}")
 end;end
end
end



  def self.tag_create(article_content)
 begin
      resp= Calais.enlighten( :content => article_content,:license_id => "n6bpk2ra4pg5qpygt686fxup",:output_format =>:json)
      json=ActiveSupport::JSSTDERR.puts "Please send the single argument,It's mean single html file Like: demo.html"ON.decode(resp)
      tags=[]
      json.values.each do |value|
        if value["name"] != nil
          tags << value["name"]
        end
      end
      return tags.first(8) rescue ""
    rescue
    end
  end



  def self.api_tag_popup_manager(article_content)
log = Logger.new("#{Rails.root}/log/open_calais_#{Time.sr_now.to_date.strftime("%d-%m-%Y")}")
  begin 
   open_calais = OpenCalais::Client.new(:api_key=>'n6bpk2ra4pg5qpygt686fxup')
   #response = open_calais.enrich(article_content)
   response = open_calais.enrich(URI.encode(article_content))
   relation_tags = []
    response.relations.each do | data |
       if not response.entities.collect{|aa| aa if aa[:guid] == data["position"] }.compact.blank?
       name = response.entities.collect{|aa| aa if aa[:guid] == data["person"] }.compact.first[:name]
       end
       if not response.entities.collect{|aa| aa if aa[:guid] == data["position"] }.compact.uniq.blank?
        career = response.entities.collect{|aa| aa if aa[:guid] == data["position"] }.compact.first[:name]
       end
    relation_tags <<  "#{name},#{career}" if name and career
    end
   tags =  (response.tags.collect{|t|  t[:name] } + response.topics.collect{|t| t[:name]} + relation_tags.uniq + response.entities.collect{|t| t[:name] if t[:type] == "Person" or t[:type] == "Company" or  t[:type] == "Position" or t[:type] == "Technology"}.compact).uniq 
   
   if tags.count >= 8
   return tags.first(8) rescue ""
   else
   log.info "\033[31m  This article #{article.id} open calais tag count :#{tags.count}"
   return tags rescue ""
   end  
   
  rescue
    debugger
    puts "Not allowed open calais :)"
    end 
  end

#[17976, 15602, 18102, 17957, 17219, 17233, 17222]
 



end


