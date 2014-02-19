require "application_helper"
require "rubygems"
require "ruby-debug"
require "builder"
class SeperateExportScript
  
  def self.generate_xml(site,params,dir_name)
    
    Dir.chdir((FileUtils.mkdir_p "#{Rails.root}/public/DataExport/#{site.short_name}/#{Date.today.to_s}/#{dir_name}").first)
    puts "--------------------Begin------------------------"
    file_path = "#{Rails.root}/public/DataExport/#{site.short_name}/#{Date.today.to_s}/#{dir_name}"
    process_xml(site,params,file_path,dir_name)
  end
  
  def self.process_xml(site,params,file_path,dir_name)
    
    logger = Logger.new("#{Rails.root}/log/#{site.short_name}_#{dir_name}.log")
    logger.info("*******************begin***********************************")
    
    if  params[:sources] == "sources"
      File.open("#{file_path}/#{site.short_name}_#{params[:sources]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.Sources do
          MigrationMethods.introduction(xml,site)
          para_cont = ["source_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @sources = site.sources.find(params[:export_data][:source_ids]) if false == retrun
          @sources = site.sources.all if true == retrun 
          n = 0
          @sources.flatten.each do |each_source|
            n = n +1
            xml.source("count" => "#{n}") do
              xml.name "#{each_source.name}"
              logger.info("Source name ---> #{each_source.name}")
              xml.alais_name "#{each_source.alais_name}"
            end
          end
        end
      }
    end
    
    
    if params[:sections] == "sections"
      File.open("#{file_path}/#{site.short_name}_#{params[:sections]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.Sections do
          MigrationMethods.introduction(xml,site)
          para_cont = ["section_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @sections = site.sections.find(params[:export_data][:section_ids]) if false == retrun
          @sections = site.sections.all if true == retrun
          n = 0
          @sections.each do |each_section|
            n = n + 1
            xml.section("count" => "#{n}") do
              xml.name each_section.name
              logger.info("Section name ---> #{each_section.name}")
              xml.alais_name each_section.alias_name
              xml.entity_type each_section.entity_type
            end
          end
        end
      }
    end
    
    
    if params[:properties] == "properties"
      File.open("#{file_path}/#{site.short_name}_#{params[:properties]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.Properties do
          MigrationMethods.introduction(xml,site)
          para_cont = ["site_property_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @properties = site.configuration_groups.find(params[:export_data][:property_ids]) if false == retrun
          @properties = site.configuration_groups.all if true == retrun
          n = 0
          @properties.each do |each_property|
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
      }
    end
    
    
    if params[:pages] == "pages"
      File.open("#{file_path}/#{site.short_name}_#{params[:pages]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.Pages do
          MigrationMethods.introduction(xml,site)
          para_cont = ["site_page_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @pages = site.pages.find(params[:export_data][:page_ids]) if false == retrun
          @pages = site.pages.all if true == retrun
          p = 0
          for page in @pages
            p = p + 1
            xml.page("count" => "#{p}") do
              MigrationMethods.export_for_pages(xml,page,logger)
              if !page.asset_group.blank?
                MigrationMethods.export_for_asset_groups(xml,page.asset_group,logger) #belongs_to
              end
            end
          end  
        end
      }
    end
    
    if params[:data_lists] == "data_lists"
      File.open("#{file_path}/#{site.short_name}_#{params[:data_lists]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.DataLits do
          MigrationMethods.introduction(xml,site)
          para_cont = ["data_list_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @data_lists = site.data_lists.find(params[:export_data][:data_lists_ids]) if false == retrun
          @data_lists = site.data_lists.all if true == retrun
          n = 0
          for data_list in @data_lists
            n = n + 1
            xml.datalist("count" => "#{n}") do
              MigrationMethods.export_for_data_lits(xml,data_list,logger)
              if !data_list.asset_group.blank?
                MigrationMethods.export_for_asset_groups(xml,data_list.asset_group,logger) #belongs_to
              end
            end
          end          
        end
      }
    end
    
    
    
    
    if params[:categories] == "categories"
      File.open("#{file_path}/#{site.short_name}_#{params[:categories]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.categories do
          MigrationMethods.introduction(xml,site)
          para_cont = ["category_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @parent_content =[]
          if false == retrun
            @parent_content.push site.categories.find(params[:export_data][:category_ids]).collect{|aa|  aa.name if aa.parent_id.blank?}.compact
            @parent_content.push site.categories.find(params[:export_data][:category_ids]).collect{|aa| aa.name if aa.parent_id == 0}.compact
          elsif true == retrun
            @parent_content.push site.categories.collect{|aa|  aa.name if aa.parent_id.blank?}.compact
            @parent_content.push site.categories.collect{|aa| aa.name if aa.parent_id == 0}.compact
          end
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
      }
    end
    
    
    
    if params[:menus] == "menus"
      File.open("#{file_path}/#{site.short_name}_#{params[:menus]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.Menus do
          MigrationMethods.introduction(xml,site)
          para_cont = ["menu_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @parent_content =[]
          if false == retrun
            @parent_content.push site.menus.find(params[:export_data][:menu_ids]).collect{|aa|  aa.name if aa.parent_id.blank?}.compact
            @parent_content.push site.menus.find(params[:export_data][:menu_ids]).collect{|aa|  aa.name if aa.parent_id == 0}.compact
          elsif true == retrun
            @parent_content.push site.menus.collect{|aa|  aa.name if aa.parent_id.blank?}.compact
            @parent_content.push site.menus.collect{|aa| aa.name if aa.parent_id == 0}.compact
          end
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
      }
    end 
    
    
    if  params[:authors] == "authors"
      File.open("#{file_path}/#{site.short_name}_#{params[:authors]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.site do
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
      }
    end
    
    if params[:ranklists] == "ranklists"
      
      File.open("#{file_path}/#{site.short_name}_#{params[:ranklists]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.rank_lists do
          MigrationMethods.introduction(xml,site)
          para_cont = ["featured_set_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          if false == retrun
            @feature_sets = site.featured_sets.find(params[:export_data][:featured_set_ids]) 
            for featured_set in @feature_sets
              
              logger.info("Ranklist -----------> #{featured_set.name}") 
              xml.rank_list("name" => "#{featured_set.name}") do
                if !(assetgroup = featured_set.asset_group).blank?
                  
                  MigrationMethods.export_for_asset_groups(xml,assetgroup,logger)
                end
              end
            end
          elsif true == retrun 
            
            MigrationMethods.export_for_ranklits(xml,site,logger) 
          end  
        end
      }
    end  
    
    
    if params[:containers] == "containers"
      File.open("#{file_path}/#{site.short_name}_#{params[:containers]}.xml", 'w+') {|file|
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct!
        xml.site do
          MigrationMethods.introduction(xml,site)
          para_cont = ["container_ids"]
          retrun = MigrationMethods.find_for_params_data_ids(para_cont,params)
          @containers = site.containers.find(params[:export_data][:container_ids]) if false == retrun
          @containers = site.containers.find(:all) if true == retrun
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
      }
    end
    
  end
  
  
  
end
