require "application_helper"
require 'libxml'
require 'find'
require 'calais'
require 'json'
require 'ruby-debug'

class SimpleArticleImport
  
  def self.from_xml(directories,options={})
    # directories="/home/rameshs/customer/Cybermedia/CMS/CMS_Admin/XML/"
    logger=Logger.new("#{RAILS_ROOT}/log/simple_article_migration_#{options[:file_name]}_#{Time.now.to_date}.log")
    logger_article_id =Logger.new("#{RAILS_ROOT}/log/simple_article_new_id_#{options[:file_name]}_#{Time.now.to_date}.log")
    n=0
    directories.each do |directory|
      Find.find(directory) do |file_path|
        unless File.directory?(file_path)
          n=n+1
          puts n
          GC.start if n%50==0
     	 puts "#{file_path}"
          process_xml(file_path,logger,options,logger_article_id)
          end
      end
    end
   end

  def self.process_xml(file_path,logger,options,logger_article_id)
  doc = LibXML::XML::Document.file("#{file_path}")
  check_and_process_xml_doc(doc,logger,file_path,options,logger_article_id)
  end

 def self.check_and_process_xml_doc(doc,logger,file_path,options,logger_article_id)
      site_short_name = {'DQWeek' => 'dq-week', 'DQChannels' => 'dq-channels' , 'DQEvent' => 'dq_event', 'DataQuest' => 'dataquest', 'CIOL' => 'ciol'}
      doc.find('channel').each do |node|
        title = doc.find(node.path+'/title').first.content
        if site_short_name[title] != nil
          @xml_site_id = Site.find(:first,:conditions=>['short_name=?',site_short_name[title]])
          doc.find(node.path+'/item').each do |each_field|
            # old_id = file_path.split('/').last.scan(/\d+.xml/).to_s.to_i
            #old_id = (doc.find(each_field.path+'/articlelink').first.content.split('/') - ["0","",".",".."])[-1]
          link  = doc.find(node.path+'/link').first.content.strip
        if !(art_link = doc.find(each_field.path+'/articlelink').first.content.gsub("#{link}","").split('/')).blank?
#debugger          
 
old_id = (art_link - ["0","",".",".."]).last.split(".").first
           if old_id.blank?
         old_id = file_path.split('/').last.scan(/\d+.xml/).to_s.to_i   
           end 
           else
#debugger
          old_id = file_path.split('/').last.scan(/\d+.xml/).to_s.to_i
         end
#debugger
          @art =  Article.find_by_title "#{doc.find(each_field.path+'/articletitle').first.content.strip}"
         ##  ref_id =  file_path.split('/').last.scan(/\d+.xml/).to_s.to_i rescue "ciol"
        if !old_id.blank?
          puts "ext_id --#{old_id}"
            logger.info("*******************************************************************************************************************")
             logger_article_id.info("*******************************************************************************************************************")
              puts "File name #{file_path}"
             logger.info("ext_id --#{old_id}")
            logger_article_id.info("ext_id --#{old_id}")
             find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article","#{old_id}",@xml_site_id.id])
          ##  if  find_id != nil
          ##   @art =  Article.find("#{find_id.int_id}") 
          ##    @org_art = @art.title
          ##   else
#debugger            
         ##   @org_art = ""
         ##     end
             
        ##    if  @art.title != doc.find(each_field.path+'/articletitle').first.content.strip  
#debugger
            if find_id == nil
              article = Article.new()
              article.title  = doc.find(each_field.path+'/articletitle').first.content.strip
              article.language =  Language.find_by_alias_name('en')
              author_alias = doc.find(node.path+'/authorname').first.content.strip
              article.author_alias = author_alias if author_alias !=""
           puts "------>2"
              article.sites = [@xml_site_id]
              article_description =   doc.find(each_field.path+'/articledescription').first.content.strip
              article.description = article_description if article_description !=""
              article_content = doc.find(each_field.path+'/ArticleContent').first.content
