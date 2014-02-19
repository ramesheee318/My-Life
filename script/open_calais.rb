require 'calais'
require 'json'
require 'ruby-debug'

class OpenCalais
  def self.tag_create(article_content)
  require 'calais'
    resp= Calais.enlighten( :content => article_content, :license_id => "n6bpk2ra4pg5qpygt686fxup",:output_format =>:json)
    json=ActiveSupport::JSON.decode(resp)
    @tags=[]
    json.values.each do |value|
      if value["name"] != nil
        @tags << value["name"]
      end
    end
    return @tags
  end

  def self.create_tag(site,options={})
    article=site.articles.find(options[:error_article])
    entity_tag= {}
      begin
        puts "----------------------------------------Tag creation start here------------------------------------------"
        resp= Calais.enlighten( :content => article.content, :content_type => :html, :license_id => "n6bpk2ra4pg5qpygt686fxup",:submitter => "kingston",:external_metadata =>"SocialTags",:output_format =>:json,:metadata_enables=>["SocialTags"])
        json=ActiveSupport::JSON.decode(resp)
        puts "----------------------------------------article =>#{article.id}-------------------------------------------"
        json.values.each do |value|
          if value["name"] != nil
            if value["_type"]
              entity_tag.merge!(value["name"] => value["_type"])
            elsif value["_typeGroup"] != nil
              entity_tag.merge!(value["name"] => value["_typeGroup"])
            else
              entity_tag.merge!(value["name"] => "socialTag")
            end
            else
              entity_tag.merge!("Social" => "socialTag")
           end
        end
        rescue
          entity_tag.merge!("Social" => "socialTag")
        end
        tags1 =[]
        entity_tag.each do |tag,entity|
          puts "Tag  and entity -----#{tag} => #{entity}-----"
          tag_name=Tag.find_by_alias_name(tag)
          if tag_name
            puts "-------------Tag is already there =>-----#{tag}---- id => #{tag_name.id}--"
            site_tag=site.tags.find_by_alias_name(tag)
            tag_name.site_ids +=[site.id] if not site_tag
            article_tag=article.tags.find_by_alias_name(tag)
            if article_tag == nil
            tags1 <<  tag_name.id
            end
            puts "----------------Tag =>#{tag}---------------------"
          else
            puts "----------Tag is not there =>#{tag}-------------------"
            new_tag=Tag.create(:name=>tag.capitalize,:entity_type =>"Article",:alias_name=>tag,:type => "ManualTag")
            new_tag.save
            new_tag.site_ids += [site.id]
            tags1 <<  new_tag.id
            puts "-----------New Tag =>#{tag}--------"
          end
          tag_entity=TagType.find_by_name(entity)
          if tag_entity
            puts " ------------Entity is there =>#{entity}----------------------------"
            tagname=Tag.find_by_alias_name(tag)
            if tagname
              tagentity=tagname.tag_types.find_by_name(entity)
              #tag_entity.tags += [tagname] if not tagentity
              tagname.tag_type_ids += [tag_entity.id] if not tagentity
            end
          else
            puts "-----------------------------New Entity =>#{entity}----------------------------------"
            new_entity=TagType.create(:name => entity)
            new_entity.save
            puts "-----------------------------Entity created =>#{new_entity.id}----------------------------------"
            #tagname.tag_types = [new_entity] if not new_entity
            # new_entity.tags += [tagname] if not new_entity
            name=Tag.find_by_alias_name(tag)
            name.tag_type_ids += [new_entity.id] if new_entity
          end
          puts "                                                                                                          "
        end
        tags1.uniq.each_with_index do |tag_id, i|
          article.articles_tags << ArticlesTag.new( :tag_id => tag_id, :sequence_number => i )
        end
        puts "---------------------------------------Tag creation end here----------------------------------"
  end

  def self.create_article_tag
      site=Site.find 32
      article=site.articles.find 2078382
       #for article in articles
      begin
        puts "----------------------------------------Tag creation start here------------------------------------------"
        resp= Calais.enlighten( :content => article.content, :content_type => :html, :license_id => "n6bpk2ra4pg5qpygt686fxup",:submitter => "kingston",:external_metadata =>"SocialTags",:output_format =>:json,:metadata_enables=>["SocialTags"])
        json=ActiveSupport::JSON.decode(resp)
        puts "----------------------------------------article =>#{article.id}-------------------------------------------"
        entity_tag= {}
        json.values.each do |value|
          if value["name"] != nil
            if value["_type"]
              entity_tag.merge!(value["name"] => value["_type"])
            elsif value["_typeGroup"] != nil
              entity_tag.merge!(value["name"] => value["_typeGroup"])
            else
              entity_tag.merge!(value["name"] => "socialTag")
            end
            else
              entity_tag.merge!("Social" => "socialTag")
           end
        end
        rescue
          entity_tag.merge!("Social" => "socialTag")
        end
        tags1 =[]
        entity_tag.each do |tag,entity|
          puts "Tag  and entity -----#{tag} => #{entity}-----"
          tag_name=Tag.find_by_alias_name(tag)
          if tag_name
            puts "-------------Tag is already there =>-----#{tag}---- id => #{tag_name.id}--"
            site_tag=site.tags.find_by_alias_name(tag)
            tag_name.site_ids +=[site.id] if not site_tag
            article_tag=article.tags.find_by_alias_name(tag)
            if article_tag == nil
            tags1 <<  tag_name.id
            end
            puts "----------------Tag =>#{tag}---------------------"
          else
            puts "----------Tag is not there =>#{tag}-------------------"
            new_tag=Tag.create(:name=>tag.capitalize,:entity_type =>"Article",:alias_name=>tag,:type => "ManualTag")
            new_tag.save
            new_tag.site_ids += [site.id]
            tags1 <<  new_tag.id
            puts "-----------New Tag =>#{tag}--------"
          end
          tag_entity=TagType.find_by_name(entity)
          if tag_entity
            puts " ------------Entity is there =>#{entity}----------------------------"
            tagname=Tag.find_by_alias_name(tag)
            if tagname
              tagentity=tagname.tag_types.find_by_name(entity)
              #tag_entity.tags += [tagname] if not tagentity
              tagname.tag_type_ids += [tag_entity.id] if not tagentity
            end
          else
            puts "-----------------------------New Entity =>#{entity}----------------------------------"
            new_entity=TagType.create(:name => entity)
            new_entity.save
            puts "-----------------------------Entity created =>#{new_entity.id}----------------------------------"
            #tagname.tag_types = [new_entity] if not new_entity
            # new_entity.tags += [tagname] if not new_entity
            name=Tag.find_by_alias_name(tag)
            name.tag_type_ids += [new_entity.id] if new_entity
          end
          puts "                                                                                                          "
        end
        tags1.uniq.each_with_index do |tag_id, i|
          article.articles_tags << ArticlesTag.new( :tag_id => tag_id, :sequence_number => i )
        end
        puts "---------------------------------------Tag creation end here----------------------------------"
     # rescue
       # end
   # end
  end

  def self.create_tag_with_entity(options={})
    site=Site.find 32
  #  articles=site.articles.latest.find(:all,:page=>{:size=>100,:auto=>true})
      articles=site.articles.latest.find(:all,:limit=>200,:offset=>300)
       for article in articles
      begin
        puts "----------------------------------------Tag creation start here------------------------------------------"
        resp= Calais.enlighten( :content => article.content, :content_type => :html, :license_id => "n6bpk2ra4pg5qpygt686fxup",:submitter => "kingston",:external_metadata =>"SocialTags",:output_format =>:json,:metadata_enables=>["SocialTags"])
        json=ActiveSupport::JSON.decode(resp)
        puts "----------------------------------------article =>#{article.id}-------------------------------------------"
        entity_tag= {}
        json.values.each do |value|
          if value["name"] != nil
            if value["_type"]
              entity_tag.merge!(value["name"] => value["_type"])
            else
              entity_tag.merge!(value["name"] => value["_typeGroup"])
            end
          end
        end
        tags1 =[]
        entity_tag.each do |tag,entity|
          puts "Tag  and entity -----#{tag} => #{entity}-----"
          tag_name=Tag.find_by_alias_name(tag)
          if tag_name
            puts "-------------Tag is already there =>-----#{tag}---- id => #{tag_name.id}--"
            site_tag=site.tags.find_by_alias_name(tag)
            tag_name.site_ids +=[site.id] if not site_tag
            article_tag=article.tags.find_by_alias_name(tag)
            if article_tag == nil
            tags1 <<  tag_name.id
            end
            puts "----------------Tag =>#{tag}---------------------"
          else
            puts "----------Tag is not there =>#{tag}-------------------"
            new_tag=Tag.create(:name=>tag.capitalize,:entity_type =>"Article",:alias_name=>tag,:type => "ManualTag")
            new_tag.save
            new_tag.site_ids += [site.id]
            tags1 <<  new_tag.id
            puts "-----------New Tag =>#{tag}--------"
          end
          tag_entity=TagType.find_by_name(entity)
          if tag_entity
            puts " ------------Entity is there =>#{entity}----------------------------"
            tagname=Tag.find_by_alias_name(tag)
            if tagname
              tagentity=tagname.tag_types.find_by_name(entity)
              #tag_entity.tags += [tagname] if not tagentity
              tagname.tag_type_ids += [tag_entity.id] if not tagentity
            end
          else
            puts "-----------------------------New Entity =>#{entity}----------------------------------"
            new_entity=TagType.create(:name => entity)
            new_entity.save
            puts "-----------------------------Entity created =>#{new_entity.id}----------------------------------"
            #tagname.tag_types = [new_entity] if not new_entity
            # new_entity.tags += [tagname] if not new_entity
            name=Tag.find_by_alias_name(tag)
            name.tag_type_ids += [new_entity.id] if new_entity
          end
          puts "                                                                                                          "
        end
        tags1.uniq.each_with_index do |tag_id, i|
          article.articles_tags << ArticlesTag.new( :tag_id => tag_id, :sequence_number => i )
        end
        puts "---------------------------------------Tag creation end here----------------------------------"
      rescue
        self.create_tag(site,{:error_article=>"#{article.id}"})
        end
    end
  end
end

