require 'xml/libxml'
require 'find'
require 'ruby-debug'
require 'open-uri'
require 'net/http'
require 'uri'
class WordPressMigration
  
 def self.process_start
   
   options = {:site_short_name => "inside_outside",
               :site_suggest => 'NW',   
               :xml_dir_path => "/home/rameshs/Downloads/demo/",
               :draft_mode => true,
               :imageset_path => "#{Rails.root}/HttpImage",
               :section_name => "News",
               :source_id => 39
               }
puts "--->1"    
process_log = Logger.new("#{Rails.root}/log/clickzasia_Into_clickz_migration.log")
   FileUtils.rm_r Dir.glob("#{Rails.root}/RssDownload/*") if  File.directory?("#{Rails.root}/RssDownload/")
   doc_reader(options,process_log)
 end

  def self.doc_reader(options,process_log)
    puts "--->2"
     n=0
    Find.find(options[:xml_dir_path]) do |file_path|
      unless File.directory?(file_path)
        n=n+1
        puts n
        GC.start if n%50==0
        
        process_xml(file_path,options,process_log)
      end
    end
  end

  def self.process_xml(file_path,options,process_log)
    doc = parse_xml(file_path,options,process_log)
    begin
      migration(doc,options,process_log) if doc
    rescue => e
      puts "#{e.backtrace}"
      process_log.info("error message in xml parsing for file---->#{e.to_s}")
      process_log.info("error in xml parsing for file---->#{file_path}-->#{e.backtrace}")
    end
  end

  def self.parse_xml(file_path,options,process_log)
    begin
      doc = XML::Document.file("#{file_path}")
      return doc
    rescue
      process_log.info("the file having some utf8 charset prblem -->#{file_path}")
      return nil
    end
  end

 def self.migration(doc,options,process_log)
   
   
   puts "-->4"
    begin
      doc.find('/rss/channel/item').each do | each_item |
debugger        
      process_log.info("********************************Begining****#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}******************************************")
      guid_title =  doc.find("#{each_item.path}/wp:post_id").first.content #.gsub("http://www.clickz.asia/","")
      Ambient.init
      @xml_site_id = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
      Ambient.current_site = @xml_site_id
      find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article","#{guid_title}_#{site_suggest}",@xml_site_id.id])
        if find_id != nil
## art =Article.find(find_id.int_id) 
## art.destroy
## find_id.delete    
        process_log.info("article find inside the xml for ext id #{find_id.ext_id} :: int id #{find_id.int_id}")
        else
        rss_feed_image_chcek(doc,each_item,options,process_log,guid_title) # Only image feed data migrtaion method
        # content_field(doc,each_item,options,process_log,guid_title) # all data migrtaion method
        end
        puts "*******************************END*******************************************"
      end
    rescue => e
        error_log =  process_log.new("#{Rails.root}/log/errors.log")
        puts "#{e.backtrace}"
        error_log.info("error message in xml parsing for file---->#{e.to_s}")
        error_log.info("error in xml parsing for file---->#{guid_title}-->#{e.backtrace}")
    end
  end

    
  def self.rss_feed_image_chcek(doc,each_item,options,process_log,guid_title)
debugger
     url_link = doc.find("#{each_item.path}/link").first.content
      if url_link.blank? #----->
       debuggger
       process_log("link url is blank! :) Please have a look")
       puts "Link Blank  !"
       else
       content_field(doc,each_item,options,process_log,guid_title)
       end
  end

  def self.content_field(doc,each_item,options,process_log,guid_title)
  debugger
    puts "new article :) -------->"
    article = Article.new()
     array_title = []
    #Title
    puts "Title"
    title = doc.find("#{each_item.path}/title").first.content.strip rescue ""
    if title != nil