#           article_content = doc.find(each_field.path+'/articlecontent').first.content
              article.content = article_content if article_content !=""
               content_with_new_image_path,image_ids = replace_image(article_content,old_id,@xml_site_id.id,logger,options,file_path)
                #content_withnew_assets = replace_asset(content_with_new_image_path,old_id,@xml_site_id.id,options)
                #article.content_withnew_assets
                 
   # OpenCalais Used to create the tags from content
=begin 
   if options[:opencalais]
  
    @tags = tag_create(content_with_new_image_path)             
   
   if !@tags.blank?
   puts "Total tag count :#{@tags.count}"
    array_tag = []
    t = 0
    @tags.take(10).each do | each_tag |
    t = t + 1
    puts "OPen Calais Tag ******************:#{each_tag}"
    debugger
     if each_tag
       @tag = Tag.find_by_alias_name(each_tag)        
       @tag = Tag.create(:name=> each_tag.capitalize, :entity_type =>"Article", :alias_name=> each_tag, :type => "ManualTag", :suggested_by => "OC") if !@tag
       site_tag = @xml_site_id.tags.find_by_alias_name(each_tag)
       @tag.site_ids += [@xml_site_id.id] if !site_tag
       array_tag << @tag.id
     end
   end
   debugger
    array_tag.uniq.each_with_index do | tag_id, i |
     article.articles_tags << ArticlesTag.new( :tag_id => tag_id, :sequence_number => i, :suggested_by => "OC" )
   end
   else
   debugger
    puts "<*** Tag does not generated by opencalais ***>"  
   end
 end 
=end 
 article.content= content_with_new_image_path
 article.image_ids = image_ids.uniq
	       puts "--------> 4" 
              old_url=[]
               (doc.find(each_field.path+'/articlelink').first.content).gsub("#{doc.find(node.path+'/link').first.content}",'').each do |xml_urls|
                if xml_urls.to_s !=""
                  xml_url = OldUrl.new()
                  xml_url.old_url = xml_urls.to_s
                  old_url << xml_url
                end
              end
#debugger

#            article_meta = doc.find(each_field.path+'/metadescription').first.content.strip
           article_meta = doc.find(each_field.path+'/MetaKeywords').first.content.strip
            article.meta_keywords = article_meta if article_meta !=""
              article.section_id = (@xml_site_id.sections.find_by_name "News").id
              source = @xml_site_id.sources.first #_by_alais_name(site_short_name[doc.find(each_field.path+'/source').first.content]))
              article.source_id = source.id if source
              #   tag = (doc.find(each_field.path+'/articlelink').first.content.split('/') - ["0","",".",".."])[-1].to_i
              xml_tag_ids=[]
             # tag_name =  ((doc.find(each_field.path+'/articlelink').first.content.split('/') - ["0","",".",".."])[2]).gsub('-',' '){|name| name}.strip
                 if !(@tag_name = doc.find(each_field.path+'/articlelink').first.content.gsub("#{link}","").gsub("#{old_id}","").gsub(".asp","").split('/') - ["","content"]).blank?
       for tag_name in (@tag_name - [".","..","0"])         
   find_tag = @xml_site_id.tags.find(:first,:conditions=>['name =? and entity_type =?',tag_name,"Article"])
                           xml_tag_ids << find_tag.id if find_tag
                           unless find_tag
                             find_tag=Tag.find(:first,:conditions=>['name =? and entity_type =?',tag_name,"Article"])  || find_tag=Tag.create(:name=>tag_name,:entity_type=>"Article")
                             @xml_site_id.tags << find_tag
                             xml_tag_ids << find_tag.id if find_tag
                             XmlMigratedData.create(:model_type => "Tag",:ext_id => old_id,:int_id => find_tag.id,:publication_id => @xml_site_id.id )
                           end
                           logger.info("Tag --->  #{xml_tag_ids.first}") if !xml_tag_ids.blank?
