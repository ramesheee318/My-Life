require 'xml/libxml'
require 'find'
require 'ruby-debug'
require 'open-uri'
require 'net/http'
require 'uri'
include Rails.application.routes.url_helpers


class FullStoryMigrationFromRss
  def self.rss_url
    begining("http://www.exchange4media.com/cms/CMS_UploadFile/latestnewswithfullstory.xml")
  end

 def self.begining(url)
    options = {:site_short_name => "inside_outside",
               :draft_mode => true,
               :imageset_path => "#{Rails.root}/HttpImage",
                :section_name => "Full Story",
                :category_id => 397,
                :author_id => 1023}
    process_log = Logger.new("#{Rails.root}/log/rss_process_result.log")
    FileUtils.rm_r Dir.glob("#{Rails.root}/RssDownload/*") if  Dir.exists?("#{Rails.root}/RssDownload/")
    rss_path = download_rss_file(url)
    
    if rss_path != nil
      process_log.info("Rss file path #{Rails.root} <===> #{rss_path}")
      rss_doc_reader(rss_path,options,process_log)
    else
      process_log.info("return is nill #{Rails.root}")
    end
  end
  
puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
  def self.rss_doc_reader(rss_path,options,process_log)
    doc = parse_xml(rss_path,process_log) # XML::Document.file("#{rss_path}")
    
    begin
     doc.find('/rss/channel/item').each do | each_item |
    
      process_log.info("********************************Begining****#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}******************************************")
      old_id =  doc.find("#{each_item.path}/guid").first.content.split('story.aspx?News_id=').last
#      @xml_site_id = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
Ambient.init
 @xml_site_id = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
Ambient.current_site = @xml_site_id
      find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article","#{old_id}",@xml_site_id.id])
       if find_id != nil
         puts "article already exists  ext id #{find_id.ext_id} :: int id #{find_id.int_id}"
        process_log.info("article find inside the rss migrated data for ext id #{find_id.ext_id} :: int id #{find_id.int_id}")
       else
       # rss_feed_image_chcek(doc,each_item,options,process_log,old_id) # Only image feed data migrtaion method
         content_field(doc,each_item,options,process_log,old_id) # all data migrtaion method
       end
      puts "*******************************END*******************************************"
    end
      rescue => e
        error_log =  Logger.new("#{Rails.root}/log/errors.log")
        puts "#{e.backtrace}"
        error_log.info("error message in xml parsing for file---->#{e.to_s}")  
        error_log.info("error in xml parsing for file---->#{rss_path.split('/').last}-->#{e.backtrace}")  
      end 
  end
 
  def self.parse_xml(rss_path,process_log)
    begin
      doc = XML::Document.file("#{rss_path}")
      return doc
    rescue
      process_log.info("the file having some problem -->#{rss_path.split('/').last}")
      return nil
    end
  end



def self.content_field(doc,each_item,options,process_log,old_id)
  
   puts "ss"
    article = Article.new()
    # Title
    debugger
    title = doc.find("#{each_item.path}/title").first.content rescue ""
    article.title = title.strip if title 
    process_log.info("Title:--> #{title}")
   puts "Title:--> #{title}"

    # Language
   language = Language.where(:name => 'English', :alias_name => 'en').first
    article.language_id =language.id if language
    debugger
    
     # Site
    site = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
    Time.zone = "Eastern Time (US & Canada)"
    article.sites = [site]
   puts "---> 1"
debugger
    # Source
    if !(source = site.sources.first).blank?
      source.data_proxy_ids = source.data_proxy_ids + [site.data_proxy_id] unless source.data_proxy_ids.include?(site.data_proxy_id)
    end
    article.source_id = source.id if !source.blank?
puts "---> 2"

    #Section
  section = site.sections.find_by_name(options[:section_name])
  article.section_id = section.id
