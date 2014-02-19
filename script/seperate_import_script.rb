require "application_helper"
require 'libxml'
require 'find'
require 'ruby-debug'

class SeperateImportScript
  
  def self.create(site,params,dir_name)
    logger =Logger.new("#{Rails.root}/log/SeperateImportScript.log")
    logger.info("---------------Starting----- TIME: #{Time.now.strftime("%H:%M:%S")}------------------------")
    file_path = "#{Rails.root}/public/DataImport/#{site.short_name}/#{Date.today.to_s}/#{dir_name}"
    
   if File.exists?("#{file_path}")
    process_xml(site,params,file_path,logger)
    else
    logger.info("Missing for path #{file_path}")
    end
  end
  
    def self.process_xml(site,params,file_path,logger)
    
      if  params[:sources] == "sources"
      logger.info("sources:-")
        doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:sources]}.xml")
        site = Site.find_by_short_name(site.short_name)
        doc.find('/Sources/source').each do | xml_source_node |
          source_name = doc.find("#{xml_source_node.path}/name").first.content
          if !doc.find("#{xml_source_node.path}/alais_name").first.content.blank?
            source_alias_name = doc.find("#{xml_source_node.path}/alais_name").first.content    
          else
            source_alias_name = source_name.gsub(/(\S)/){|ss| ss.downcase} #Here automatically created for  alias name because no alias name in XML
          end
          source = Source.find(:first, :conditions => ['name =?  and alais_name = ?',source_name,source_alias_name])
          if !source.blank?
                  logger.info("This source #{source_name} already there in db")
             site_source = site.sources.find(:first, :conditions => ['name =?  and alais_name = ?',source_name,source_alias_name])
            if !site_source.blank?
             logger.info("This source  #{source_name} already there in site")
            else
           logger.info("Source #{source.name}  assined to the #{site.short_name}")  if site.source_ids = site.source_ids + [source.id]
            end
          else
          
            new_source = Source.create(:site_id => '#{site.data_proxy_id}',:name => source_name,:alais_name=> source_alias_name)
           logger.info("Created the new source -> #{new_source.name} ") if site.source_ids = site.source_ids + [new_source.id]
          end
        end
      end
      
      
     if params[:sections] == "sections"
       logger.info("Sections:-")
       doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:sections]}.xml")
       site = Site.find_by_short_name(site.short_name)
       doc.find('/Sections/section').each do | xml_section_node |
         section_name = doc.find("#{xml_section_node.path}/name").first.content
         entity_type = doc.find("#{xml_section_node.path}/entity_type").first.content
         if !doc.find("#{xml_section_node.path}/alais_name").first.content.blank?
           section_alias_name = doc.find("#{xml_section_node.path}/alais_name").first.content
         else
           section_alias_name = section_name.gsub(/(\S)/){|ss| ss.downcase} #Here automatically created for alias name because no alias name in XML
         end
         section = Section.find(:first, :conditions => ["name =? and entity_type =?",section_name,entity_type])
         if !section.blank?
           section_site = site.sections.find(:first, :conditions => ["name =? and entity_type =?",section_name,entity_type])
           if !section_site.blank?
             logger.info("This section #{section_name}  already there on site")
           else
             logger.info("site [#{site.id}] assigned to the sections[#{section.id}] ") if section.site_ids = section.site_ids + [site.data_proxy_id]
             end
         else
           new_section = Section.create(:name => section_name ,:alias_name => section_alias_name,:entity_type=> entity_type)
           logger.info("Created the new section > #{new_section.name} <")
           logger.info("site [#{site.id}] assigned to the sections[#{new_section.id}]")  if new_section.site_ids = new_section.site_ids + [site.data_proxy_id]
         end
       end
     end
    
 if params[:properties] == "properties"
   logger.info("Properties-")
   doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:properties]}.xml")
   site = Site.find_by_short_name(site.short_name)
   doc.find('/Properties/configuration_group').each do |xml_group|
     if !(name = doc.find(xml_group.path+'/group_name').first.content).blank?
       group = ConfigurationGroup.find(:first, :conditions => ["site_id = ? and group_name =?", site.id, name])
       if group.blank?
         group =  ConfigurationGroup.create(:site_id => "#{site.id}",:group_name => "#{name}")
         
         MigrationMethods.create_for_configuration_value(doc,xml_group,group) 
       else
         logger.info("Already exists this group==>#{group.id}")
         
         MigrationMethods.create_for_configuration_value(doc,xml_group,group) 
       end
     else
       logger.info("Gruop Name dose not  Exist in  XML file")
     end
   end 
 end           
     
     
        if  params[:pages] == "pages"
          logger.info("Pages:")
          doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:pages]}.xml")
          site = Site.find_by_short_name(site.short_name)
          doc.find('/Pages/page').each do |xml_page|
            MigrationMethods.create_for_page(doc,site,xml_page,logger)
          end
        end                    
        
        
        if params[:data_lists] == "data_lists"
          logger.info("DataList:")
          doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:data_lists]}.xml")
          site = Site.find_by_short_name(site.short_name)
          doc.find('/DataLits/datalist').each do | data_list_node |
            MigrationMethods.create_for_datalist(doc,site,data_list_node,logger)
          end
        end                    
             
                         