#                           article.tag_ids = xml_tag_ids.uniq unless xml_tag_ids.blank?
                         end
                          article.tag_ids = xml_tag_ids.uniq unless xml_tag_ids.blank?
                   else
#debugger
                  logger.info("Tag Blank in XML")
                  end       
             
              #Category
=begin
      if !doc.find(each_field.path+'/sectionname').blank?
         cat_id = []
          doc.find(each_field.path+'/sectionname').each do | each_cate |
            if !(cat_name = each_cate.content).blank?
            cat = cat_name.split("/").join(" >> ")
            new_cat = Category.find_by_name(cat) if cat
               new_cat = Category.create(:parent_id=> 0,:name=> cat ,:alias_name=> cat.split(" >> ").join("-").downcase) if new_cat.blank?
            logger_article_id.info("Category Id => #{new_cat.id} :name => #{new_cat.name}")
            new_cat.data_proxy_ids = new_cat.data_proxy_ids + [@xml_site_id.data_proxy_id] if !new_cat.data_proxy_ids.include?(@xml_site_id.data_proxy_id)
            cat_id << new_cat.id if new_cat
            end
          end 
          article.category_ids = cat_id.uniq unless cat_id.blank?
        else
          puts "Category not exists!"
        end
=end

        if !doc.find(each_field.path+'/sectionname').blank?
         cat_id = []
         hash_map = { "Android" =>  "Hot Topics >> Android", "Cloud-and-Virtualization" => "Hot Topics >> Cloud", "Developer" => "News", "Enterprise" => "ENTERPRISE", "Mobility" => "Hot Topics >> Mobility", "Networking" => "Hot Topics >> Networking", "News" =>  "News","Security" => "Hot Topics >> Security", "Semicon" => "Hot Topics >> Semicon", "SMB" => "SMB", "Storage" => "Hot Topics >> Storage","Uncategorized" => "News"}
          doc.find(each_field.path+'/sectionname').each do | each_cate |
            if !(cat_name = each_cate.content).blank?
            cat =hash_map["#{cat_name}"] #.split("/").join(" >> ")
