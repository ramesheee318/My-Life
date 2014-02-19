require 'xml/libxml'
require 'RMagick'
require 'find'  
require 'ruby-debug'
require 'csv'
# CSV.foreach("") do |row|

class CommonDatamigration
    
 def self.migrate(directories,options={})
    logger=Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_new_#{Time.sr_now.to_date}.log")
    #Time.zone = "Eastern Time (US & Canada)"
    if options[:old_url_mapping]
      url_file = File.open("#{RAILS_ROOT}/tmp/url_mapping_for_#{options[:site_short_name]}_#{Time.sr_now.to_date}.txt","w")
    end
    n=0
    directories.each do |directory|
      Find.find(directory) do |file_path|
        unless File.directory?(file_path)
          n=n+1
          GC.start if n%50==0
          process_xml(file_path,options,logger,url_file)
        end
      end
    end
    if options[:old_url_mapping]
    url_file.close
    end
  end
  
  def self.process_xml(file_path,options,logger,url_file)
    doc = parse_xml(file_path,logger)
     begin
      check_and_process_xml_doc(doc,options,logger,file_path,url_file) if doc
    rescue => e
      xmlerror_logger=Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_error_in_xml#{Time.sr_now.to_date}.log")
      xmlerror_logger.info("error message in xml parsing for file---->#{e.to_s}")  
      xmlerror_logger.info("error in xml parsing for file---->#{file_path}-->#{e.backtrace}")  
    end 
  end
  
  def self.parse_xml(file_path,logger) 
  begin  
    doc = XML::Document.file("#{file_path}")
    return doc
  rescue
    logger.info("the file having some utf8 charset prblem -->#{file_path}")
      return nil
  end 
  end
  
 def self.check_and_process_xml_doc(doc,options,logger,file_path,url_file)
    if options[:check_old_articles]
      old_id = doc.find('/article/article_id').first.content
      @xml_site_id = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
      find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article",old_id,@xml_site_id.id])
      if find_id == nil
        process_xml_doc(doc,options,logger,file_path,url_file)
      else
        puts "article id found--------->Int =  #{find_id.int_id}"
      end
    end
  end

  def self.process_xml_doc(doc,options,logger,file_path,url_file)
    old_id = doc.find('/article/article_id').first.content
    puts old_id
    article = Article.new()
    puts file_path
    logger.info("File name: #{file_path}")
   
    if doc.find('/article/language').first
    xml_language = doc.find('/article/language').first['id']
    language =  Language.find_by_alias_name(xml_language) if xml_language and xml_language !=""
   article.language_id =language.id if language and language != ""
    end
Ambient.init
    @site=Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
Ambient.current_site = @site    
     Time.zone = "London"

   article.sites = [@site]

puts "Source"      
    if options[:source_name]
    source = @site.sources.find_by_name(options[:source_name])         
    else
    source_name = doc.find('/article/source').first['id']
    source = @site.sources.find_by_name(source_name) if source_name
    end  
   article.source_id = source.id

puts "Section"

    if options[:section_mapping_file] and File.exists?(options[:section_mapping_file])
     section_mapping = {}
      CSV.foreach("#{options[:section_mapping_file]}") do |row|
      section_mapping[row.shift.strip] = row
      end
    else
       section_mapping = {}
    end   
     array_section_id = []
     
      if options[:section_name]
      array_section_id << @site.sections.find_by_name(options[:section_name]).id
      else   
      doc.find('/article/content-type').each do |node|
        section_name= node['id']
          if section_mapping["#{section_name}"] != nil
           section_mapping["#{section_name}"].each do | each_section_name |
           array_section_id << @site.sections.find_by_name(each_section_name.strip).id
           end
          end
      end
    end
   article.section_id = array_section_id.first
    
    title=doc.find('/article/title')
   article.title = title.first.content.to_s if title and title.first

    sub_title = doc.find('/article/sub_title')
   article.sub_title = sub_title.first.content.to_s if !sub_title.first.blank?

    title_url = doc.find('/article/title_url')
   article.title_url = title_url.first.content.to_s if !title_url.first.blank?
   
    fragment_title_text = doc.find('/article/fragment_title_text')
   article.fragment_title_text = fragment_title_text.first.content.to_s  if !fragment_title_text.first.blank?

    summary=doc.find('/article/summary')
   article.description = summary.first.content.to_s if summary and summary.first