if params[:categories] == "categories"
  logger.info("Categories-")
  doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:categories]}.xml")
  site = Site.find_by_short_name(site.short_name)
  p = 0
  doc.find('/categories/category').each do |xml_category|
    p =  p + 1
    seq_val = "#{p}"
    who = "Parent"
    parent_id = 0
    parent_category,xml_category =  MigrationMethods.create_for_category(doc,xml_category,site,who,parent_id,seq_val,logger)
    
    if !doc.find(xml_category.path+'/category').first.blank?
      c1 = 0
      doc.find(xml_category.path+'/category').each do |xml_child_category|
        c1 = c1 + 1
        seq_val = "#{c1}"
        who = "Child 1"
        parent_id = parent_category
        parent_category,xml_category =  MigrationMethods.create_for_category(doc,xml_child_category,site,who,parent_id,seq_val,logger)
        if !doc.find(xml_category.path+'/category').first.blank?
          c2 = 0
          doc.find(xml_category.path+'/category').each do |xml_sub_child_category|
            c2 = c2 + 1
            seq_val = "#{c2}"
            who = "Child 2"
            parent_id = parent_category
            parent_category,xml_category =  MigrationMethods.create_for_category(doc,xml_sub_child_category,site,who,parent_id,seq_val,logger)
            if !doc.find(xml_category.path+'/category').first.blank?
              c3 = 0
              doc.find(xml_category.path+'/category').each do |xml_sub_child_category|
                c3 = c3 + 1
                seq_val = "#{c3}"
                who = "Child 3"
                parent_id = parent_category
                parent_category,xml_category =  MigrationMethods.create_for_category(doc,xml_sub_child_category,site,who,parent_id,seq_val,logger)
              end
            end
          end
        end
      end
    end
  end
end
            
      
     
    if  params[:menus] == "menus"
      logger.info("Menus:-")
      doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:menus]}.xml")
      site = Site.find_by_short_name(site.short_name)
      p = 0
      doc.find('/Menus/menu').each do | xml_menu_node |
        p =  p + 1
        seq_val = "#{p}"
        who = "Parent"
       xml_menu_node =  MigrationMethods.create_for_menu(doc,xml_menu_node,site,who,seq_val,logger)
        if !doc.find("#{xml_menu_node.path}/menu").first.blank?
          m1 = 0
          doc.find("#{xml_menu_node.path}/menu").each do | xml_menu1_node |
            m1 = m1 + 1
            seq_val = "#{m1}"
            who = "Child 1"
            xml_menu_node =  MigrationMethods.create_for_menu(doc,xml_menu1_node,site,who,seq_val,logger)
            if !doc.find("#{xml_menu_node.path}/menu").first.blank?
              m2 = 0
              doc.find("#{xml_menu_node.path}/menu").each do | xml_menu2_node |
                m2 = m2 + 1
                seq_val = "#{m2}"
                who = "Child 2"
                xml_menu_node =  MigrationMethods.create_for_menu(doc,xml_menu2_node,site,who,seq_val,logger)
                if !doc.find("#{xml_menu_node.path}/menu").first.blank?
                  m3 = 0
                  doc.find("#{xml_menu_node.path}/menu").each do | xml_menu3_node |
                    m3 = m3 + 1
                    seq_val = "#{m3}"
                    who = "Child 3"
                    xml_menu_node =  MigrationMethods.create_for_menu(doc,xml_menu3_node,site,who,seq_val,logger)
                  end
                end
              end
            end
          end
        end
      end
    end
                        
            
           
     if params[:authors] == "authors"
       doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:authors]}.xml")
       site = Site.find_by_short_name(site.short_name)
       MigrationMethods.create_for_author(doc,site,logger)
     end
            
     if  params[:ranklists] == "ranklists"
       doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:ranklists]}.xml")
       site = Site.find_by_short_name(site.short_name)
       doc.find('/rank_lists/rank_list').each do |node|
         feature_set  = FeaturedSet.find_by_name( node["name"]) || FeaturedSet.new(:name => "#{node['name']}") 
         if !doc.find("#{node.path}/asset_group").blank?
           doc.find("#{node.path}/asset_group").each do | asset_group_node |
             asset_group = MigrationMethods.create_for_asset_group(doc,site,asset_group_node,logger)
             feature_set.entity_type ="DataProxy"
             feature_set.entity_id = site.data_proxy.id
             feature_set.asset_group = asset_group
             logger.info("Created the new features set -->#{feature_set.name} in Site ") if feature_set.save
           end 
         else
           feature_set.entity_type ="DataProxy"
           feature_set.entity_id = site.data_proxy.id
           feature_set.asset_group = asset_group
           logger.info("Created the new features set -->#{feature_set.name} in Site ") if feature_set.save
         end
       end 
     end                   
            
         if  params[:containers] == "containers"
           doc = LibXML::XML::Document.file("#{file_path}/#{site.short_name}_#{params[:containers]}.xml")
           site = Site.find_by_short_name(site.short_name)
           MigrationMethods.create_for_container(doc,site,logger)
         end
       end 
 
    
 end
