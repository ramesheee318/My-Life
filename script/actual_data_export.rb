require "ruby-debug"
require "application_helper"
require "ruby-debug"
require "builder"
class ActualDataExport
  def self.generate_xml(site,params,dir_name)
    
    dir_path = ( FileUtils.mkdir_p "#{Rails.root}/public/DataExport/#{site.short_name}/#{Date.today.to_s}/#{dir_name}" ).first
    process_xml(site,params,dir_path)
  end
  
  def self.process_xml(site,params,dir_path)
    
    array_section = []
    array_section.push("#{params[:static_fragment]}") if  params[:static_fragment] == 'static_fragment' 
    array_section.push("#{params[:static_page]}") if params[:static_page] == 'static_page'
    array_section.push("publish_data") if !(params[:e_date1] && params[:e_date2]).blank?
    array_section.push("display_data") if !(params[:e_date3] && params[:e_date4]).blank?
    array_section.push("entire_exports") if  params[:action] == "entire_exports"
    array_section.push("export_entire_data") if params[:action] == "export_entire_data"
    array_section.push("daily_Published_data") if params[:action] == "daily_Published_data"
    array_section.each do |each_section|
      article_selection = {:static_page => ["static_page"], :static_fragment => ["static_fragment"], :publish_data => ["PublishData"], :display_data => ["DisplayData"], :entire_exports => ["StaticArticle"], :export_entire_data => ["EntireData"],:daily_Published_data => ["DailyData"]}
      datachose = {:static_page => "static-page",:static_fragment => "static-fragment"}
      article_selection[each_section.to_sym].each do |section|
        if params[:static_fragment] == section
          params_hase_ids = ["static_fragment_ids"]
          @return = find_for_params_data_ids(params_hase_ids,params)
          @articles = site.static_articles.collect{ |article| article if article.section_name ==  datachose[:"#{section}"] }.compact  if false == @return
          @articles = site.static_articles.find(params[:export_data][:static_fragment_ids]) if true == @return
        elsif params[:static_page] == section
          params_hase_ids = ["static_page_ids"]
          @return = find_for_params_data_ids(params_hase_ids,params)
          @articles = site.static_articles.collect{|article| article if article.section_name ==  datachose[:"#{section}"] }.compact if false == @return
          @articles = site.static_articles.find(params[:export_data][:static_page_ids])  if true == @return
        elsif "PublishData" == section 
          @articles = site.articles.published_date_range("#{params[:e_date1].gsub("/","-")} 00:00:00","#{params[:e_date2].gsub("/","-")} 23:59:59") 
        elsif "DisplayData" == section
          @articles = site.articles.display_date_range("#{params[:e_date3].gsub("/","-")} 00:00:00","#{params[:e_date4].gsub("/","-")} 23:59:59") 
        elsif "StaticArticle" == section
          @articles = site.static_articles.find(:all)
        elsif "EntireData" == section
          @articles = site.articles.find(:all)
        elsif "DailyData" == section # Daily published articles export
         @articles = site.articles.published_date_range("#{(Time.now - 1.days).strftime("%Y-%m-%d")} 00:00:00","#{(Time.now - 1.days).strftime("%Y-%m-%d")} 23:59:59")
        end
        
        if File.directory?("#{dir_path}/#{section}")
          `rm -rf #{dir_path}/#{section}` #Don't use this code in ur localhost for very danger
        end
        
        file_path = (FileUtils.mkdir_p "#{dir_path}/#{section}/XmlFolder").first
        logger = Logger.new("#{Rails.root}/log/#{site.short_name}_#{section}.log")
        logger.info("#{section} ---> #{@articles.count}")
        total = 0
        for article in @articles
        total = total + 1  
          article.inspect
          article_new =  article
          File.open("#{file_path}/#{article_new.id}.xml", 'w+') {|file|
            xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
            xml.instruct!
            xml.article do
              logger.info("************#{article_new.id} ---> begin**************") if xml.article("id" => "#{article_new.id}")
              xml.language("Language" => "en")
              xml.title "#{article_new.title}"
              xml.sub_title "#{article_new.sub_title}"
              xml.title_url "#{article_new.title_url}"
              xml.fragment_title_text "#{article_new.fragment_title_text}"
              if !article_new.format.blank?
              xml.format "#{article_new.format}"
              else
             xml.format "html"
              end
              xml.url_part  "#{article_new.url_part}" if !article_new.url_part.blank?
              xml.summary "#{article_new.description}"
              xml.author_name_string "#{article_new.author_alias}" if article_new.author_alias
              logger.info("Section ==> ")  if  xml.content_type("id" => "#{article_new.section.alias_name}","entity_type" => "#{article_new.section.entity_type}")
              xml.primary_medium "#{article_new.primary_medium}" if !article_new.primary_medium.blank?
              xml.source("alais" => "#{article_new.source.alais_name}") if !article_new.source.blank?
              if !article_new.article_old_urls.blank?
                xml.old_urls do      
                  for old_url in article_new.article_old_urls
                    xml.old_url "#{old_url}"
                  end
                end       
              end   
              #As below article Content 
              article_content = article_new.article_contents.last
              if !article_content.content.blank?
                content= article_content.replace_new_content_image(article_content.content)
                #        xml.content "#{content}"
                #As Content Image for internal image#
                
                begin
                content.scan(/(<img[^>]*[^>]*>)/i) do |img|
                  img.first=~/<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
                  img_src= $2
                  img_src.gsub("//","/") =~ /IMG+\/(\d+)/
                  image_id= $1
                  if !image_id.blank?
                    image_path_id = Image.find(image_id)
                    if image_path_id
                      new_directroy =(FileUtils.mkdir_p "#{file_path}"+image_path_id.generate_image_folder_path(image_path_id.id)).first
                      image_path_id.image_details.each do |image_detail|
                        orginal_image_path = "#{Rails.root}"+"/public"+"#{image_detail.image_path}"
                        img_file_name = (image_detail.image_path.split('/').last)
                        duplicate_image_path="#{new_directroy}/#{img_file_name}"
                        if File.exist?(orginal_image_path)
                          logger.info("**** content image is there -------------->#{img_file_name}")
                          FileUtils.cp_r orginal_image_path,duplicate_image_path
                        end
                      end
                    end
                  end
                end 
                rescue
                end
                
                #As content Digital-->pdf for internal  Digital
                pdf_find =( article_new.article_contents.collect{|aa| aa if aa.content =~/(asset_library_tag\s(\d+),([^]]+).pdf)/} - [nil]).last
                if !pdf_find.blank?
                  content = pdf_find.replace_content_asset(pdf_find.content)
                  xml.content "#{content}"
                  if content =~ (/(href=.*digital_assets\/(\d+)\/(\w+.pdf))/) || content =~ /href=("|')..\/\w+\/(\d+)\/(\w+.pdf)/
                    content.scan((/(href=.*digital_assets\/(\d+)\/(\w+.pdf))/) || content =~ /href=("|')..\/\w+\/(\d+)\/(\w+.pdf)/).flatten.collect do |digit|
                      digit.first =~ /\/(\d+)\//
                      digital_id = DigitalAsset.find("#{$1}")
                      orginal_digit_path = "#{Rails.root}"+"/public"+"#{digital_id.document_path}"
                      digital_id.document_path =~ /(([&\/a-z].*)(\/\d.+))/
                      FileUtils.mkdir_p "#{file_path}/#{$2}/#{digital_id.id}"
                      new_digitaldirectroy = "#{file_path}/#{$2}/#{digital_id.id}"
                      digital_file_name= digital_id.document_path.split('/').last
                      duplicate_digital_path ="#{new_digitaldirectroy}/#{digital_file_name}"
                      if File.exist?(orginal_digit_path)
                        FileUtils.cp_r orginal_digit_path,duplicate_digital_path
                        logger.info("- **** content PDF Is there -------->#{digital_id.document_path}")
                      else
                        logger.info("Not for pdf on public folder------------------>#{digital_id.document_path}")
                      end
                    end
                  else
                  end
                else
                  
                  xml.content "#{content}"
                end
              end
              
              xml.meta_tags do
                xml.meta_keywords "#{article_new.meta_keywords}" if !article_new.meta_keywords.blank?
                xml.meta_description "#{article_new.meta_description}" if !article_new.meta_description.blank?
              end
              
              #@@@ As for Category Parts @@@#
              if !article_new.categories.blank?
                xml.categories do
                  for category in article_new.categories
                    fetch_for_category(xml,category,logger)
                  end
                end
              end
              
              if !article_new.tags.blank?
                xml.tags do
                  article_new.tags.each do |each_tag|
                    fetch_for_tag(xml,each_tag,logger)         
                  end
                end
              end
              
              if !article_new.authors.blank?
                xml.authors do
                  for authors in article_new.authors
                    fetch_for_author(xml,authors,logger)
                  end
                end
              end
              
              if article_new.further_readings.blank?
                xml.further_readings do
                  for further in article_new.further_readings
                    xml.articles_id "#{further.id}"
                  end
                end
              end
              
              xml.dates do
                fetch_for_date(xml,article_new)
              end
              
              xml.issue_number "#{article_new.magazine_issue_id}"
              if article_new.magazine_issue
                xml.print_magazine do
                  xml.volume_issue "#{article_new.magazine_issue.short_name}"
                  xml.print_issue_date "#{article_new.magazine_issue.date_of_publication.xmlschema}" if !article_new.magazine_issue.blank?
                end
              end
              
              #As IMAGE SET for  external IMAGE#
              if !article_new.image.blank?
              image_path =  article_new.image.image_path rescue ""
                if !image_path.blank?
                xml.imagesets("#{article_new.image.image_path}", "caption" => "#{article_new.image.caption}")
                orginal_image_path = "#{Rails.root}"+"/public"+article_new.image.image_path
                image_path_id = Image.find(article_new.image.image_id)
                FileUtils.mkdir_p "#{file_path}"+image_path_id.generate_image_folder_path(image_path_id.id).gsub('//','/')
                new_directroy= "#{file_path}"+image_path_id.generate_image_folder_path(image_path_id.id).gsub('//','/')
                image_path_id.image_details.each do |image_detail|
                  img_file_name= image_detail.image_path.split('/').last
                  duplicate_image_path="#{new_directroy}/#{img_file_name}"
                  if File.exist?(orginal_image_path)
                    logger.info("Article image-------------------->#{article_new.image.image_path}")
                    FileUtils.cp_r orginal_image_path,duplicate_image_path
                    else
                    puts "Image does not exixts in public folder -->#{article_new.id}.xml"
                  end
                end
                else
                  "Image does not exists in public -->#{article_new.id}.xml"   
                end
              end
              
              #As Media Details for  external Media
              if !article_new.media_detail.blank?
                orginal_media_path = "#{Rails.root}"+"/public"+article_new.media_detail.video_path
                media_detail_id =    MediaDetail.find(article_new.media_detail.id)
                flv_filename = "#{media_detail_id.name}.flv"
                xml.media_path "#{article_new.media_detail.video_path.gsub(".mp4",".flv")}"
                media_folder =  article_new.media_detail.video_path.split('/')[1]
                FileUtils.mkdir_p "#{file_path}/#{media_folder}/#{article_new.media_detail.id}"
                new_directroy= "#{file_path}/#{media_folder}/#{article_new.media_detail.id}"
                duplicate_media_path="#{new_directroy}/#{flv_filename}"
                if File.exist?(orginal_media_path)
                  logger.info("- **** Article media -------------------> #{article_new.media_detail.video_path}")
                  FileUtils.cp_r orginal_media_path,duplicate_media_path
                else
                  logger.info("NOT for Article media path on publish-------------------> #{article_new.media_detail.video_path}")
                end
              end
              
              #As audio for  external audio         
              if !(@audio = article_new.audio).blank?
                audio_path = @audio.audio_path
                xml.audio_path "#{audio_path}"
                orginal_audio_path = "#{Rails.root}"+"/public"+"#{audio_path}"
                new_directroy = (FileUtils.mkdir_p "#{file_path}/#{audio_path.split('/')[1]}/#{article_new.audio.id}").first
                duplicate_audio_path = "#{new_directroy}/#{audio_path.split('/').last}"
                if File.exist?(orginal_audio_path)
                  logger.info("-Article audio -------------------> #{orginal_audio_path}")
                  FileUtils.cp_r orginal_audio_path,duplicate_audio_path
                else
                  logger.info("Not for Article audio path on publish---------------------->#{article_new.id}-")
                end
              end
              
              #As GALLERY SET for  external GALLERY#
              
              if !article_new.gallery.blank?
                xml.gallery do
                  if !(@image_sequence = article_new.gallery.image_sequence).blank?
                    xml.image_sequence("id" => "#{@image_sequence.id}")
                    xml.name "#{@image_sequence.name}"
                    xml.description "#{@image_sequence.description}"
                    if !(@image_properties = @image_sequence.image_properties).blank?
                      @image_properties.each do | gallery_imageset |
                        image_path = gallery_imageset.image_path rescue ""
                      
                          if !image_path.blank?
                         xml.image_property do  
                          xml.imageset_path("#{gallery_imageset.image_path}","image_id" => "#{gallery_imageset.image_id}", "width" => "#{gallery_imageset.width}", "height" => "#{gallery_imageset.height}", "position" => "#{gallery_imageset.sequence_number}", "description" => "#{gallery_imageset.description}", "caption" => "#{gallery_imageset.caption}", "alt_tag" => "#{gallery_imageset.alt_tag}", "titel" => "#{gallery_imageset.image.title}") 
                         
                          gallery_imageset.image_path.gsub("//","/") =~ /IMG+\/(\d+)/
                          image_id= $1
                          
                                                    if !image_id.blank?
                                                      image_path_id = Image.find(image_id) rescue ""
     if !image_path_id.blank?
       orginal_image_path = "#{Rails.root}"+"/public"+gallery_imageset.image_path
       FileUtils.mkdir_p "#{file_path}"+image_path_id.generate_image_folder_path(image_path_id.id)
       new_directroy= "#{file_path}"+image_path_id.generate_image_folder_path(image_path_id.id)
       img_file_name= gallery_imageset.image_path.split('/').last
       duplicate_image_path="#{new_directroy}/#{img_file_name}"
       if File.exist?(orginal_image_path)
         logger.info("- **** -Article image ----------------#{img_file_name}")
         FileUtils.cp_r orginal_image_path,duplicate_image_path
       else
         puts "Image  dose not exixts in public -->#{article_new.id}.xml "
       end
       else
       puts "Image Id dose not exists in Image Table =>ID: #{image_id}"
     end
                                                     end
                                            end
                          else
                          puts "Image path dose not exixts in table(image_property) -->#{article_new.id}.xml"
                          end                  
                      end
                    end
                  end
                end  
              end
              if !article_new.comments.blank?
                xml.comments do
                  n = 0
                  for comment in article_new.comments
                    n = n + 1
                    fetch_for_command(xml,comment,n,logger)
                  end
                end
              else
                logger.info("Not for Comments in article-->#{article_new.id}")
              end
            end
          }
        end
       
       return total,file_path if params[:action] == "daily_Published_data"
       
        Dir.chdir("#{dir_path}/#{section}/XmlFolder")
        Dir.entries("#{dir_path}/#{section}/XmlFolder").select {|entry| File.directory? File.join("#{dir_path}/#{section}/XmlFolder",entry) and !(entry =='.' || entry == '..') }.each do |dir|
          if File.directory?("#{dir_path}/#{section}/XmlFolder/#{dir}")
            `mv #{dir} ../`
          end
        end 
        
      end
    end
  end
  
  
  def self.fetch_for_author(xml,authors,logger)
    xml.author do
      xml.author_email "#{authors.email}"
      xml.author_firstname "#{authors.firstname}"
      xml.author_lastname "#{authors.lastname}"
      logger.info("Author  ------#{authors.firstname}-----------> #{authors.email}")
    end
  end
  
  
  def self.fetch_for_command(xml,comment,n,logger)
    xml.comment do
      logger.info("Comment --------------->#{comment.email}")
      xml.comment("id" => "#{comment.id}", "count" => "#{n}")
      xml.title "#{comment.title}"
      xml.posted_date "#{comment.created_at.xmlschema}"
      xml.message "#{comment.description}"
      xml.commenter_name "#{comment.user_name}"
      xml.commenter_email "#{comment.email}"
      xml.status "#{comment.status}"
    end
  end
  
  def self.fetch_for_category(xml,category,logger)
    xml.category("name" => "#{category.full_name}")
    xml.full_alias_name "#{category.full_alias_name}"
    logger.info("Category name -------------------->#{category.full_name}")
  end
  
  def self.fetch_for_date(xml,article_new)
    xml.display_date "#{article_new.display_date.xmlschema}" if !article_new.display_date.blank?
    xml.valid_from "#{article_new.publish_date.xmlschema}"  if !article_new.publish_date.blank?
    xml.created_date "#{article_new.created_at.xmlschema}" if !article_new.created_at.blank?
    xml.last_modified_date "#{article_new.updated_at.xmlschema}" if !article_new.updated_at.blank?
  end
  
  def self.find_for_params_data_ids(param_hase_ids,params)
    if !params[:export_data].blank?
      if !params[:export_data]["#{param_hase_ids[0].to_sym}"].blank?
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def self.fetch_for_tag(xml,each_tag,logger)         
    xml.tag("name" => "#{each_tag.name}" )
    logger.info("Tag name ------------------>#{each_tag.name}")
  end
end
