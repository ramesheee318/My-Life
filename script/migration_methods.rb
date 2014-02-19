require "application_helper"
require 'libxml'
require 'find'
require 'ruby-debug'

class MigrationMethods
  
  # :Export => "API  For Export"
  
  def self.find_for_proxy_name(xml,comp_node)
    if !comp_node.presentation_proxy_id.blank?
      @site = Site.find(comp_node.presentation_proxy_id)
      xml.presentation_proxy_name "#{@site.short_name}"
    end
  end
  
  def self.introduction(xml,site)
    xml.site("short_name" => "#{site.short_name}")
    xml.language("id" => "en")
  end
  
  
  def self.find_for_params_data_ids(group_ids,params)
    if !params[:export_data].blank?
      if !params[:export_data]["#{group_ids[0].to_sym}"].blank?
        return false
      else
        return true
      end
    else
      return true
    end
  end
  
  def self.export_for_asset_groups(xml,assetgroup,logger)     
    logger.info("Asset Grop --------------> #{assetgroup.name}")
    xml.asset_group("name" => "#{assetgroup.name}") do
      if !( asset_conditions = assetgroup.asset_conditions).blank?
        for asset_condition in asset_conditions
          hash_condition = {"AssetConditionCategory" => "categories", "AssetConditionTag" => "tags", "AssetConditionSection" => "sections", "AssetConditionSource" => "source"}
          hash_other_condition = { "AssetConditionNewerThan" => "get_condition.to_time.strftime('%d-%m-%Y')",
                                                                 "AssetConditionOlderThan" => "get_condition.to_time.strftime('%d-%m-%Y')",
                                                                 "AssetConditionPremium" => "premium","AssetConditionMagazineIssue" => "magazine_issue",
                                                                 "AssetConditionAudioOrVideoArticle" => "audio_or_video_article",
                                                                 "AssetConditionAudioArticle" => "audio_article",
                                                                 "AssetConditionVideoArticle" => "video_article",
                                                                 "AssetConditionLatestMagazineIssueFromSource" => "latest_magazine_issue_from_source"}
          hash_fields = {"AssetConditionCategory" => "Category", "AssetConditionSection" => "Section","AssetConditionTag" =>"Tag","AssetConditionSource"=>"Source","AssetConditionNewerThan" => "newer_than","AssetConditionOlderThan" => "older_than","AssetConditionPremium" => "premium","AssetConditionMagazineIssue" => "magazine_issue","AssetConditionAudioOrVideoArticle" => "audio_or_video_articles","AssetConditionAudioArticle" => "audio_articles","AssetConditionVideoArticle" => "video_articles","AssetConditionLatestMagazineIssueFromSource" => "latest_magazine_from_source"}
          hash_values = { "AssetConditionCategory" => "full_alias_name", "AssetConditionSection" => "alias_name","AssetConditionTag" =>"alias_name","AssetConditionSource"=>"alais_name"}  
          if hash_condition[asset_condition.class.name] 
            xml.asset_condition("type" => asset_condition.class.name) do
              for assetvalue in [asset_condition.send(hash_condition[asset_condition.class.name])].flatten
                xml.assetvalue( "#{assetvalue.send(hash_values[asset_condition.class.name])}" ,"type" => "#{hash_fields[asset_condition.class.name]}")
              end
            end 
          elsif hash_other_condition[asset_condition.class.name]
            xml.asset_condition("type" => asset_condition.class.name) do
              for assetvalue in [asset_condition.send(hash_other_condition[asset_condition.class.name])].flatten
                xml.assetvalue( "#{assetvalue.send(hash_values[asset_condition.class.name])}" , "type" => "#{hash_fields[asset_condition.class.name]}")
              end
            end 
          else
          end                                                                    
        end 
      end        
    end
  end  
  
  
  def self.export_for_author(xml,site,each_author,n,file_path,logger)
    xml.author("count" => "#{n}") do
      logger.info("Authour name ==> #{each_author.name}") if xml.firstname "#{each_author.name}"
      xml.middle_name "#{each_author.middle_name}"
      xml.lastname "#{each_author.lastname}"
      xml.fullname "#{each_author.fullname}"
      xml.email "#{each_author.email}"
      if !each_author.image.blank?
        image_path = each_author.image.image_path rescue ""
        if !image_path.blank?
          xml.image_path "#{each_author.image.image_path}" 
          logger.info("Authour image path ====>#{each_author.image.image_path}") 
          if !each_author.image.image_id.blank?
            image_path_id = Image.find(each_author.image.image_id)
            if image_path_id
              orginal_image_path = "#{Rails.root}"+"/public"+"#{image_path_id.image_path}"
              new_directroy =(FileUtils.mkdir_p "#{file_path}"+image_path_id.generate_image_folder_path(image_path_id.id)).first
              img_file_name= (image_path_id.image_path.split('/').last)
              duplicate_image_path="#{new_directroy}/#{img_file_name}"
              if File.exist?(orginal_image_path)
                FileUtils.cp_r orginal_image_path,duplicate_image_path
              else
                puts "Image Path does not exists on public Folder $$$$$$$$$$$$$$$$$$$$$$$"  
              end
            end
          end
        else
          xml.image_path "Image path not exists on Table"
          puts "Image path not exists? on Table *******************"
        end
      end
      xml.author_profile do
        each_author.author_profiles.each do | author_profile |
          xml.professional_title "#{author_profile.professional_title}";  xml.title "#{author_profile.title}";  xml.company_name "#{author_profile.company_name}";  xml.company_website_url "#{author_profile.company_website_url}";  xml.meta_description "#{author_profile.meta_description}";  xml.meta_keywords "#{author_profile.meta_keywords}";  xml.meta_title "#{author_profile.meta_title}";  xml.twitter_url "#{author_profile.twitter_url}";  xml.twitter_user_name "#{author_profile.twitter_user_name}";  xml.description "#{author_profile.description}";  xml.linkedin_url "#{author_profile.linkedin_url}";  xml.biography "#{author_profile.biography}";  xml.facebook_url "#{author_profile.facebook_url}";  xml.youtube_url "#{author_profile.youtube_url}";  xml.blog_url "#{author_profile.blog_url}";  xml.recommendation "#{author_profile.recommendation}";  xml.company_linkedin_url "#{author_profile.company_linkedin_url}";  xml.google_plus "#{author_profile.google_plus}"
        end
      end
    end
  end
  
  
  def self.export_for_category(xml,each_category,who,logger)
    logger.info("#{who} ------> #{each_category.name}")
    xml.name "#{each_category.name}"
    xml.alias_name "#{each_category.alias_name}"
    xml.full_name "#{each_category.full_name}"
    xml.full_alias_name "#{each_category.full_alias_name}"
    xml.sequence_number("order" => "#{each_category.sequence_number}")
    xml.parent_full_alias_name "#{each_category.parent_full_alias_name}"
  end  
  
  
  def self.export_for_data_lits(xml,data_count,logger)
    xml.display_name data_count.display_name if !data_count.display_name.blank?
    xml.data_string data_count.data_string
    logger.info("data list type:--------> #{data_count.data_list_type}") if xml.data_list_type data_count.data_list_type
    xml.name data_count.name
    xml.entity data_count.entity
    xml.sort data_count.sort
    xml.data_list_type data_count.data_list_type
    xml.paginate data_count.paginate if !data_count.paginate.blank?
    xml.automated_data_string data_count.automated_data_string
    xml.ranklist data_count.ranklist if !data_count.ranklist.blank?
  end
  
  
  
  def self.export_for_menu(xml,each_menu,who,logger)
    logger.info("#{who} -----------> #{each_menu.name}")
    xml.name "#{each_menu.name}"
    xml.alias_name "#{each_menu.alias_name}"
    xml.entity_type "#{each_menu.entity_type}"
    xml.sequence_number("order" => "#{each_menu.sequence_number}")
    xml.category_name "#{each_menu.category_name}"
    xml.parent_name each_menu.parent_name
  end               
  
  def self.export_for_pages(xml,page,logger)
    logger.info("page  -----> #{page.type}") if xml.type page.type
    xml.page_name page.page_name
    xml.url page.url
    xml.template page.template
    xml.layout page.layout
    xml.layout_required page.layout_required
    xml.active page.active
    xml.cache page.cache
  end
  
  
  
  def self.export_for_ranklits(xml,content,logger)
    for featured_set in content.featured_sets
      logger.info("Ranklist -----------> #{featured_set.name}") 
      xml.rank_list("name" => "#{featured_set.name}") do 
        if !(assetgroup = featured_set.asset_group).blank?
          asset_groups(xml,assetgroup,logger)
        end
      end
    end
  end  
  
  
  
  
  
  # :Import => "API  For Import" :: MigrationMethods
  AssetGroup.inspect
  AssetConditionSite.inspect
  def self.create_for_asset_group(doc,site,asset_group_node,logger)
    asset_group = AssetGroup.new(:name => asset_group_node['name'],:description => asset_group_node['name'] )  
    doc.find("#{asset_group_node.path}/asset_condition").each do | asset_condition_node |
      asset_condition = asset_condition_node['type'].constantize.new()
      doc.find("#{asset_condition_node.path}/assetvalue").each do | attribute | 
        if attribute['type'] == "Section"
          asset_condition.section_ids = [site.sections.find_by_alias_name(attribute.content).id.to_s] if !site.sections.find_by_alias_name(attribute.content).blank?
        elsif attribute['type'] == "Category"
          asset_condition.category_ids = [site.categories.find_by_full_alias_name(attribute.content).id.to_s] if !site.categories.find_by_full_alias_name(attribute.content).blank?
        elsif attribute['type'] == "Tag" 
          asset_condition.tag_ids = [site.tags.find_by_alias_name(attribute.content).id.to_s] 
        elsif attribute['type'] == "Source"  
          asset_condition.source_id = site.sources.find_by_alais_name(attribute.content).id
        elsif attribute['type'] == "newer_than"
          asset_condition.newer_than = attribute.content
        elsif attribute['type'] == "older_than"
          asset_condition.older_than = attribute.content
        elsif attribute['type'] == "premium"
          asset_condition.premium = attribute.content
        elsif attribute['type'] ==  "magazine_issue"
          asset_condition.magazine_issue = attribute.content
        elsif attribute['type'] == "audio_or_video_articles"
          asset_condition.audio_or_video_article =attribute.content
        elsif attribute['type'] ==  "audio_articles"
          asset_condition.audio_articles = attribute.content
        elsif attribute['type'] ==  "video_articles"
          asset_condition.video_article = attribute.content
        elsif attribute['type'] ==  "latest_magazine_from_source"
          asset_condition.latest_magazine_issue_from_source = attribute.content
        end
        asset_group.asset_conditions << asset_condition_site = AssetConditionSite.new(:data_proxy_ids=> "#{site.data_proxy.id}" )
        asset_group.asset_conditions <<  asset_condition     
      end     
      return asset_group if asset_group.save
    end
    # loop from ass group
  end
  
  
  
  Author.inspect
  AuthorProfile.inspect
  def self.create_for_author(doc,site,logger)
   doc.find('/site/Authors/author').each do | each_author_node |
    if !doc.find("#{each_author_node.path}/email").first.blank?
      email = doc.find("#{each_author_node.path}/email").first.content
      author = Author.find_by_email(email)
      if author.blank?
    new_author = Author.new
    middle_name =  doc.find("#{each_author_node.path}/middle_name").first.content
    lastname = doc.find("#{each_author_node.path}/lastname").first.content
    fullname = doc.find("#{each_author_node.path}/fullname").first.content
    email = doc.find("#{each_author_node.path}/email").first.content
    new_author.middle_name = middle_name
    new_author.lastname = lastname
    new_author.fullname = fullname
    new_author.email = email
    new_author.sites = [site]
    if new_author.save
    
    if !doc.find("#{each_author_node.path}/author_profile").blank?
      author_profile = AuthorProfile.new
      doc.find("#{each_author_node.path}/author_profile").each do | each_profile_node |
        author_profile.author_id = new_author.id
        author_profile.professional_title = doc.find("#{each_profile_node.path}/professional_title").first.content; author_profile.title = doc.find("#{each_profile_node.path}/title").first.content; author_profile.company_name =  doc.find("#{each_profile_node.path}/company_name").first.content; author_profile.company_website_url = doc.find("#{each_profile_node.path}/company_website_url").first.content; author_profile.meta_description = doc.find("#{each_profile_node.path}/meta_description").first.content; author_profile.meta_keywords = doc.find("#{each_profile_node.path}/meta_keywords").first.content; author_profile.meta_title = doc.find("#{each_profile_node.path}/meta_title").first.content; author_profile.twitter_url = doc.find("#{each_profile_node.path}/twitter_url").first.content; author_profile.twitter_user_name = doc.find("#{each_profile_node.path}/twitter_user_name").first.content; author_profile.description = doc.find("#{each_profile_node.path}/description").first.content; author_profile.linkedin_url = doc.find("#{each_profile_node.path}/linkedin_url").first.content; author_profile.biography = doc.find("#{each_profile_node.path}/biography").first.content; author_profile.facebook_url = doc.find("#{each_profile_node.path}/facebook_url").first.content; author_profile.youtube_url = doc.find("#{each_profile_node.path}/youtube_url").first.content; author_profile.blog_url = doc.find("#{each_profile_node.path}/blog_url").first.content; author_profile.recommendation = doc.find("#{each_profile_node.path}/recommendation").first.content; author_profile.company_linkedin_url = doc.find("#{each_profile_node.path}/company_linkedin_url").first.content; author_profile.google_plus = doc.find("#{each_profile_node.path}/google_plus").first.content
        author_profile.save
      end
     end 
    end
      else
        logger.info("Author Already Exists!")
      end
    else
      logger.info("Email dose not exist in XML file")
    end
  end
  end
  
  
  
  
  
  ConfigurationValue.inspect
  ConfigurationValue.inspect
  def self.create_for_configuration_value(doc,xml_group,group) 
    if !(value = doc.find(xml_group.path+'/configuration_value').first).blank?
      doc.find(xml_group.path+'/configuration_value').each do |xml_value|
        if !(key = doc.find(xml_value.path+'/key').first.content).blank?
          value =  doc.find(xml_value.path+'/value').first.content
          conf_value = ConfigurationValue.find(:first, :conditions => ["configuration_group_id =? and key =?",group.id,key])
          if conf_value.blank?
            ConfigurationValue.create(:configuration_group_id => group.id, :key => key,:value => value)
          end
        end
      end
    end    
  end
  
  
  
  
  Category.inspect          
  def self.create_for_category(doc,xml_category,site,who,parent_id,seq_val,logger)
    parent_name = doc.find(xml_category.path+'/name').first.content
    parent_alias_name =  doc.find(xml_category.path+'/alias_name').first.content
    parent_full_name = doc.find(xml_category.path+'/full_name').first.content
    parent_full_alias_name = doc.find(xml_category.path+'/full_alias_name').first.content
    logger.info("#{who}--------------------------------------->#{parent_name}")
    if !(Category.find(:first, :conditions => ["parent_id =? and name =? and full_name =? and full_alias_name =? and alias_name =?", parent_id, parent_name, parent_full_name, parent_full_alias_name,parent_alias_name])).blank?
      parent_category = Category.find(:first, :conditions => ["parent_id =? and name =? and full_name =? and full_alias_name =? and alias_name =?", parent_id, parent_name, parent_full_name, parent_full_alias_name,parent_alias_name])
      parent_category.data_proxy_ids = parent_category.data_proxy_ids + [site.data_proxy_id] if !parent_category.data_proxy_ids.include?(site.data_proxy_id)
      if !doc.find(xml_category.path+'/category').blank?
        return parent_category.id,xml_category
      else
        return parent_id,xml_category
      end    
    else
      parent_category = Category.create(:parent_id=> parent_id,:name=> parent_name,:full_name => parent_full_name,:full_alias_name =>parent_full_alias_name ,:alias_name=> parent_alias_name,:sequence_number => seq_val )
      parent_category.data_proxy_ids = parent_category.data_proxy_ids + [site.data_proxy_id] if !parent_category.data_proxy_ids.include?(site.data_proxy_id)
      if !doc.find(xml_category.path+'/category').blank?
        return parent_category.id,xml_category
      else
        return parent_id,xml_category
      end
    end
  end
  
  
  Container.inspect
  Component.inspect
  ContainerComponent.inspect
  ComponentProperty.inspect
 ContainerPage.inspect
  def self.create_for_container(doc,site,logger)
  
    if !(doc.find('/site/containers/container')).blank?
      doc.find('/site/containers/container').each do | xml_container_node |
        container_name = doc.find("#{xml_container_node.path}/name").first.content
        @container = Container.find(:first, :conditions=>['name =? and presentation_proxy_id =?',container_name ,site.presentation_proxy_id])
       
     
        if !@container.blank?
          logger.info("Already there for container_type-->#{container_name} on Container table")
        else
          container_position = doc.find("#{xml_container_node.path}/position").first.content
          container_template = doc.find("#{xml_container_node.path}/template").first.content
          container_type = doc.find("#{xml_container_node.path}/container_type").first.content
          
          @container =  Container.create(:name => container_name ,:container_type=> container_type ,:position=> container_position ,:template_id=> container_template ,:site_id=> site.id)
          logger.info("New container name updated to Container[ #{@container.id} ] table")
          if !doc.find("#{xml_container_node.path}/page").first.blank?
                        doc.find("#{xml_container_node.path}/page").each do | xml_page |
                          @page = create_for_page(doc,site,xml_page,logger)
                          ContainerPage.create(:page_id => @page.id,:container_id => @container.id) if @page
                        end
          end      
                             
          if !doc.find("#{xml_container_node.path}/compoents").first.blank?
            doc.find("#{xml_container_node.path}/compoents/compoent").each_with_index do | xml_components,position |
              component_name = doc.find("#{xml_container_node.path}/name").first.content.to_s
              @component = Component.find(:first, :conditions=>['presentation_proxy_id =? and name =?',site.presentation_proxy_id,component_name])
              if !@component.blank?
                logger.info("already there on component---->#{@component.id} tables")
              else
              
                component_name = doc.find("#{xml_components.path}/name").first.content.to_s
                component_url = doc.find("#{xml_components.path}/url").first.content.to_s
                component_number_of_items = doc.find("#{xml_components.path}/number_of_items").first.content.to_s
                component_number_of_prominent = doc.find("#{xml_components.path}/number_of_prominent").first.content.to_s
                component_cache_duration = doc.find("#{xml_components.path}/cache_duration").first.content.to_s
                component_status = doc.find("#{xml_components.path}/status").first.content.to_s
                component_parent_id =doc.find("#{xml_components.path}/parent_id").first.content.to_s
                @component = site.components.create(:name=> component_name ,:url => component_url ,:number_of_items => component_number_of_items ,:number_of_prominent => component_number_of_prominent ,:cache_duration => component_cache_duration ,:status => component_status ,:parent_id => component_parent_id)
                if !doc.find("#{xml_components.path}/datalist").first.blank?
                  doc.find("#{xml_components.path}/datalist").each do | data_list_node |
                    @data_list = create_for_datalist(doc,site,data_list_node,logger)
                    @data_list.component_ids = @data_list.component_ids + [@component.id]
                  end 
                end
                @container_component = ContainerComponent.find(:first,:conditions=>['component_id =? and component_container_id =? ',"#{@component.id}","#{@container.id}"])
                ContainerComponent.create(:component_id => @component.id, :component_container_id=> @container.id,:container_id => @container.id ,:position => position) unless @container_component
                logger.info("Create for ContainerComponent ")
                if !doc.find("#{xml_components.path}/ComponentProperties/component_property").first.blank?
                  doc.find("#{xml_components.path}/ComponentProperties/component_property").each do | xml_component_property |
                    component_property_component = doc.find("#{xml_component_property.path}/component").first.content.to_s
                    component_property_name = doc.find("#{xml_component_property.path}/name").first.content.to_s
                    component_property_value = doc.find("#{xml_component_property.path}/value").first.content.to_s
                    base_component  = site.components.find_by_name("#{component_name}")
                    if !base_component.id.blank?
                      @aa.destroy  if @aa = base_component.component_properties.find_by_name("#{component_property_name}")
                      logger.info("Deleted for old component_propertie  ----->#{base_component.id}")
                      @component_property = ComponentProperty.create(:name=> component_property_name ,:value=> component_property_value, :component_id=> base_component.id)
                      logger.info("Created for new Component property---#{@component_property.id}  relation to the components id #{base_component.id}")
                    else
                      logger.info("Blank component")
                    end
                  end
                end
              end
            end
          end
        end                
      end
    end
  end    
  
  
  DataList.inspect                                       
  def self.create_for_datalist(doc,site,data_list_node,logger)
    if !(name =  doc.find("#{data_list_node.path}/name").first.content).blank? && !(entity = doc.find("#{data_list_node.path}/entity").first.content).blank? &&  !(data_list_type = doc.find("#{data_list_node.path}/data_list_type").first.content).blank?
      display_name = doc.find("#{data_list_node.path}/display_name").first.content rescue nil
    data_string = doc.find("#{data_list_node.path}/data_string").first.content
      sort = doc.find("#{data_list_node.path}/sort").first.content
      paginate = doc.find("#{data_list_node.path}/paginate").first.content rescue nil
    automated_data_string = doc.find("#{data_list_node.path}/automated_data_string").first.content
      ranklist = doc.find("#{data_list_node.path}/ranklist").first.content rescue nil
    @data_list =  site.data_lists.find(:first, :conditions =>["name =? and presentation_proxy_id =? and entity =? and data_list_type =?", name,site.presentation_proxy_id,entity,data_list_type])     
      if @data_list.blank?
        @data_list =  DataList.create(:name => name,:presentation_proxy_id => site.presentation_proxy_id ,:entity => entity,:data_list_type => data_list_type,:display_name => display_name, :data_string => data_string, :sort => sort, :paginate => paginate, :automated_data_string => automated_data_string, :ranklist => ranklist)
        if !doc.find("#{data_list_node.path}/asset_group").first.blank?
          doc.find("#{data_list_node.path}/asset_group").each do | asset_group_node |
            asset_group = create_for_asset_group(doc,site,asset_group_node,logger)
            @data_list.update_attributes(:asset_group_id => asset_group.id) if asset_group
            # Updated for Asset group Id in Page       
          end
          return @data_list
        else
          return @data_list   
        end
      else
        if !doc.find("#{data_list_node.path}/asset_group").first.blank?
          doc.find("#{data_list_node.path}/asset_group").each do |asset_group_node|
            asset_group = create_for_asset_group(doc,site,asset_group_node,logger)
            @data_list.update_attributes(:asset_group_id => asset_group.id) if asset_group     
            # Updated for Asset group Id in Page       
          end
          return @data_list
        else
          return @data_list
        end
      end
    end
  end
  
  
  Menu.inspect
  def self.create_for_menu(doc,xml_menu_node,site,who,seq_val,logger)
    name = doc.find("#{xml_menu_node.path}/name").first.content
    puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#{name}"
    if !( alias_name = doc.find("#{xml_menu_node.path}/alias_name").first.content).blank? # alias name not blank
    else
      alias_name = name.gsub(/(\S)/){|ss| ss.downcase}  # alias name blank?
    end
    entity_type = doc.find("#{xml_menu_node.path}/entity_type").first.content
    logger.info("#{who}--------------------------------------->#{parent_name}")
    if !(parent_name = doc.find("#{xml_menu_node.path}/parent_name").first.content).blank?
      @parent_name = site.menus.find_by_name(parent_name)
      parent_id = @parent_name.id
    else
      parent_id = 0
    end
    if doc.find("#{xml_menu_node.path}/category_name").first.content.blank?
      category_id = nil
    else
      category_name = doc.find("#{xml_menu_node.path}/category_name").first.content
      category_id = site.categories.find_by_alias_name(category_name).id 
      puts "Categort id ==> #{category_id}"
    end
    if !(parent_menu = Menu.find(:first, :conditions => ["parent_id =? and presentation_proxy_id = ? and name =? and entity_type = ?", parent_id, site.presentation_proxy_id,name, entity_type])).blank?
      if !(xml_page = doc.find("#{xml_menu_node.path}/page").first).blank? # PAGE
        @page = create_for_page(doc,site,xml_page,logger)
        @page.update_attributes(:menu_id => parent_menu.id)
      end
      return xml_menu_node
    else
      parent_menu = Menu.create(:parent_id=> parent_id, :presentation_proxy_id => site.presentation_proxy_id,:name=> name,:alias_name => alias_name,:entity_type => entity_type,:sequence_number => seq_val,:category_id => category_id)
      if !(xml_page = doc.find("#{xml_menu_node.path}/page").first).blank? # PAGE
        @page = create_for_page(doc,site,xml_page,logger)
        @page.update_attributes(:menu_id => parent_menu.id)
      end
      return xml_menu_node
    end
  end
  
  Page.inspect
  def self.create_for_page(doc,site,xml_page,logger)
    if !(type =  doc.find("#{xml_page.path}/type").first.content).blank? && !(page_name = doc.find("#{xml_page.path}/page_name").first.content).blank?
      url =  doc.find("#{xml_page.path}/url").first.content 
      template =  doc.find("#{xml_page.path}/template").first.content
      layout =  doc.find("#{xml_page.path}/layout").first.content
      layout_required =  doc.find("#{xml_page.path}/layout_required").first.content 
      active =  doc.find("#{xml_page.path}/active").first.content
      cache = doc.find("#{xml_page.path}/cache").first.content
      logger.info("  #{page_name}")
      
      @page =  site.pages.find(:first, :conditions =>["page_name =? and presentation_proxy_id =? and type =?", page_name,site.presentation_proxy_id,type])     
      if @page.blank?
        @page =  Page.create(:page_name => page_name,:presentation_proxy_id => site.presentation_proxy_id ,:type => type,:url =>  url,:template => template,:layout => layout, :layout_required => layout_required ,:active =>active,:cache => cache)
        @page.save if @page.type = "#{type}"
        #@new_page.update_attributes(:menu_id => parent_menu.id) if !parent_menu.blank?
        if !doc.find("#{xml_page.path}/asset_group").first.blank?
          doc.find("#{xml_page.path}/asset_group").each do | asset_group_node | 
            asset_group = create_for_asset_group(doc,site,asset_group_node,logger)
            @page.update_attributes(:asset_group_id => asset_group.id) if asset_group #.save     
            # Updated for Asset group Id in Page 
          end
          return @page 
        else
          return @page 
        end
      else
        # @new_page.update_attributes(:menu_id => parent_menu.id) if !parent_menu.blank?
        if !doc.find("#{xml_page.path}/asset_group").first.blank?
          doc.find("#{xml_page.path}/asset_group").each do | asset_group_node |
            asset_group = create_for_asset_group(doc,site,asset_group_node,logger)
            @page.update_attributes(:asset_group_id => asset_group.id) if asset_group #.save     
            # Updated for Asset group Id in Page      
            #%%%%%%
          end
          return @page
        else
          return @page
        end
      end
    end
  end
  
  
end