=begin
puts "Content"      
  contents_new =[]
    doc.find('/article/content').each do|xml_content|
    contents_new << xml_content.content.to_s #.gsub(/<page.*>|<\/page>/,"")
  end
  new_con = contents_new.join("<p><!-- pagebreak --></p>")
  content_with_new_image_path,image_ids = replace_image(new_con,old_id,@site.id,logger,options)
  content_withnew_assets = replace_asset(content_with_new_image_path,old_id,@site.id,options)
  article.content = content_with_new_image_path
  article.content = content_withnew_assets 
  article.image_ids = image_ids.uniq if !image_ids.blank?
=end
puts "Category"
 if options[:category_mapping_file] and File.exists?(options[:category_mapping_file])
    category_mapping = {}
     CSV.foreach("#{options[:category_mapping_file]}") do |row|
     category_mapping[row.shift.strip.gsub(/\s+/,"\s")] = row
     end
  else
    debugger
        category_mapping = {}
  end     

 cat_id = []
 if options[:category_full_name]
  cat_id << @site.categories.find_by_full_name(options[:category_full_name].strip).id 
 else
     if doc.find('/article/categories').first
       doc.find('/article/categories').each do |node1|
       xpath= node1.path
         doc.find(xpath+'/category').each do |node|
         xpath= node.path
          if doc.find(xpath+'/full-name').first
           if doc.find(xpath+'/full-name').first.content.strip !=""
              cat = doc.find(xpath+'/full-name').first.content.strip
                 if category_mapping[cat] != nil
                  category_mapping[cat].each do |cat_name|
                    new_cat = @site.categories.find_by_full_name(cat_name.strip.gsub(/\s+/,"\s")) if cat_name
                    cat_id << new_cat.id if new_cat
                    puts "category_found with id ---->#{new_cat.id}" if new_cat
                    unless new_cat
                    logger.info("New category not in db--->#{cat_name.strip.gsub(/\s+/,"\s")}")
                    end
                  end
                 end
           end
          end
         end
       end
     end
 end
 debugger
 article.category_ids = cat_id.uniq unless cat_id.blank?

   
puts "Tag"
 if options[:tag_mapping_file] and File.exists?(options[:tag_mapping_file])
     tag_mapping = {}
     CSV.foreach("#{options[:tag_mapping_file]}") do |row|
     tag_mapping[row.shift.strip] = row
     end
  else   
    debugger
         tag_mapping = {}
  end
 
  xml_tag_ids=[]
if options[:tag_name]
   xml_tag_ids <<  @site.tags.find_by_name(options[:tag_name]).id
    
else     
if doc.find('/article/tags/tag').first 
 doc.find('/article/tags').each do |pnode|
    xpath=pnode.path
  doc.find(xpath+'/tag').each do |node|
   if node['id'].strip !=""  
    if tag_mapping[node['id'].strip] != nil
      tag_mapping[node['id'].strip].each do | each_tag |
       find_tag = @site.tags.find_by_name(each_tag.strip)
       xml_tag_ids << find_tag.id if find_tag
       find_tag = @site.tags.find_by_alias_name(each_tag.strip.downcase) unless find_tag
       xml_tag_ids << find_tag.id if find_tag
       unless find_tag
         debugger
       logger.info("New tag not in db --->#{each_tag.strip}")
       end
      end 
    end
   end
  end
 end
end
end
debugger
  article.tag_ids = xml_tag_ids.uniq unless xml_tag_ids.blank?

debugger
puts "Author"
   if options[:author_mapping_file] and File.exists?(options[:author_mapping_file])
      author_mapping = {}
      CSV.foreach("#{options[:author_mapping_file]}") do |row|
      author_mapping[row.shift.strip] = row
     end
    else
    debeugger
    author_mapping = {}
    end
       
author_alias = []
if options[:author_email]
          author_alias << @site.authors.find_by_email(options[:author_email]).id
else
if doc.find('/article/authors').first
   if doc.find('/article/authors').first.content.to_s !=""
       doc.find('/article/authors').each do |node1|
       xpath= node1.path
         doc.find(xpath+'/author').each do |node|
          path= node.path
          author_email = doc.find(path+'/author-email').first.content.strip
           if author_email != nil
             debugger
            if author_mapping[author_email] != nil
              debugger
             author_mapping[author_email].each do | each_email |
               debugger             
              author = @site.authors.find_by_email(each_email.strip)
              if author
              puts "auhtor ------ find with id  -->#{author.id}"
              author_alias << author.id
              else 
              logger.info("author not assing plz chcek ")
              end
             end
            end   
           end
         end     
       end      
   end