puts "Title :*:*:*:*************   #{title}"
    article.title = title.strip if title
    process_log.info("Title:--> #{article.title}")
    else
      process_log.info("Title Blank -->#{guid_title}")
         array_title.push "Title blank"
    end  
    
    #Language
     puts "Language"
     language =  Language.find_by_alias_name("en")
     article.language_id =language.id if language
     process_log.info("Language:--> #{article.language_id}")
     
     
    #Summary
     puts "Summary"
     summary = doc.find("#{each_item.path}/excerpt:encoded").first
     if !summary.first.blank?
     article.description = summary.first.content.to_s
     process_log.info("Summary:--> #{article.description}")
     else
     process_log.info("Summary: Blank!")
     end
    #Site
     puts "Site"
     site = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
     Time.zone = "New Delhi"
     article.sites = [site]
     process_log.info("Site: #{article.sites.first.short_name}")
    
    #Source
     puts "Source"
     article.source_id = options[:source_id] if !options[:source_id].blank?
     process_log.info("Source: #{article.source_id}")
    
    #Section
     puts "Section"
     section = site.sections.find_by_name(options[:section_name])
     article.section_id = section.id
     process_log.info("Section: #{article.section_id}")
    
    #Old URL
    puts "Old URL"
    old_url=[]
    doc.find("#{each_item.path}/link").each do |xml_urls|
      if xml_urls.content.to_s !=""
        xml_url = OldUrl.new()
        xml_url.old_url = xml_urls.content.gsub(/.*[a-z0-9.\-]+[.][a-z]{2,4}/,"")to_s # [a-z0-9.\-]+[.][a-z]{2,4} this  looks like domain name followed by a slash this pattern very very usefull(rameshkumar)
        old_url << xml_url
      end
    end

    #Content
     puts "Content"
     array_content =[]
       if !doc.find("#{each_item.path}/content:encoded").first.content.blank?
puts"content "
new_art = doc.find("#{each_item.path}/content:encoded").first
                     new_atr=new_art.to_s 
                new_hom= new_atr.gsub("<content:encoded><![CDATA[","<p>") 
             new_con=  new_hom.gsub("]]><\/content:encoded>","</p>")     
content_with_new_image_path,image_ids = replace_image(new_con,guid_title,site.id,process_log,options)
article.content = content_with_new_image_path 
            article.image_ids = image_ids if image_ids
        else
          process_log.info("Content Blank! in xml for file path #{title}")
          puts "Content Blank! in xml for file path #{title}"
          array_content.push "Content Blank ......!"
       end
             

           puts "---> Title Image"
       #    title_image = []
          if !doc.find("#{each_item.path}/wp:attachment_url").blank?
 title_image = []
            ## doc.find("#{each_item.path}/wp:attachment_url").each do | each_meta | #$@#
       each_image  = doc.find("#{each_item.path}/wp:attachment_url").first.content rescue "BLANK"
             title_image <<  each_image.content 
           if each_image != ""
            ext = each_image.split('/')[-1].split('.')[-1] =~ /(jpg|jpeg|png|gif|JPG|JEG|PNG|GIF)/ 
              if ext != nil
               title_image <<  each_image
              end
           end
           ## end #$@#
             if title_image[0] != nil  and !(imageset_id = title_image[0]).blank?
              puts "imageset find with id------------->#{imageset_id}"
              migrated_image_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image","#{imageset_id.split('/').last}",site.id])
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
                    XmlMigratedData.create(:model_type => "Image",:ext_id =>imageset_id.split('/').last,:int_id => image.id,:publication_id =>site.id)
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
#
               image= Image.find(migrated_image_id.int_id)
               image_detail = image.image_details.find_by_logical_name "original"
               image_detail.create_other_images(image) if image
                puts "------old image found id image set ------>#{image.id}" if image
              end
              article.image = ImageProperty.new(:image_id=>image.id,:alt_tag=>image.alt_tag) if image
            end
##           end #$#  
             else
               puts "Title image is blank? #{title}"
             end 

       puts " -----8"
        publish_date  = doc.find("#{each_item.path}/wp:post_date")
        article.publish_date = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.display_date = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.created_at = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.updated_at = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
       
# 
puts"----------------------------->category"


      cat_id= []
if doc.find("#{each_item.path}/category")
     doc.find("#{each_item.path}/category").each do | node |
    if node['domain']
          if node['domain'] == "category" 
            cat_name = node.content
               process_log.info("category_found ---->#{cat_name}")
               cat = cat_name.split("/").join(" >> ")  if cat_name
               new_cat = site.categories.find_by_name(cat_mapped) if cat
              new_cat = site.categories.find_by_full_name(cat) if cat
               cat_id << new_cat.id if new_cat
                unless new_cat
                process_log.info("New category created from xmls --->#{cat_name}")
                end