#debugger
            new_cat = @xml_site_id.categories.find_by_full_name(cat) if cat
              # new_cat = Category.create(:parent_id=> 0,:name=> cat ,:alias_name=> cat.split(" >> ").join("-").downcase) if new_cat.blank?
            logger_article_id.info("Category Id => #{new_cat.id} :name => #{new_cat.full_name}")
            new_cat.data_proxy_ids = new_cat.data_proxy_ids + [@xml_site_id.data_proxy_id] if !new_cat.data_proxy_ids.include?(@xml_site_id.data_proxy_id)
            cat_id << new_cat.id if new_cat
            end
          end
          article.category_ids = cat_id.uniq unless cat_id.blank?
        else
          puts "Category not exists!"
          logger_article_id.info("Category not exists!")
        end






             publish_date=doc.find(each_field.path+'/pubdate')
              article.publish_date=(publish_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if publish_date and publish_date.first and not publish_date.first.content.to_s.empty?
             article.display_date = (publish_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if publish_date and publish_date.first and not publish_date.first.content.to_s.empty?
	      article.updated_at=(publish_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if publish_date and publish_date.first and not publish_date.first.content.to_s.empty?
	      article.created_at=(publish_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if publish_date and publish_date.first and not publish_date.first.content.to_s.empty?
              if options[:draft_flag]
             article.active =false
             article.is_draft =true
             else
             article.active =true
             article.is_draft =false
              end

#debugger

              if article.save_with_out_time_stamp
                logger.info("article successfully save --->#{article.id}") if puts "#{article.id}"
             @xml =   XmlMigratedData.create(:model_type => "Article",:ext_id => "#{old_id}",:int_id => article.id,:publication_id => @xml_site_id.id,:old_url_part=>"",:previous_id=>"",:old_urls=>old_url)
                puts "article successfully save --->#{article.id}"
               puts "XmlMigratedData id #{@xml.id}"
              logger_article_id.info("#{XmlMigratedData.id}")
               logger_article_id.info("article successfully save --->#{article.id}")    
              old_url = (doc.find(each_field.path+'/articlelink').first.content).gsub("#{doc.find(node.path+'/link').first.content}",'')
	      new = Article.find_by_id("#{article.id}")
	      Ambient.init()
	      Ambient.current_site = @xml_site_id	
         #    OpenCalaisByTag.article(@xml_site_id,new)

#         begin
#	puts "Successfully created the redirect ==>#{old_url} to #{new.url}" if ActiveRecord::Base.connection.execute("insert INTO all_redirects (host,orig_uri,destination,redirect_type,record_type,created_at,updated_at) VALUES ('#{@xml_site_id.name}','#{db.escape_string(old_url)}','#{new.url}','permanent','uri',now(),now())")
#           logger.info("Success fully ------>created old url: #{old_url} and new url: #{new.url}   article id #{new.id}")         
#        rescue
logger_not_insert = Logger.new("#{RAILS_ROOT}/log/new_article_redirects_test1.log")
logger_not_insert.info("insert INTO all_redirects (host,orig_uri,destination,redirect_type,record_type,created_at,updated_at) VALUES ('#{@xml_site_id.name}','#{old_url}','#{new.url}','permanent','uri',now(),now())")
#logger.info("created old url: #{old_url} and new url: #{new.url}   article id #{new.id}")
#                puts "created old url:#{old_url} and new url:#{new.url}   article id #{new.id}"
#      end

                logger.info("article successfully save --->#{article.id}")
              else
                  puts "article not save --->#{file_path.split('/').last}"
                logger.info("article not save --->#{file_path.split('/').last}")
              end
            else

               logger_article_id.info("article id found--------->Intid  --->#{find_id.int_id} -----> file name #{file_path.split("/").last}")
              puts "article id found--------->Int =  #{find_id.int_id}"
	      old_url = (doc.find(each_field.path+'/articlelink').first.content).gsub("#{doc.find(node.path+'/link').first.content}",'')
	      new_art = Article.find_by_id("#{find_id.int_id}")
	      Ambient.init()
	      Ambient.current_site = @xml_site_id


               if new_art	
              # OpenCalaisByTag.article(@xml_site_id,new_art)

                
#debugger
=begin
puts "Successfully created the redirect ==>#{old_url} to #{new_art.url}" if ActiveRecord::Base.connection.execute("insert INTO all_redirects (host,orig_uri,destination,redirect_type,record_type,created_at,updated_at) VALUES ('#{@xml_site_id.name}','#{old_url}','#{new_art.url}','permanent','uri',now(),now())")
           logger.info("Success fully ------>created old url: #{old_url} and new url: #{new_art.url}   article id #{new_art.id}")

 rescue
logger_not_insert1 = Logger.new("#{RAILS_ROOT}/log/old_article_redirects.log")
logger_not_insert1.info("insert INTO all_redirects (host,orig_uri,destination,redirect_type,record_type,created_at,updated_at) VALUES ('#{@xml_site_id.name}','#{old_url}','#{new_art.url}','permanent','uri',now(),now())")
=end
               else
		puts "Article not find with the ID -->" #{find_id.int_id}"
	      end
            end
     else # link nil --art id
          logger.info("No article id in XML file")
      end 
          end
       # link nil --art id
        else
          logger.info("Site Short name not matched on xml file --> #{file_path.split('/').last}")

          puts "Site Short name not matched on xml file --> #{file_path.split('/').last}"
        end
      end
    end

         def self.replace_image(content,xml_article_id,site_id,logger,options,file_path)
           image_ids = []
           content.gsub!(/(<img[^>]*[^>]*>)/i) do |img_tag|
             puts "inline image found ----------------------->#{img_tag}"
             image = save_image(img_tag,xml_article_id,site_id,logger,options,file_path)
             if image
               image.update_attributes(:default_version_id => image.image_details.first.id,:thumbnail_version_id => image.image_details.last.id) if image.default_version_id==nil and image.thumbnail_version_id==nil
             end
             if @image_flag
               if image
                 image_ids << image.id
                 img_tag.sub(/src=['|"][^'|"]*['|"]/i,"src='#{image.default_image.image_path}'")
               else
                 img_tag
               end
             else
               img_tag
             end
           end
           return content,image_ids
         end



       def self.save_image(image,xml_article_id,site_id,logger,options,file_path)
      @image_flag = true
         begin
    image=~/<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
    img_src= $2
    extra_info = "#{$1} #{$3}"

puts "image_full_path ***************"
    image_full_path = find_image_path(img_src,options,file_path)
        puts image_full_path
    
    if image_full_path
      puts "before saving xml migrated data"
      find_img_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",img_src,site_id])
      if find_img_id !=nil
        #debugger
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
       if $1
         img_alt= $1
       else
         img_alt=""
       end
       image_name=img_src.split("/").last
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
#debugger
  file_new = File.new("#{image_full_path}")
  @flag ="read"
  if options[:stand_alone] == true
    if image_name=~/\.([^\.]+)$/
      image=Image.image_migration_for_standalone(file_new,image_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
    else
      mimetype = `file -ib "#{image_full_path}"`.gsub(/\n/,"")
      full_file_name = "#{image_name}.#{mimetype.split('/').last}"
      image=Image.image_migration(file_new,full_file_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title           
    end
  else
    if image_name=~/\.([^\.]+)$/
      image=Image.image_migration(file_new,image_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
    else
      mimetype = `file -ib "#{image_full_path}"`.gsub(/\n/,"")
      full_file_name = "#{image_name}.#{mimetype.split('/').last}"
      image=Image.image_migration(file_new,full_file_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title           
    end
  end
  puts "internal image create with id --------> #{image.id}" if image
 logger.info("internal image create with id --------> #{image.id}")
  XmlMigratedData.create(:model_type => "Image",:ext_id => img_src,:int_id => image.id,:publication_id => site_id) if image
  return image
end



=begin
def self.find_image_path(imgsrc,options,file_path)
  data_path= options[:inline_asset_path]
  if imgsrc
    data_path.each do|site_url,value|
    if imgsrc.match(/^#{Regexp.escape(site_url)}/)
  imgsrc=~/^#{Regexp.escape(site_url)}(.*)/i
      image_src_rest = $1
      puts "#{value}#{image_src_rest}"
      image_full_path = value+image_src_rest
      return image_full_path
    end
  end
end
return nil
end
=end

#=begin
def self.find_image_path(imgsrc,options,file_path)

  data_path= options[:inline_asset_path]
log_img = Logger.new("#{RAILS_ROOT}/log/image_find_#{Time.now.to_date}.log")
log_img_err = Logger.new("#{RAILS_ROOT}/log/image_does_not_find_#{Time.now.to_date}.log")

  if imgsrc =~ /((http|Http|https|Https):\/\/[a-z0-9_.-i\/]+)?((\/images\d+|\/images\/)(.*(.jpg|.jpeg|.png|.gif|.JPG|.JPEG|.PNG|.GIF)))/
   image_full_path = data_path + $3
    if File.exists?(image_full_path)
      log_img.info("Image Exists? in #{image_full_path} in #{file_path.split('/').last}")
      return image_full_path
    else
#debugger
      img = "wget #{imgsrc}"
      system(img)
       (FileUtils.mkdir_p "#{Rails.root}/NOKOGIRIMG").first
      `mv #{Rails.root}/#{imgsrc.split('/').last} #{Rails.root}/NOKOGIRIMG`
      if File.exist?("#{Rails.root}/NOKOGIRIMG/#{imgsrc.split('/').last}")
       log_img.info("Image  exists in NOKOGIRIMG  #{imgsrc.split('/').last} in #{file_path.split('/').last}")
        image_full_path = "#{Rails.root}/NOKOGIRIMG/#{imgsrc.split('/').last}"
        return image_full_path
      else
        puts "Not Exists!"
        log_img_err.info("Image does not  exists in server  #{imgsrc.split('/').last} in #{file_path.split('/').last}") 
        return nil
      end
    end
  return nil
  end
end

#=end




def self.replace_asset(content,xml_article_id,site_id,options)
 content.gsub!(/<a href=['|"]([^'|"]*)['|"]/i) do |anchor_tag|
   puts "anchor tag found=================>#{anchor_tag}"
   @assest_original_path = "#{$1}"
    puts "assest path = #{@assest_original_path}"
   ext = @assest_original_path.split('/').last.split('.').last if @assest_original_path !="/" and @assest_original_path !=""
   if ext == "pdf" || ext=="doc"
     puts "assest path = #{@assest_original_path}"
     asset_path = match_asset_path(@assest_original_path,options)
     if asset_path
       if File.exist?("#{asset_path}")
         asset = save_assets(asset_path,site_id,@assest_original_path)
         if asset
          anchor_tag.sub(/href=['|"][^'|"]*['|"]/,"href='#{asset.document_path}'")
         else
           anchor_tag
         end
       else
        puts "file_not_find"
        return content
       end
     else
       puts "no assests path match"
      anchor_tag
     end
   else
     puts "anchor tag not matched for pdf"
        anchor_tag
   end
 end
     return content
end

def self.match_asset_path(anchor_tag,options)
  data_path= options[:inline_asset_path]
  if anchor_tag
    data_path.each do|site_url,value|
    if anchor_tag.match(/^#{Regexp.escape(site_url)}/)
      anchor_tag=~/^#{Regexp.escape(site_url)}(.*)/i
      asset_src_rest = $1
      puts "#{value}#{asset_src_rest}"
      asset_full_path = value+asset_src_rest
      return asset_full_path
    end
  end
  return nil
end
end

def self.save_assets(href,site_id,asset_content_path)
  find_pdf_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Pdf",asset_content_path,site_id])
  if find_pdf_id
  puts "old pdf id found ------> #{find_pdf_id.int_id}"
    digital_assest= DigitalAsset.find_by_id(find_pdf_id.int_id)
    return  digital_assest
  else
    file_new = File.new("#{href}")
    digital_asset=DigitalAsset.new()
    digital_asset.name=href.split("/").last
    digital_asset.data_proxy_id = site_id
    if digital_asset.save
      FileUtils.mkdir_p  "public/digital_assets/#{digital_asset.id}",:mode => 0755
          directory = "public/digital_assets/#{digital_asset.id}"
          org_asset_path = File.join(directory,digital_asset.name)  # create the file path        
          File.open(org_asset_path, "wb") { |f| f.write(file_new.read) } # write the file
          digital_asset.update_attributes(:document_path=>"/digital_assets/#{digital_asset.id}/#{digital_asset.name}")
          puts "digital_asset Created Sucessfully ======> '/digital_assets/#{digital_asset.id}/#{digital_asset.name}'"
          XmlMigratedData.create(:model_type => "Pdf",:ext_id => asset_content_path,:int_id => digital_asset.id,:publication_id => site_id)
          return digital_asset
        else
          puts "#{href}"
          digital_asset = DigitalAsset.find_by_name("#{href}".split("/").last)
          if digital_asset
            puts "digital_asset find sucessfully with id-->#{digital_asset.id}"
            XmlMigratedData.create(:model_type => "Pdf",:ext_id => asset_content_path,:int_id => digital_asset.id,:publication_id => site_id)
            return digital_asset
          else
            return nil
          end
        end
      end
    end
    
    def self.tag_create(article_content)
      resp= Calais.enlighten( :content => article_content,:license_id => "n6bpk2ra4pg5qpygt686fxup",:output_format =>:json)
      json=ActiveSupport::JSON.decode(resp)
      @tags=[]
      json.values.each do |value|
        if value["name"] != nil
          @tags << value["name"]
        end
      end
      return @tags
    end
  end