puts "---> 3"
    
    #Category
    article.category_ids = Array(options[:category_id]) 
    
    #Date  
         puts " -----8"
        publish_date  = doc.find("#{each_item.path}/pubDate")
        article.publish_date = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.display_date = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.created_at = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.updated_at = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
         
         
     if !doc.find("#{each_item.path}/author").first.blank?
      author_string = doc.find("#{each_item.path}/author").first.content.to_s
      article.author_alias = author_string if author_string !=""
    end    
         
      puts "Author"
      article.author_ids = Array(options[:author_id]) 
       # if !doc.find("#{each_item.path}/idgnsrss:creator").blank?
       #  doc.find("#{each_item.path}/idgnsrss:creator").each do |node|
       #  end
       #end 
        
           # Body
            contents_new = []
            if !doc.find("#{each_item.path}/description").blank?
            doc.find("#{each_item.path}/description").each do | each_page |
           debugger
            contents_new <<  each_page.content
            end
            
        if !contents_new.blank?
         new_con = contents_new.join("<p><!-- pagebreak --></p>") #.gsub(/&lt;/,"<").gsub(/&gt;/,">")
         article.content = new_con
         content_with_new_image_path,image_ids = replace_image(new_con,old_id,site.id,process_log,options)
            article.content = content_with_new_image_path 
            article.image_id = image_ids.uniq if image_ids
         else
         process_log.info("Content Blank! in xml for file path #{title}")#
         puts "Content Blank! in xml for file path #{title}"
         article.content = "Content Blank ......!"
         end
         else
         process_log.info("Content Blank! in xml for file path #{title}")
         puts "Content Blank! in xml for file path #{title}"
         article.content = "Content Blank ......!"
       end
       
       
       
       puts "---> Title Image"
           debugger
            if !doc.find("#{each_item.path}/storyimages").blank?
              title_image = []
              doc.find("#{each_item.path}/storyimages").each do | each_image |
                debugger
                each_image.content =~ /((http|Http|https|Https):\/\/[a-z0-9_.-i\/].*(.jpg|.jpeg|.png|.gif|.JPG|.JPEG|.PNG|.GIF))/i
                if $1
                title_image << $1
                end
              end
             
              debugger
             if !(imageset_id = title_image[0]).blank?
              puts "imageset find with id------------->#{imageset_id}"
              migrated_image_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image","#{imageset_id}",site.id])
              if !migrated_image_id        
                file_full_path = image_fatched_from_http(imageset_id,options)
                   if file_full_path != nil
                  file_new = File.new("#{file_full_path}")
                  @flag ="read"
                  image_name = file_full_path.split("/").last
                  if image_name=~/\.([^\.]+)$/
                    image = Image.image_migration(file_new,Array(image_name),alt="",@flag,extra_info="",caption="",title="",site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
                  else
                    mimetype = `file -ib "#{file_full_path}"`.gsub(/\n/,"")
                    full_file_name = "#{image_name}.#{mimetype.split('/').last}"
                    puts "file full path after mime type --------------------------------------->convertion ----------------->#{full_file_name}"
                    image=Image.image_migration(file_new,Array(full_file_name),alt="",@flag,extra_info="",caption="",title="",site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
                  end
                  if image
                    puts "image saved with id inside the imageset or gallery---------------------->#{image.id}"
                             process_log.info("image saved with id inside the imageset or gallery---------------------->#{image.id}")
                    XmlMigratedData.create(:model_type => "Image",:ext_id =>imageset_id,:int_id => image.id,:publication_id =>site.id)
                    #return image
                  else
                    process_log.info("Validation errors images #{image.errors.full_messages.join(", ")}") if image
                    process_log.info("error in image saved imageset --> #{title}")
                    return nil
                  end
                else

                  puts "file not found ---->"
                  process_log.info("file not found --> #{title}")
                  #return nil
                end
              else

                image= Image.find(migrated_image_id.int_id)
            process_log.info("------old image found id image set ------>#{image.id}")
                puts "------old image found id image set ------>#{image.id}" if image
              end
              debugger
              article.image = ImageProperty.new(:image_id=>image.id,:alt_tag=>image.alt_tag) if image
            end
             else
               puts "Title image is blank? #{title}"
             end 

     
       if options[:draft_mode]
          article.active =true
          article.is_draft =false  
        else
          article.active =false
          article.is_draft =true
        end
      
        article.format = "html"
      debugger
        if article.save(:validate => false)
           puts "article saved with id -->#{article.id}"
          process_log.info("article saved with id -->#{article.id}")
          XmlMigratedData.create(:model_type => "Article",:ext_id => "#{old_id}",:int_id => article.id,:publication_id => site.id,:article_last_modify_date =>"",:old_url_part=>"",:previous_id=>"")
process_log.info("Xml Data Migration :ext_id => #{old_id},:int_id => #{article.id}")
         else
            process_log.info("Article Not Saved Poperlly:#{old_id}")
         end 
end
                 

  def self.download_rss_file(url)
    rss_log = Logger.new("#{Rails.root}/log/rss_download_result.log")
    orginal_rss = url.split('/').last
    puts "D-O-W-N-L-O-A-D"
    if url
      Dir.chdir(FileUtils.mkdir_p("#{Rails.root}/RssDownload").first) if !File.directory?("#{Rails.root}/RssDownload")
      Dir.chdir("#{Rails.root}/RssDownload")
      
      if !File.exists?("#{Rails.root}/RssDownload/#{orginal_rss}")
        system(`wget "#{url}"`)
      else
        puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
      end
      rss_path = ("#{Rails.root}/RssDownload/#{orginal_rss}")
      if File.exists?("#{rss_path}")
        rss_log.info("Rss downloaded #{orginal_rss}")
      return rss_path
      else
        rss_log.info("Rss not downloaded #{orginal_rss}")
        return nil
      end
    end
  end


def self.image_fatched_from_http(imgsrc,options)
  debugger
      data_path = options[:imageset_path]
  log_img = Logger.new("#{Rails.root}/log/image_find_#{Time.now.to_date}.log")
      log_img_err = Logger.new("#{Rails.root}/log/image_does_not_find_#{Time.now.to_date}.log")
  if imgsrc =~ /((http|Http|https|Https):\/\/[a-z0-9_.-i\/].*(.jpg|.jpeg|.png|.gif|.JPG|.JPEG|.PNG|.GIF))/i
   image_full_path = "#{data_path}/" + imgsrc.split('/').last
    Dir.chdir("#{Rails.root}")
    if imgsrc
   image_name=URI.encode(imgsrc.split("/").last)
   url = URI.parse(URI.encode(imgsrc))
   http = Net::HTTP.new(url.host, url.port)
   fetch_file=Net::HTTP.get_response(url)

      if fetch_file.class== Net::HTTPNotFound
        puts "image not found #{url}"
        log_img_err("image not found #{url}")
        return nil
      else
        img_alt = image_name
        (FileUtils.mkdir_p "#{Rails.root}/HttpImage").first
        File.open("#{Rails.root}/HttpImage/#{image_name}", "wb") { |f| f.write(fetch_file.body) }
         log_img.info("Image  exists in HttpImage  #{image_name}")
         puts "Created New Image**************************"
        image_full_path="#{Rails.root}/HttpImage/#{image_name}"
        return image_full_path
      end
    end
  return nil
  end
 end
 
 
 
 
 
 
 
 
def self.replace_image(content,xml_article_id,site_id,logger,options)

  image_ids = []
debugger
  content.gsub!(/(<img[^>]*[^>]*>)/i) do |img_tag|
debugger
    puts "inline image found ----------------------->#{img_tag}"
  image = save_image(img_tag,xml_article_id,site_id,logger,options)
 if image
     image.update_attributes(:default_version_id => image.image_details.first.id,:thumbnail_version_id => image.image_details.last.id) if image.default_version_id==nil and image.thumbnail_version_id==nil
    end
    if @image_flag
      if image
        debugger
        image_ids << image.id
        img_tag.sub(/src=['|"][^'|"]*['|"]/i,"src='#{image.default_image.image_path}'")
      else
        img_tag
      end
    else
      img_tag
    end
  end
  debugger
  return content,image_ids
end




def self.save_image(image,xml_article_id,site_id,logger,options)
  @image_flag = true
  
  begin
    image =~ /<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
    img_src= $2.split('?').first
    extra_info = "#{$1} #{$3}"
  debugger
    image_full_path = image_fatched_from_http(img_src,options)
  
    if image_full_path
      puts "before saving xml migrated data"
      find_img_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",img_src,site_id])
     
      if find_img_id !=nil
        puts "old_id for images #{find_img_id.int_id}"
        return Image.find(find_img_id.int_id)
      else
    #    image=~/<img[^>]*alt=['|"]([^"]*)['|"][^>]*>/i
    image=~/<img[^>]*alt=[\\|'|"]([^"]*)['|"][^>]*>/i
        if $1
          img_alt= $1 #.gsub("_","").gsub("-","")
        else
          img_alt=""
        end
        image_name=img_src.split("/").last
      
  image_full_path = "#{image_full_path}".split('?').first
        if File.exist?("#{image_full_path}")
         image_create= create_image_after_find(image_full_path,image_name,img_alt,extra_info,site_id,img_src,options)
         return image_create
        else
          puts "not found file "
          logger.info("internal image not found file==>#{image}==> for xml article id ==> #{xml_article_id}")
          @image_flag=false
          return @image_flag
        end
      end
    
 
     elsif options[:external_img_src]
     for external_image in options[:external_img_src]
     if img_src.match(external_image)
       puts "find '#{external_image}'"
       fetch_file=Net::HTTP.get_response(URI.parse(img_src))
     if fetch_file.class== Net::HTTPNotFound
         puts "image not found #{img_src}"
         logger.error("Not save image for path==>#{image}==> for xml article id ==> #{xml_article_id}")
         @image_flag=false
         return @image_flag
     else
         puts "image found"
        image=~/<img[^>]*alt=['|"]([^"]*)['|"][^>]*>/i
 #        image=~/<img[^>]*alt=[\\|'|"]([^"]*)['|"][^>]*>/i
 
       if $1
         img_alt= $1.gsub("_","").gsub("-","")
       else
         img_alt=""
       end
       image_name=img_src.split("/").last.split('?').first
         find_img_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",img_src,site_id])
       
       if find_img_id !=nil
        puts "old_id for images #{find_img_id.int_id}"
        return Image.find(find_img_id.int_id)
       else
         File.open("/export/#{image_name}", "wb") { |f| f.write(fetch_file.body) }
         image_full_path="/export/#{image_name}"
         image_create= create_image_after_find(image_full_path,image_name,img_alt,extra_info,site_id,img_src,options)
         FileUtils.rm(image_full_path)
         return image_create
       end          
     end
   else
    logger.info("internal image not found file==>#{img_src}==> for xml article id ==> #{xml_article_id}")
    puts "Not matched image path and external_img_src ===#{img_src}"
    return nil
   end     
  end    
  end
  rescue => e
    logger.error("Not save internal image for path==>#{img_src}==> for xml article id ==> #{xml_article_id}")
    logger.error("Error in intenaml image creation ======> #{e}")
    puts "errorin image fetching"
    @image_flag=false
  end
end



def self.create_image_after_find(image_full_path,image_name,img_alt,extra_info,site_id,img_src,options)
  file_new = File.new("#{image_full_path}")
  @flag ="read"
  
    if image_name=~/\.([^\.]+)$/
      image=Image.image_migration(file_new,Array(image_name),img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
    else
      mimetype = `file -ib "#{image_full_path}"`.gsub(/\n/,"")
      full_file_name = "#{image_name}.#{mimetype.split('/').last}"
      image=Image.image_migration(file_new,Array(full_file_name),img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title           
    end
  puts "internal image create with id --------> #{image.id}" if image
  XmlMigratedData.create(:model_type => "Image",:ext_id => img_src,:int_id => image.id,:publication_id => site_id) if image
  
  return image
end


end