end
end
end       
      article.category_ids = cat_id.uniq unless cat_id.blank?
   end
    
    if doc.find("#{each_item.path}/category")
       xml_tag_ids=[]
      doc.find("#{each_item.path}/category").each do |node|
         if node['domain']
            if node['domain'] == "post_tag"
             
             find_tag = site.tags.find_by_name(node.content.to_s)
             xml_tag_ids << find_tag.id if find_tag
             unless find_tag
             find_tag=Tag.create(:name=>node.content.to_s,:entity_type=>"Article")
             find_tag.save(false)
             site.tags << find_tag
             xml_tag_ids << find_tag.id if find_tag
             guid_title =  doc.find("#{each_item.path}/wp:post_id").first.content
             XmlMigratedData.create(:model_type => "Tag",:ext_id => "#{guid_title}_#{options[:site_suggest]}",:int_id => find_tag.id,:publication_id => site.id )
             end
            end
        end
      end
      article.tag_ids = xml_tag_ids unless xml_tag_ids.blank?
    end

  
   #<<<<<<<<<<<<######( ALTER TABLE authors ADD COLUMN author_login_xml text; )#######>>>>>>>>>>>>>>>#

  if doc.find("#{each_item.path}/dc:creator").first
    if doc.find("#{each_item.path}/dc:creator").first.content.to_s !=""
        author_alias = []
       doc.find("#{each_item.path}/dc:creator").each do |node|
        puts "author id found inside the xml------------------->#{node.content}"
#ebugger
puts"for guid_title"        
        auth =  site.authors.find_by_author_login_xml(node.content.strip)
        #auth =  site.authors.find_by_firstname(node.content.strip)
             if auth != nil
              author_alias << auth.id       
             else
       
              new_author =   Author.new()
              new_author.firstname = node.content.strip
              new_author.lastname = node.content.strip
              new_author.email = node.content.strip
              if new_author.save(false)
                 puts "auhtor created with id  -->#{new_author.id}"
                 site.author_ids =  site.author_ids + [new_author.id]
                 author_alias << new_author.id
                 process_log.info("Autho blank :) ==>  #{title}  Author => #{node.content.strip}  ID ==>#{new_author.id}")
              end
             end
       end
       
       article.author_ids = author_alias.uniq if author_alias
    end
    else
      process_log.info("Author Blank -->")
  end
       
         if options[:draft_mode]
          article.active =true
          article.is_draft =false  
        else
          article.active =false
          article.is_draft =true
        end
  #     
          guid_title =  doc.find("#{each_item.path}/wp:post_id").first.content 
       
           if  !array_content.blank? and  !array_title.blank? #$#
              process_log.info("Article Title Blank -->#{guid_title}") if !array_title.blank? 
              process_log.info("Article content  Blank -->#{guid_title}") if !array_content.blank?
           else 
 #     
        if article.save(:validate => false)
          puts "article saved with id -->#{article.id}"
          process_log.info("article saved with id -->#{article.id}")
         guid_title =  doc.find("#{each_item.path}/wp:post_id").first.content
          XmlMigratedData.create(:model_type => "Article",:ext_id => "#{guid_title}_#{site_suggest}",:int_id => article.id,:publication_id => site.id,:article_last_modify_date =>"",:old_url_part=>"",:previous_id=>"")
          process_log.info("Xml Data Migration :ext_id => #{guid_title}_#{asia} :int_id => #{article.id}")

          puts "Index"           
          ##Ambient.init
          ##Ambient.current_site = site
          ##process_log.info("Article index done") if article.index_to_search_engine
          ###puts "Article index done"
     process_log.info("********************************END******************************************")
  end
