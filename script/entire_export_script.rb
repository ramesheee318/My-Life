require "application_helper"
require "rubygems"
require "ruby-debug"
require "builder"
class EntireExportScript
  
  def self.generate_xml(site,params,dir_name)
    
    Dir.chdir((FileUtils.mkdir_p "#{Rails.root}/public/DataExport/#{site.short_name}/#{Date.today.to_s}/#{dir_name}").first)
    puts "--------------------Begin------------------------"
    file_path = "#{Rails.root}/public/DataExport/#{site.short_name}/#{Date.today.to_s}/#{dir_name}"
    process_xml(site,params,file_path,dir_name)
  end
  
  def self.process_xml(site,params,file_path,dir_name)
    logger = Logger.new("#{Rails.root}/log/#{site.short_name}_#{dir_name}.log")
    
    if  params[:action] == "entire_exports"
      File.open("#{file_path}/#{site.short_name}_#{params[:action]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
      
        xml.site do
          xml.site("short_name" => "#{site.short_name}")
          xml.language("id" => "en")
          
          if !site.sources.blank?
            xml.Sources do
              n = 0
              site.sources.all.flatten.each do |each_source|
                n = n +1
                xml.source("count" => "#{n}") do
                  xml.name "#{each_source.name}"
                  logger.info("Source name ---> #{each_source.name}")
                  xml.alais_name "#{each_source.alais_name}"
                end
              end
            end
          end
          
          
          if !site.sections.blank?
            xml.Sections do
              n = 0
              site.sections.all.each do |each_section|
                n = n + 1
                xml.section("count" => "#{n}") do
                  xml.name each_section.name
                  logger.info("Section name ---> #{each_section.name}")
                  xml.alais_name each_section.alias_name
                  xml.entity_type each_section.entity_type
                end
              end
            end
          end 
          
          if !site.configuration_groups.blank?
            xml.Properties do
              n = 0
              site.configuration_groups.all.each do |each_property|
                n = n + 1
                xml.configuration_group("count" => "#{n}") do
                  logger.info("Property name ---> #{each_property.group_name}")
                  xml.group_name "#{each_property.group_name}"
                  if !(@values = each_property.configuration_values).blank?
                    v = 0
                    @values.each do |each_value|
                      if !each_value.key.blank? && !each_value.value.blank?
                        v = v +1
                        xml.configuration_value("count" => "#{v}") do
                          xml.key "#{each_value.key}"
                          xml.value "#{each_value.value}"
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          
          if !site.categories.blank?
            xml.categories do
              @parent_content =[]
              @parent_content.push site.categories.collect{|aa|  aa.name if aa.parent_id.blank?}.compact
              @parent_content.push site.categories.collect{|aa| aa.name if aa.parent_id == 0}.compact
              p  = 0
              @parent_content.flatten.uniq.compact.each do |each_category|
                p = p + 1
                xml.category("Parent-count" => "#{p}") do
                  category = site.categories.find_by_name(each_category)
                  who = "Parent:"
                  MigrationMethods.export_for_category(xml,category,who,logger)
                  if !category.children.blank?
                    c1 = 0
                    category.children.each do |each_sub_category|
                      c1 = c1 + 1
                      xml.category("child1-count" => "#{c1}") do
                        who = "Child 1:"
                        MigrationMethods.export_for_category(xml,each_sub_category,who,logger)
                        if !each_sub_category.children.blank?
                          c2 = 0
                          each_sub_category.children.each do |each_sub_category|
                            c2 = c2 + 1
                            xml.category("child2-count" => "#{c2}") do
                              who = "Child 2:"
                              MigrationMethods.export_for_category(xml,each_sub_category,who,logger)
                              if !each_sub_category.children.blank?
                                c3 = 0
                                each_sub_category.children.each do |each_sub_category|
                                  c3 = c3 + 1
                                  xml.category("child3-count" => "#{c3}") do
                                    who = "Child 3:"
                                    MigrationMethods.export_for_category(xml,each_sub_category,who,logger)
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
              end
            end
          end 
          
          
          if !site.menus.blank?
            xml.Menus do
              @parent_content =[]
              @parent_content.push site.menus.collect{|aa|  aa.name if aa.parent_id.blank?}.compact
              @parent_content.push site.menus.collect{|aa| aa.name if aa.parent_id == 0}.compact
              p = 0
              @parent_content.flatten.uniq.compact.each do |each_menu|
                p = p + 1
                xml.menu("parent-count" => "#{p}") do
                  menu = site.menus.find_by_name(each_menu)
                  who = "Parent :"
                  MigrationMethods.export_for_menu(xml,menu,who,logger)
                  if !(page = menu.page).blank?
                    xml.page do
                      MigrationMethods.export_for_pages(xml,page,logger)
                      if not (assetgroup = page.asset_group).blank?
                        MigrationMethods.export_for_asset_groups(xml,assetgroup,logger)
                      end
                    end
                  end 
                  if !menu.children.blank?
                    c1 = 0
                    menu.children.each do |each_sub_menu|
                      c1 = c1 + 1
                      xml.menu("child1-count" => "#{c1}") do 
                        who = "Child 1:"
                        MigrationMethods.export_for_menu(xml,each_sub_menu,who,logger)
                        if !(page = each_sub_menu.page).blank?
                          MigrationMethods.export_for_pages(xml,page,logger)
                          xml.page do
                            if not (assetgroup = page.asset_group).blank?
                              MigrationMethods.export_for_asset_groups(xml,assetgroup,logger)
                            end
                          end
                        end 
                        if !each_sub_menu.children.blank?
                          c2 = 0
                          each_sub_menu.children.each do |each_sub_menu|
                            c2 = c2 + 1
                            xml.menu("child2-count" => "#{c2}") do 
                              who = "Child2 :"
                              MigrationMethods.export_for_menu(xml,each_sub_menu,who,logger)                    
                              if !(page = each_sub_menu.page).blank?
                                xml.page do
                                  MigrationMethods.export_for_pages(xml,page,logger)
                                  if not (assetgroup = page.asset_group).blank?
                                    MigrationMethods.export_for_asset_groups(xml,assetgroup,logger)
                                  end
                                end
                              end 
                              if !each_sub_menu.children.blank?
                                c3 = 0
                                each_sub_menu.children.each do |each_sub_menu|
                                  c3 = c3 + 1
                                  xml.menu("child3-count" => "#{c3}") do
                                    who = "Child 3:" 
                                    MigrationMethods.export_for_menu(xml,each_sub_menu,who,logger)                    
                                    if !(page = each_sub_menu.page).blank?
                                      xml.page do
                                        MigrationMethods.export_for_pages(xml,page,logger)
                                        if not (assetgroup = page.asset_group).blank?
                                          MigrationMethods.export_for_asset_groups(xml,assetgroup,logger)
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
                    end
                  end
                end
              end  
            end
          end
          
          
          
          if !site.authors.blank?
            xml.Authors do
              MigrationMethods.introduction(xml,site)
              para_cont = ["author_ids"]
              retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
              @authors = site.authors.find(params[:export_data][:author_ids]) if false == retrun
              @authors = site.authors.all if true == retrun
              n = 0
              @authors.each do |each_author|
                n = n + 1
                MigrationMethods.export_for_author(xml,site,each_author,n,file_path,logger)
              end
            end
          end
          
          if ! site.featured_sets.blank?
            xml.rank_lists do
              MigrationMethods.export_for_ranklits(xml,site,logger) 
            end
          end 
          
          if !(site.containers.find(:all)).blank?
            @containers = site.containers.find(:all)
            xml.containers do
              c = 0
              @containers.each do |container_node|
                c = c + 1
                xml.container("count" => "#{c}") do 
                  logger.info("container type -----> #{container_node.name}") if xml.name "#{container_node.name}"
                  xml.position "#{container_node.position}"
                  xml.template "#{container_node.template_id}"
                  xml.container_type "#{container_node.container_type}"
                  if !(page = container_node.pages).blank?
                    xml.page do
                      MigrationMethods.export_for_pages(xml,page.first,logger)
                      if !page.first.asset_group.blank?
                        MigrationMethods.export_for_asset_groups(xml,page.first.asset_group,logger) #belongs_to
                      end
                    end  
                  end 
                  xml.compoents do 
                    if  !container_node.components.empty?
                      p = 0
                      for comp_node in container_node.components
                        p = p + 1
                        xml.compoent("count" => "#{p}") do 
                          logger.info("component ----> #{comp_node.name}") if xml.name "#{comp_node.name}"
                          xml.url "#{comp_node.url}"
                          xml.number_of_items "#{comp_node.number_of_items}"
                          xml.number_of_prominent "#{comp_node.number_of_prominent}"
                          xml.cache_duration "#{comp_node.cache_duration}"
                          xml.status "#{comp_node.status}"
                          xml.entry_value "#{comp_node.entry_value}"
                          if !(id = comp_node.fragment_id).blank?
                            @art = site.articles.find(id) rescue nil
                            if @art != nil
                              xml.fragment_id "#{@art.title.strip}" # Article title
                            end
                          end
                          MigrationMethods.find_for_proxy_name(xml,comp_node)
                          xml.parent_id "#{comp_node.parent_id}"
                          if !comp_node.featured_sets.blank?
                            xml.rank_lists do
                              MigrationMethods.export_for_ranklits(xml,comp_node,logger) 
                            end
                          end   
                          if !comp_node.data_lists.blank?
                            for data_count in comp_node.data_lists
                              xml.datalist("total" => "#{[data_count].count + 0}") do
                                MigrationMethods.export_for_data_lits(xml,data_count,logger)
                                if !data_count.asset_group.blank?
                                  MigrationMethods.export_for_asset_groups(xml,data_count.asset_group,logger) #belongs_to
                                end
                              end
                            end
                          end
                          if !comp_node.component_properties.empty?
                            xml.ComponentProperties do
                              n = 0
                              for component_propertie in comp_node.component_properties
                                n = n + 1
                                xml.component_property("count" => "#{n}") do
                                  xml.component "#{component_propertie.component_id}"
                                  logger.info("ComponentProperty ------> #{component_propertie.name}") if xml.name "#{component_propertie.name}"
                                  xml.value "#{component_propertie.value}"
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
            end
          end
        end
      }
    end
    
    #  completed_xml(site,params,file_path)
  end
  #  def self.completed_xml(site,params,file_path)
  #    Dir.chdir("#{Rails.root}/public/DataExport/")
  #    `zip -r #{file_path.split('/').last}.zip #{file_path.split('/').last}`
  #  end 
end