end
end
debugger
  article.author_ids = author_alias if author_alias!=[]

  if doc.find('/article/author-name-string').first
    author_string = doc.find('/article/author-name-string').first.content.to_s
   article.author_alias = author_string if author_string !=""
  end

 
  if doc.find('/article/primary-medium').first
    medium = doc.find('/article/primary-medium') if doc.find('/article/primary-medium').first.content !=""
   article.primary_medium = medium.first.content.to_s if medium and medium.first
  end
  
 if doc.find('/article/meta-tags').first
    if doc.find('/article/meta-tags/meta-keywords').first
      meta_key=doc.find('/article/meta-tags/meta-keywords') if doc.find('/article/meta-tags').first.content !=""
     article.meta_keywords = meta_key.first.content.to_s if meta_key and meta_key.first
    end
    
    if doc.find('/article/meta-tags/meta-description').first
      meta_desc=doc.find('/article/meta-tags/meta-description') if doc.find('/article/meta-tags/meta-description').first.content!=""
     article.meta_description = meta_desc.first.content.to_s if meta_desc and meta_desc.first 
    end
  end

  
  display_date=doc.find('/article/dates/display-date')
  article.display_date=(display_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if display_date and display_date.first and not display_date.first.content.to_s.empty?
  
  publish_date=doc.find('/article/dates/valid-from')
  article.publish_date=(publish_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if publish_date and publish_date.first and not publish_date.first.content.to_s.empty?

  created_at = doc.find('/article/dates/created-date')
  article.created_at=(created_at.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if created_at and created_at.first and not created_at.first.content.to_s.empty?
  
  updated_at = doc.find('/article/dates/last-modified-date')
  updated_at_date=(updated_at.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if updated_at and updated_at.first and not updated_at.first.content.to_s.empty?
  article.updated_at = updated_at_date
  

#Video
  if options[:asset_flag]
  
    if doc.find('/article/audio_path').first
      xml_assets_id = doc.find('/article/audio_path').first.content
      if File.exists?("#{options[:audio_binary_path].first}/#{xml_assets_id}")
              local_file_path = "#{options[:audio_binary_path].first}/#{xml_assets_id}"
           File.open("#{RAILS_ROOT}/tmp/ttr.mp3", "wb") { |f| f.write(File.open("#{local_file_path}").read)}   
      logger.info("audio path does ========#{options[:audio_binary_path].first}/#{xml_assets_id}=========>exists File name ==#{old_id}")
        audio = Audio.upload_migration(local_file_path,@site,migration=true)
       article.audio_id = audio.first.id if audio
      else
        logger.info("audio path does not exists File name ==#{old_id}")
        puts "audio path not exists"
      end
    end
  
    if doc.find('/article/media-path').first
      media_path= doc.find('/article/media-path').first.content
      
       video_old_id= XmlMigratedData.find(:first,:conditions=>['model_type=? and ext_id=? and publication_id=?',"Media",media_path,@site.id])
       if not video_old_id    
         
         media = create_video(media_path,@site.id,options[:video_binary_path],logger)
         article.media_detail_id = media.id.to_s if media
      else
        media= MediaDetail.find(video_old_id.int_id)
        puts "old media id found with id------> #{media.id}" if media
       end
      article.media_detail_id = media.id.to_s if media 
    end
  end
  

  magazine_name = doc.find('print-magazine/volume-issue').first.content.to_s if doc.find('print-magazine/volume-issue').first
  magazine_date=doc.find('print-magazine/print-issue-date').first.content.to_s if doc.find('print-magazine/print-issue-date').first
  if !magazine_date.blank?
    puts "----------> magazine date=======>#{magazine_date}"
     print_issue_date = (magazine_date).to_time.strftime("%d-%m-%Y %H:%M:%S")
           issue_date=(magazine_date).to_time.strftime("%Y-%m-%d")
    if !magazine_name.blank?
      find_magazine = MagazineIssue.find(:first,:conditions=>["short_name=? and  source_id=?",magazine_name,source.id])
    else
      find_magazine = MagazineIssue.find(:first,:conditions=>["short_name=? and  source_id=?",issue_date,source.id])
      end
    unless find_magazine
      if !magazine_name.blank?
        find_magazine=MagazineIssue.create(:short_name=>magazine_name,:source_id=>source.id,:date_of_publication=>print_issue_date)
         XmlMigratedData.create(:model_type => "Magazine",:ext_id =>magazine_name,:int_id => find_magazine.id,:publication_id => @site.id)
      else
        find_magazine=MagazineIssue.create(:short_name=>issue_date,:source_id=>source.id,:date_of_publication=>print_issue_date) 
        XmlMigratedData.create(:model_type => "Magazine",:ext_id => issue_date,:int_id => find_magazine.id,:publication_id => @site.id) 
      end
    end
    puts "---find maganine_id ===============>#{find_magazine.id}"
   article.magazine_issue_id = find_magazine.id  if find_magazine
    # article_content.magazine_issue_id = find_magazine.id if find_magazine
   end
  

   if options[:draft_flag]
     article.active =false
     article.is_draft =true
    else
     article.active =true
     article.is_draft =false  
    end


puts "imagesets"
 if !doc.find('/article/imagesets').first.blank?
        imageset_id = doc.find('/article/imagesets').first.content.split('/')[3]   if doc.find('/article/imagesets').first.content !=""
        if imageset_id
          puts "imageset find with id------------->#{imageset_id}"
          migrated_image_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",imageset_id,@site.id])
          if not migrated_image_id        
            xml_file_path = doc.find("/article/imagesets").first.content.to_s
                        options[:imageset_binary_path].each do |data_path|
                          
                          if File.exist?("#{data_path}#{xml_file_path}")
                            @file_full_path = "#{data_path}#{xml_file_path}"
                          end
                        end
                                                if @file_full_path
                                                  file_new = File.new("#{@file_full_path}")
                                                  @flag ="read"
                                                  image_name = xml_file_path.split("/").last
                                                  if image_name=~/\.([^\.]+)$/
                                                    image = Image.image_migration(file_new,image_name.to_a,alt="",@flag,extra_info="",caption="",title="",@site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
                                                  else
                                                    mimetype = `file -ib "#{@file_full_path}"`.gsub(/\n/,"")
                                                    full_file_name = "#{image_name}.#{mimetype.split('/').last}"
                                                    puts "file full path after mime type --------------------------------------->convertion ----------------->#{full_file_name}"
                                                    image=Image.image_migration(file_new,full_file_name.to_a,alt="",@flag,extra_info="",caption="",title="",@site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
                                                  end
                                                  if image
                                                    puts "image saved with id inside the imageset or gallery---------------------->#{image.id}"
                                                    XmlMigratedData.create(:model_type => "Image",:ext_id =>imageset_id,:int_id => image.id,:publication_id =>@site.id)
                                                    #return image
                                                  else
                                                    logger.info("Validation errors images #{image.errors.full_messages.join(", ")}") if image
                                                    #logger.info("error in image saved imageset --> #{filepath} for imageset id --> #{imagesetid}---> for file name ------->#{file_name}")
                                                    return nil
                                                  end
                                                else
                                                  puts "file not found ---->"
                                                  #logger.info("file not found --> #{filepath} for imageset id --> #{imagesetid}")
                                                  #### return nil
                                                end
                                              else
            image= Image.find(migrated_image_id.int_id)
            puts "------old image found id image set ------>#{image.id}" if image
          end
          
         article.image = ImageProperty.new(:image_id=>image.id,:alt_tag=>image.alt_tag) if image
        end
      end

puts "------------------->gallery"
if !doc.find('/article/gallery').first.blank?
if doc.find('/article/gallery').first.content.to_s !="" and doc.find('/article/gallery').first.content.to_s !="\n"
    doc.find('/article/gallery').each do |xml_gallery|
    
      if xml_gallery
        img_seq = ImageSequence.create(:name=>old_id,:description=>old_id,:site_id=> @site.id)
        doc.find('/article/gallery/image_property/imageset_path').each do |gallery_image|
          path = gallery_image.path
          imageset_id = gallery_image
          position_id = doc.find(path+'/position').first.content.to_s
    puts "gallery imageset_id --> #{imageset_id}"
        gallery_caption = doc.find(path+'/caption').first.content.to_s 
        gallery_description = nil
          migrated_image_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",imageset_id,@site.id])
          if not migrated_image_id
            image_migration = ImageMigration.new(options[:image_set_xml_path])
            image = image_migration.image_parse_form_xml(imageset_id,@site.id,gallery_caption,options[:imageset_binary_path],logger,file_path)
            #puts "new image set created ---------------->#{image.id}" if image
          else
            image= Image.find(migrated_image_id.int_id)
            puts "old imageset_galery_id -----------> #{image.id}" if image  
          end
#          ImageImageSequence.create(:image_id=>image.id,:image_sequence_id=>img_seq.id,:sequence_number=>position_id) if image
          ImageProperty.create(:entity_type=>"ImageSequence",:entity_id=>img_seq.id,:image_id=>image.id,:alt_tag=>image.alt_tag,:sequence_number=>position_id,:description=>gallery_description) if image 
          XmlMigratedData.create(:model_type => "ImageSequence",:ext_id =>"",:int_id => img_seq.id,:publication_id =>@site.id) 
#        article.image_sequence_id = img_seq.id 
          article.gallery = GalleryProperty.new(:image_sequence_id=>img_seq.id,:entity_attribute=>"ImageGallery") if image
        end
      end
    end
   end
end
puts "last last"
debugger
  if article.save_with_out_time_stamp

puts "article saved with id -->#{article.id}" 
      logger.info("article saved with id -->#{article.id}")

puts "Succes fully Xml Migrated Data"
 xml_migrated_data = XmlMigratedData.create(:model_type => "Article",:ext_id => old_id,:int_id => article.id,:publication_id => @site.id,:article_last_modify_date =>updated_at_date,:old_url_part=>"",:previous_id=>"",:old_urls=>"")  

   old_url=[]
     doc.find('/article/old-url').each do |xml_urls|
       if xml_urls.content.to_s !=""
         old_url << xml_urls.content.to_s
         url_file.info("#{xml_urls.content.to_s} #{article.url}")
      end
     end
debugger
    if !old_url.blank? and old_url.each do | each_old_url |
      debugger  
           xml_url = OldUrl.create(:xml_migrated_data_id => "#{xml_migrated_data.id}" ,:old_url  =>  each_old_url  ,:created_at => Time.new.strftime("%d-%m-%Y %H:%M:%S"),:updated_at => Time.new.strftime("%d-%m-%Y %H:%M:%S"))
           puts "Succes fully Old URl Data"
    end;end

  else
    logger.info("not saved file==>#{file_path}")
    logger.info("Validation errors articles #{article.errors.full_messages.join(", ")}")
  end
  
end

def self.replace_image(content,xml_article_id,site_id,logger,options)
  image_ids = []
  content.gsub!(/(<img[^>]*[^>]*>)/i) do |img_tag|
    puts "inline image found ----------------------->#{img_tag}"
  image = save_image(img_tag,xml_article_id,site_id,logger,options)
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


def self.save_image(image,xml_article_id,site_id,logger,options)
  @image_flag = true
  begin
    image=~/<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
    img_src= $2
    extra_info = "#{$1} #{$3}"
    image_full_path = find_image_path(img_src,options)
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
        image_name=img_src.split("/").last.split("?").first
        if File.exist?("#{image_full_path}")
          file_new = File.new("#{image_full_path}")
          @flag ="read"
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
          logger.info("internal image not found file==>#{image}==> for xml article id ==> #{xml_article_id}")
          @image_flag=false
          return @image_flag
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
  XmlMigratedData.create(:model_type => "Image",:ext_id => img_src,:int_id => image.id,:publication_id => site_id) if image
  return image
end


def self.find_image_path(imgsrc,options)
  data_path= options[:inline_asset_path]
  if imgsrc 
    data_path.each do|site_url,value|
    if imgsrc.match(/^#{Regexp.escape(site_url)}/)
      imgsrc=~/^#{Regexp.escape(site_url)}(.*)/i
      image_src_rest = $1
      puts "#{value}#{image_src_rest}"
      image_full_path = value+image_src_rest 
      return image_full_path.split('?').first # image_full_path
    end
  end
end
return nil
end



def self.replace_asset(content,xml_article_id,site_id,options)
content.gsub!(/^<a\s+href=['|"]([^'|"]*)['|"][^>]*>/i) do |anchor_tag|
   puts "anchor tag found=================>#{anchor_tag}"
  @assest_original_path = "#{$1}"
  puts "assest path = #{@assest_original_path}"
   ext = @assest_original_path.split('/').last.split('.').last if @assest_original_path !="/" and @assest_original_path !=""
   if ext == "pdf"
     puts "assest path = #{@assest_original_path}"
     asset_path = match_asset_path_pdf(@assest_original_path,options)
     if asset_path
      if File.exist?("#{asset_path}")
         asset = save_assets(asset_path,site_id,@assest_original_path)
         if asset
           anchor_tag.sub!(/href=['|"]([^'|"]*)['|"]/,"href='#{asset.document_path}'")          
         else
           anchor_tag
     puts "n2" 
         end              #return content, asset_ids
       end
     else
       puts "no assests path match"
      anchor_tag
      puts "n3"
     end
   else
     puts "anchor tag not matched for pdf"
     anchor_tag
     puts "n4"
   end
   anchor_tag 
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

def self.match_asset_path_pdf(anchor_tag,options)
data_path= options[:inline_pdf_path]
  if anchor_tag
    data_path.each do|site_url,value|
    if anchor_tag.match(/#{Regexp.escape(site_url)}/)
      anchor_tag=~/#{Regexp.escape(site_url)}(.*)/i
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
#  begin
puts "888888888888888888"

    file_new = File.new("#{href}")
    digital_asset=DigitalAsset.new()
    digital_asset.name=href.split("/").last
    digital_asset.data_proxy_id = site_id
      FileUtils.mkdir_p  "public/digital_assets/#{digital_asset.id}",:mode => 0755
          directory = "public/digital_assets/#{digital_asset.id}"
          org_asset_path = File.join(directory,digital_asset.name)  # create the file path        
          File.open(org_asset_path, "wb") { |f| f.write(file_new.read) } # write the file
   digital_asset.document_path = "/digital_assets/#{digital_asset.id}/#{digital_asset.name}"
    if digital_asset.save(false)
          digital_asset.document_path = "/digital_assets/#{digital_asset.id}/#{digital_asset.name}"
          puts "digital_asset Created Sucessfully ======> '/digital_assets/#{digital_asset.id}/#{digital_asset.name}'" if digital_asset.save(false)
          XmlMigratedData.create(:model_type => "Pdf",:ext_id => asset_content_path,:int_id => digital_asset.id,:publication_id => site_id)
          return digital_asset
        else
          return nil
        end
      end
end


  def self.create_video(video_file_path,site_id,video_dump_path,logger)
    begin
      video_dump_path.each do |data_path|
        if File.exists?("#{data_path}#{video_file_path}")
          @file_full_path = "#{data_path}#{video_file_path}"
        end
      end 
      if @file_full_path
        local_file_path = "#{@file_full_path}"
        file_type = video_file_path.split("/").last
        if file_type=~/(.*?)\.(flv|mp4|wmv|FLV|MP4|WMV)$/ 
          media = MediaDetail.new(:site_id=>site_id,:original_file_name=>file_type,:name=>file_type.gsub(' ','_').split('.')[0])
          if media.save
            media.update_attributes(:video_path=>"/medias/"+media.id.to_s+"/"+media.name+".flv",:display_name=>media.name)
            FileUtils.mkdir_p  "#{RAILS_ROOT}/public/medias/#{media.id.to_s}" ,:mode => 0755
            output_path = "#{RAILS_ROOT}/public/medias/#{media.id.to_s}"
            flv_filename = "#{media.name}.flv"
            flv_file_path = "#{output_path}/#{flv_filename}"
            MediaManager.convert(local_file_path,output_path,flv_filename)  if file_type=~/(.*?)\.(mp4|wmv|MP4|WMV)$/ 
            FileUtils.cp local_file_path,flv_file_path  if file_type=~/(.*?)\.(flv|FLV)$/
            FileUtils.mkdir_p  "#{RAILS_ROOT}/public/medias/#{media.id.to_s}/thumbs" ,:mode => 0755
            image_list,image_path=MediaDetail.set_thumb(media,page=nil,site_id,flag="no_image",flag1="createfile_obj")
            image=MediaDetail.create_image_for_video(image_path+"/"+image_list[3],site_id,flag1="createfile_obj")
            logger.error("new image genetrated  from flv ---->#{image.id}") if image
            media.update_attributes(:image_id=>image.id) if image
            #            end
            meta_info = MediaManager.get_meta_info(output_path,flv_filename)
            file_size = File.size(flv_file_path)
            media.update_attributes(:file_size=>file_size,:video_duration=>meta_info.to_s)
            XmlMigratedData.create(:model_type => "Media",:ext_id => video_file_path,:int_id => media.id,:publication_id => site_id)
            return media
          end
        else
          logger.info("file type not supported for assest_id ----> #{video_file_path}")
          return nil
        end
      else
        logger.info("file not found for assest_id ----> #{video_file_path}")
        return nil
      end
    rescue => e
      logger.info("video set not find in assest xml --->#{video_file_path} error ====>#{e.backtrace}")
      return nil
    end
  end  
    
end