end
end

                         
   def self.replace_image(content,xml_article_id,site_id,process_log,options)
     puts ""
    image_ids = []
    
    #content.gsub!(/(<a href[^>]*[^>]*>)/i) do |img_tag|
    content.gsub!(/(<img[^>]*[^>]*>)/i) do |img_tag|
      puts "inline image found ----------------------->#{img_tag}"
      #img_tag  =~ /<a href=['|"](\/images+?.*.jpg)['|"]>/i
      #img_tag  =~ /<img[^>]*src=['|"](\/images\/[a-z0-9_.-i\/]+.jpg|.jpeg|.png|.gif|.JPG|.JPEG|.PNG|.GIF)['|"]\s\/>/i
      # 
      image = save_image(img_tag,xml_article_id,site_id,process_log,options)
      if image
        image.update_attributes(:default_version_id => image.image_details.first.id,:thumbnail_version_id => image.image_details.last.id) if image.default_version_id==nil and image.thumbnail_version_id==nil
      end
      if @image_flag
        if image
          image_ids << image.id
          #img_tag.sub(/(<img src=)(['|"][^'|"]*['|"])(.*[^>]*>)/i,"<p>#{$1}#{image.default_image.image_path}#{$3}</p>")
          # img_tag.sub(/(<img src=)(['|"][^'|"]*['|"])(.*[^>]*>)/i,"<p>#{$1}#{image.default_image.image_path}#{$3}</p>")
          img_tag.sub(/src=['|"][^'|"]*['|"]/i,"src=#{image.default_image.image_path}")
         #
         # img_tag.sub(/(<img class=['|"][^'|"]*['|"]*[^>]*>)/i,"<p>#{$1}</p>")
        #  img_tag.sub(/(src=['|"](\/images\/[a-z0-9_.-i\/]+.jpg|.jpeg|.png|.gif|.JPG|.JPEG|.PNG|.GIF)['|"])/i,"src='#{image.default_image.image_path}'")
        else
        img_tag
        end
      else
      img_tag
      end
    end
    return content,image_ids
  end

  def self.save_image(image,xml_article_id,site_id,process_log,options)
  @image_flag = true
  begin
    image=~/<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
    img_src= $2
    extra_info = "#{$1} #{$3}"
    image_full_path = image_fatched_from_http(img_src,options)
    #    puts image_full_path
    #    if img_src=~/.*(\/data\/.*)/
    #      #img_src=~/.*(\/data\/.*)/
    #      @image_path = $1
    if image_full_path
      find_img_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",img_src,site_id])
      if find_img_id !=nil
        puts "old_id for images #{find_img_id.int_id}"
        return Image.find(find_img_id.int_id)
      else
        
        image=~/<img[^>]*alt=['|"]([^"]*)['|"][^>]*>/i
        if $1
          img_alt= $1 
        else
          img_alt=""
        end
        
        image_name=img_src.split("/").last
        #if File.exist?("#{options[:imageset_binary_path]}#{@image_path}")
        #file_new = File.new("#{options[:imageset_binary_path]}#{@image_path}")
        if File.exist?("#{image_full_path}")
          file_new = File.new("#{image_full_path}")
          @flag ="read"
          #ext = image_name.last.chomp.split(".")[-1]
          #if ext=~/(_jpg|_jpeg|_png|_gif|_JPG|_JPEG|_PNG|_GIF)$/
          if image_name=~/\.([^\.]+)$/
            image=Image.image_migration(file_new,image_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
          else
            mimetype = `file -ib "#{image_full_path}"`.gsub(/\n/,"")
            full_file_name = "#{image_name}.#{mimetype.split('/').last}"
            image=Image.image_migration(file_new,full_file_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title            
          end
          puts "internal image create with id --------> #{image.id}" if image 
          XmlMigratedData.create(:model_type => "Image",:ext_id => img_src,:int_id => image.id,:publication_id => site_id) if image
          return image  
        else
          puts "not found file "
          process_log.info("internal image not found file==>#{image}==> for xml article id ==> #{xml_article_id}")
          @image_flag=false
          return @image_flag
        end
      end
    end
  rescue => e
    process_log.error("Not save internal image for path==>#{img_src}==> for xml article id ==> #{xml_article_id}")
    process_log.error("Error in intenaml image creation ======> #{e}")
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

        def self.find_image_path(imgsrc,options)
        begin
          log_img = process_log.new("#{Rails.root}/log/NOKOGIRIMG.log")
          if imgsrc 
            
             data_path = options[:imageset_binary_path]
            image_full_path = "#{data_path}#{imgsrc}"
             
            if File.exist?(image_full_path)
              puts "%%%%%%%%%%%%%%%%%"
              log_img.info("Image  exists in NOKOGIRIMG  #{image_full_path.split('/').last}")
              return image_full_path
            else 
              puts "Not Exists!"
              log_img_err.info("Image does not  exists in server  #{image_full_path.split('/').last}") 
              puts "niiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii"
              return nil
            end
          end
        rescue
        end
        puts "nil allllllllllllllllllllllllllllllllllllllllllllllll"
        return nil    
      end
      


def self.image_fatched_from_http(imgsrc,options)
  
      data_path = options[:imageset_path]
  log_img = process_log.new("#{Rails.root}/log/image_find_#{Time.now.to_date}.log")
      log_img_err = process_log.new("#{Rails.root}/log/image_does_not_find_#{Time.now.to_date}.log")
  if imgsrc =~ /((http|Http|https|Https):\/\/[a-z0-9_.-i\/].*(.jpg|.jpeg|.png|.gif|.JPG|.JPEG|.PNG|.GIF))/i
   image_full_path = "#{data_path}/" + imgsrc.split('/').last
    Dir.chdir("#{Rails.root}")
    if imgsrc
    
   image_name=URI.encode(imgsrc.split("/").last)
   url = URI.parse(URI.encode(imgsrc))
   http = Net::HTTP.new(url.host, url.port)
   fetch_file=Net::HTTP.get_response(url)
   
      if fetch_file.class == Net::HTTPNotFound
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


end
