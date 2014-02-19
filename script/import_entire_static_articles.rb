require 'xml/libxml'
require 'RMagick'
require 'find'  
require 'ruby-debug'
class ImportEntireStaticArticles
  logger=Logger.new("#{Rails.root}/log/article_migration.log")
  
  def self.migrate(directories,options={})
    logger=Logger.new("#{Rails.root}/log/#{options[:site_short_name]}_new_#{Time.sr_now.to_date}.log")
    n=0
    Find.find(directories) do | file_path |
      
      unless File.directory?(file_path)
        n=n+1
        puts "#{n} ==> #{file_path}"
        GC.start if n%50==0
puts " -----1"
          process_xml(file_path,options,logger)
        end     
      end
  end     
  
  def self.process_xml(file_path,options,logger)
    doc = parse_xml(file_path,logger)
      check_and_process_xml_doc(doc,options,logger,file_path)if doc
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
  
  def self.check_and_process_xml_doc(doc,options,logger,file_path)
  
    if options[:check_old_articles]
    puts " -----2"
    
      old_id = doc.find('/article/article').first['id']
      
      @xml_site_id = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
      find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article",old_id,@xml_site_id.id])
      if find_id == nil
	    process_xml_doc(doc,options,logger,file_path,old_id)
      else
         puts "article id found--------->Int =  #{find_id.int_id}" 
     end
    else
      process_xml_doc(doc,options,logger,file_path,old_id)
    end  
  end
  
  def self.process_xml_doc(doc,options,logger,file_path,old_id)
    old_id = doc.find('/article/article').first['id']
    puts  "XML ID: #{old_id}"
    article = Article.new()
     puts " -----3"
     
        if !doc.find('/article/language').blank?
          xml_language = doc.find('/article/language').first['Language']
          if !xml_language.blank?
            language =  Language.find_by_alias_name(xml_language)
            language = Language.create(:name => 'English', :alias_name => xml_language)  unless !language.blank?
          else
          
            language = Language.create(:name => 'English', :alias_name => 'en')
          end
         article.language_id =language.id if language
          else
          
               language = Language.create(:name => 'English', :alias_name => 'en')
               article.language_id =language.id if language
        end

    @site=Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
    Time.zone = "New Delhi"
    article.sites = [@site]
  
    title = doc.find('/article/title')
    article.title = title.first.content.strip.to_s if !title.first.blank?
    
    sub_title = doc.find('/article/sub_title')
    article.sub_title = sub_title.first.content.to_s if !sub_title.first.blank?

    title_url = doc.find('/article/title_url')
    article.title_url = title_url.first.content.to_s if !title_url.first.blank?
    puts " -----4"
    fragment_title_text = doc.find('/article/fragment_title_text')
    article.fragment_title_text = fragment_title_text.first.content.to_s  if !fragment_title_text.first.blank?

    summary=doc.find('/article/summary')
    article.description = summary.first.content.to_s if !summary.first.blank?

    author_name_string = doc.find('/article/author_name_string')
   article.author_alias = author_name_string.first.content.to_s  if !author_name_string.first.blank?
      
     
          if !doc.find('/article/source').blank?
          source_name = doc.find('/article/source').first['alais']
          source = Source.find_by_alais_name(source_name) if source_name
          article.source_id = source.id if source
          end
       
    doc.find('/article/content_type').each do |node|
    section_name= node['id']; entity_type = node['entity_type']
     if section_name !=nil
     section = Section.find_by_alias_name(section_name)
      if !section.blank?
      article.section_id = section.id
      section.site_ids = section.site_ids + [@site.data_proxy_id] unless section.site_ids.include?(@site.data_proxy_id)
      else
      
      section = Section.create(:name => "#{section_name}",:alias_name => "#{section_name}",:entity_type => "#{entity_type}")
      article.section_id = section.id
     logger.info("the new section found in the xml ---->#{section_name}----for sites-->#{options[:site_short_name]}-----for id---->#{old_id} then create the new section==>#{section.id}") if section.site_ids = section.site_ids + [@site.data_proxy_id] 
      end
    end
  end 
      
       puts " -----5"
    if !doc.find('/article/meta_tags').first.blank?
      if !doc.find('/article/meta_tags/meta_keywords').first.blank?
      meta_key = doc.find('/article/meta_tags/meta_keywords').first.content.to_s 
      article.meta_keywords = meta_key
     end
     if !doc.find('/article/meta_tags/meta_description').first.blank?
      meta_desc = doc.find('/article/meta_tags/meta_description').first.content.to_s
      article.meta_description = meta_desc
     end
  end


     old_url=[]
     doc.find('/article/old_url').each do |xml_urls|
       if xml_urls.content.to_s !=""
         xml_url = OldUrl.new()
         xml_url.old_url = xml_urls.content.to_s
         old_url << xml_url
      end
     end
  
 puts " -----7"
    contents_new =[]
    doc.find('/article/content').each do|xml_content|
    contents_new << xml_content.content.to_s #.gsub(/<page.*>|<\/page>/,"")
    end
  new_con = contents_new.join("<p><!-- pagebreak --></p>")
 
  content_with_new_image_path,image_ids = replace_image(new_con,old_id,@site.id,logger,options)
  #content_withnew_assets = replace_asset(content_with_new_image_path,old_id,@site.id,options)
  
   article.content = content_with_new_image_path
  # article.content = content_withnew_assets
   article.image_ids = image_ids if image_ids
   puts " -----88"
  if !doc.find('/article/primary_medium').first.blank?
   if !(medium = doc.find('/article/primary_medium').first.content).blank?
    article.primary_medium = medium.to_s
    end
  end
   puts " -----8"
  display_date=doc.find('/article/dates/display_date')
  article.display_date=(display_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if !display_date.blank? && !display_date.first.blank? && !display_date.first.content.to_s.blank?
        
        publish_date=doc.find('/article/dates/valid_from')
        article.publish_date=(publish_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        
        created_at = doc.find('/article/dates/created_date')
        article.created_at=(created_at.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if !created_at.blank? && !created_at.first.blank? &&  !created_at.first.content.to_s.blank?
        
        updated_at = doc.find('/article/dates/last_modified_date')
        updated_at_date=(updated_at.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if !updated_at.blank? && !updated_at.first.blank? && !updated_at.first.content.to_s.blank?
        article.updated_at = updated_at_date
        puts " -----9"
        xml_tag_ids=[]
        if doc.find('/article/tags').blank?
          doc.find('/article/tags/tag').each do | node |
            if node['id'] !=""
              find_tag = @site.tags.find_by_name(node['id'])
              xml_tag_ids << find_tag.id if find_tag
              unless find_tag
                find_tag=Tag.create(:name => node['id'], :entity_type => "Article")
                @site.tags << find_tag
                xml_tag_ids << find_tag.id if find_tag      
                XmlMigratedData.create(:model_type => "Tag", :ext_id => old_id, :int_id => find_tag.id, :publication_id => @site.id )
              end
            end
          end
          article.tag_ids = xml_tag_ids.uniq unless xml_tag_ids.blank?
        end
        puts " -----10"
        
        cat_id= []
        if !doc.find('/article/categories').blank?
          doc.find('/article/categories/category').each do |node|
            if node['name']
              if node['name']!="" || node['name']!=" "
                cat_name = node['name'] #.downcase.gsub(/(\A|\s)\w/){ |letter| letter.upcase }
                logger.info("category_found ---->#{cat_name}")
                new_cat = @site.categories.find_by_full_alias_name(cat_name) if cat_name
                if !new_cat
                  new_cat = @site.categories.find_by_full_name(cat_name) if cat_name
                end
                cat_id << new_cat.id if new_cat
                puts "category_found with id ---->#{new_cat.id}" if new_cat
                unless new_cat
                  logger.info("New category created from xmls --->#{node['name']}")
                end
              end
            end
          end
          article.category_ids = cat_id.uniq unless cat_id.blank?
        end
        
        
        if !doc.find('/article/author_name_string').first.blank?
          author_string = doc.find('/article/author_name_string').first.content.to_s
          article.author_alias = author_string if author_string !=""
        end
        puts " -----13"
        @author_alias = []
        if !doc.find('/article/authors').blank?
          
          doc.find('/article/authors/author').each do |node|
            path = node.path
            
            author_email = doc.find(path+'/author_email').first.content
            if author_email
              
              author = @site.authors.find_by_email("#{author_email}")
              if author
                puts "auhtor find with id  -->#{author.id}"
                @author_alias << author.id
              else
                puts "auhtor not find with email ->#{author_email}"
                firstname = doc.find(path+'/author_firstname').first.content
                lastname  = doc.find(path+'/author_lastname').first.content
                email= doc.find(path+'/author_email').first.content
                new_author =   Author.new()
                new_author.firstname = "#{firstname}"
                new_author.lastname = "#{lastname}"
                new_author.email = "#{email}"
                if new_author.save(false)
                  puts "auhtor created with id  -->#{new_author.id}"
                  @site.author_ids =  @site.author_ids + [new_author.id]
                  @author_alias << new_author.id
                end
              end	    
            end      
          end
          article.author_ids = @author_alias if @author_alias!=[]
          
        end    
        
        #Video
        puts " -----14"
        if options[:asset_flag]
          if doc.find('/article/media_path').first
            media_path = doc.find('/article/media_path').first.content
            video_old_id= XmlMigratedData.find(:first,:conditions=>['model_type=? and ext_id=? and publication_id=?',"Media",media_path,@site.id])
            if !video_old_id
              media = create_video(media_path,@site.id,options[:video_binary_path],logger)
            else
              media= MediaDetail.find(video_old_id.int_id)
              puts "old media id found with id------> #{media.id}" if media
            end
            article.media_detail_id = media.id.to_s if media 
          end
          
          if doc.find('/article/audio_path').first
            audio_path = doc.find('/article/audio_path').first.content
            audio_old_id= XmlMigratedData.find(:first,:conditions=>['model_type=? and ext_id=? and publication_id=?',"Audio",audio_path,@site.id])
            if !audio_old_id
              audio = create_audio(audio_path,@site.id,options[:video_binary_path],logger)
            else
              audio = Audio.find(video_old_id.int_id)
              puts "old Audio id found with id------> #{audio.id}" if audio
            end
            article.audio_id  = audio.id.to_s if audio 
          end
        end
        
        
        puts " -----15"
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
        end
        puts " -----16"
        
        if options[:draft_flag]
          article.active =false
          article.is_draft =true
        else
          article.active =true
          article.is_draft =false  
        end
        
        if !(format = doc.find('/article/format').first).blank?
          article.format = format.content.to_s if !format.content.blank?
        end
        
        if !(url_part = doc.find('/article/url_part').first).blank?
          article.format = url_part.content.to_s if !url_part.content.blank?
        end
        
        
        if article.save(:validate => false)
          puts "Article ID -->#{article.id}"
          
          puts " -----18"
          if !doc.find('/article/imagesets').blank?
            imageset_id = doc.find('/article/imagesets').first.content.split('/')[3]   if doc.find('/article/imagesets').first.content !=""
            if imageset_id
              puts "imageset find with id------------->#{imageset_id}"
              migrated_image_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",imageset_id,@site.id])
              if !migrated_image_id        
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
                    image = Image.image_migration(file_new,Array(image_name),alt="",@flag,extra_info="",caption="",title="",@site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
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
                  return nil
                end
              else
                image= Image.find(migrated_image_id.int_id)
                puts "------old image found id image set ------>#{image.id}" if image
              end
              article.image = ImageProperty.new(:image_id=>image.id,:alt_tag=>image.alt_tag) if image
            end
          end
          puts " -----19"
          
          if !doc.find('/article/gallery').blank? 
            doc.find('/article/gallery').each do |xml_gallery|
              if xml_gallery
                xpath =  xml_gallery.path
                name =  doc.find(xpath+'/name').first.content
                description =  doc.find(xpath+'/description').first.content
                img_seq = ImageSequence.create(:name=> name,:description=> description,:site_id=> @site.id)
                doc.find(xpath+'/image_property').each do |gallery_image|
                  xpath = gallery_image.path
                  imageset_id = doc.find(xpath+'/imageset_path').first['image_id'] 
                  position_id = doc.find(xpath+'/imageset_path').first['position']
                  puts "gallery imageset_id --> #{imageset_id}"
                  puts "gallery position_id--> #{position_id}"
                  migrated_image_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image",imageset_id,@site.id])
                  if !migrated_image_id
                    if  doc.find(xpath+'/imageset_path').first['description']
                      gallery_description =  doc.find(xpath+'/imageset_path').first['description'].to_s
                    else
                      gallery_description = ""
                    end         
                    
                    if doc.find(xpath+'/imageset_path').first['alt_tag']
                      alt = doc.find(xpath+'/imageset_path').first['alt_tag'].to_s
                    else
                      alt = ""
                    end
                    if doc.find(xpath+'/imageset_path').first['caption']
                      caption = doc.find(xpath+'/imageset_path').first['caption']
                    else
                      caption = ""
                    end
                    if doc.find(xpath+'/imageset_path').first['titel']
                      title= doc.find(xpath+'/imageset_path').first['titel']
                    else
                      title = ""
                    end
                    xml_file_path = doc.find(xpath+'/imageset_path').first.content.to_s
                    options[:imageset_binary_path].each do |data_path|
                      if File.exist?("#{data_path}#{xml_file_path}")
                        @file_full_path = "#{data_path}#{xml_file_path}"
                      end
                    end
                    if @file_full_path
                      file_new = File.new("#{@file_full_path}")
                      @flag ="read"
                      extra_info=""     
                      image_name = xml_file_path.split("/").last
                      
                      if image_name=~/\.([^\.]+)$/
                        image = Image.image_migration(file_new,Array(image_name),alt,@flag,extra_info,caption,title,@site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title  
                      else
                        mimetype = `file -ib "#{@file_full_path}"`.gsub(/\n/,"")
                        full_file_name = "#{image_name}.#{mimetype.split('/').last}"
                        puts "file full path after mime type --------------------------------------->convertion ----------------->#{full_file_name}"
                        image=Image.image_migration(file_new,Array(image_name),alt,@flag,extra_info,caption,title,@site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title  
                      end
                      puts "new imageset created ---------------->#{image.id}" if image
                    else
                      puts "file not found ---->"
                      return nil
                    end
                  else
                    image= Image.find(migrated_image_id.int_id)
                    puts "old imageset_galery_id -----------> #{image.id}" if image  
                  end
                  ImageProperty.create(:entity_type=>"ImageSequence",:entity_id=>img_seq.id,:image_id=>image.id,:alt_tag=>image.alt_tag,:sequence_number=>position_id,:description=>gallery_description) if image 
                  XmlMigratedData.create(:model_type => "ImageSequence",:ext_id =>"",:int_id => img_seq.id,:publication_id =>@site.id) 
                  article.gallery = GalleryProperty.new(:image_sequence_id=>img_seq.id,:entity_attribute=>"ImageGallery") if image
                end
              end
            end
          end
          
          puts " -----21"
          
          if !doc.find('/article/comments/comment').blank?
            
            doc.find('/article/comments/comment').each do | node |
              xpath = node.path
              cmd_old_id = doc.find(xpath+'/comment').first['id']
              comment_oldid = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Comment",cmd_old_id,@site.id])
              if comment_oldid !=nil
                comment=Comment.find_by_id(comment_oldid.int_id)
                comment.update_attributes(:article_id=>article.id,:entity_type=>"Article") if comment
              else
                #logger.info("comment not found id----->#{node['id']} for #{old_id}")
                comment = Comment.new()
                c_old_id = cmd_old_id
                p_date=  doc.find(xpath+'/posted_date')
                comment.created_at= (p_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if p_date and p_date.first and not p_date.first.content.to_s.empty?
                comment.updated_at= (p_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if p_date and p_date.first and not p_date.first.content.to_s.empty?
                title= doc.find(xpath+'/title').first.content
                comment.title = title.to_s if title
                message = doc.find(xpath+'/message').first.content
                comment.description = message.to_s if message
                cname = doc.find(xpath+'/commenter_name').first.content
                comment.user_name = cname.to_s if cname
                cemail = doc.find(xpath+'/commenter_email').first.content
                comment.email = cemail.to_s if cemail
                status = doc.find(xpath+'/status').first.content
                comment.status = status.to_s if status
                if comment.save
                  puts "NEW comment create for articles with id-->#{comment.id} for article-->#{article.id}"
                  logger.info("new comment create for articles with id-->#{comment.id} for article-->#{article.id}")
                  new_comment= Comment.find_by_id("#{comment.id}")
                  new_comment.update_attributes(:article_id=>article.id,:entity_type=>"Article")
                  migrated_data = XmlMigratedData.create(:model_type => "Comment",:ext_id => c_old_id,:int_id => comment.id,:publication_id => @site.id)
                else
                  logger.info("comment not found id----->#{node['id']} for #{old_id}")
                end
              end
            end
          end
          
          
          puts " -----last"
          puts "article saved with id -->#{article.id}"
          logger.info("article saved with id -->#{article.id}")
          `mv "#{file_path}" "#{file_path}/.."`
          XmlMigratedData.create(:model_type => "Article",:ext_id => old_id,:int_id => article.id,:publication_id => @site.id,:article_last_modify_date =>updated_at_date,:old_url_part=>"",:previous_id=>"")  
          
          if options[:old_url_mapping] # Should be true
            Ambient.init()
            Ambient.current_site = @site  
            article_new = Article.find(article.id)
            old_urls = article_new.article_old_urls
            for old_url in old_urls 
              # Created For New URL
              url_file.write "#{old_url} #{Util.new.article_url_path(article_new)}\n" if old_url
            end
          end
          
        else
          puts "Article Not save for #{article.errors.full_messages.join(", ")}"
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
          
          image =~ /<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
          img_src= $2.split('?').first
          extra_info = "#{$1} #{$3}"
          image_full_path = find_image_path(img_src,options)
          
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
      
      
      
      
      
      def self.find_image_path(imgsrc,options)
        
        data_path= options[:inline_asset_path]
        if imgsrc 
          data_path.each do|site_url,value|
          
          if imgsrc.match(/#{Regexp.escape(site_url)}/)
            imgsrc=~/#{Regexp.escape(site_url)}(.*)/i
            image_src_rest = $1
            puts "#{value}#{image_src_rest}"
            
            image_full_path = value+image_src_rest 
            return image_full_path
          end
        end
      end
      return nil
    end
    
    def self.replace_asset(content,xml_article_id,site_id,options)
      
      content.gsub!(/<a href=['|"]([^'|"]*)['|"]/i) do |anchor_tag|
        puts "anchor tag found=================>#{anchor_tag}"
        @assest_original_path = "#{$1}"
        puts "assest path = #{@assest_original_path}"
        ext = @assest_original_path.split('/').last.split('.').last if @assest_original_path !="/" and @assest_original_path !=""
        if ext == "pdf"
          puts "assest path = #{@assest_original_path}"
          asset_path = match_asset_path(@assest_original_path,options)
          if asset_path
            if File.exist?("#{asset_path}")
              asset = save_assets(asset_path,site_id,@assest_original_path)
              if asset
                anchor_tag.sub(/href=['|"][^'|"]*['|"]/,"href='#{asset.document_path}'")
                
              else
                anchor_tag
              end              #return content, asset_ids
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
      return content #,nil
      
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
      #  begin
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
        return nil
      end
      #      rescue
      #        return nil
      #      end
    end
  end
  
  def self.create_audio(audio_path,site_id,audio_dump_path,logger)
    begin
      audio_dump_path.each do |data_path|
        if File.exist?("#{data_path}#{audio_path}")
          @file_full_path = "#{data_path}#{audio_path}"
        end
      end 
      
      if @file_full_path
        local_file_path = "#{@file_full_path}"
        file_type = audio_path.split("/").last
        
        audio_details  = {"site_name" => "#{Site.find(site_id).short_name}", "name" => "#{file_type}","audio_path" => "#{@file_full_path}" }
        Audio.upload_from_xml_import(audio_details)
        
      end
    end
  end
  
  
  
  def self.create_video(video_file_path,site_id,video_dump_path,logger)
    
    begin
      video_dump_path.each do |data_path|
        if File.exist?("#{data_path}#{video_file_path}")
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
            FileUtils.mkdir_p  "#{Rails.root}/public/medias/#{media.id.to_s}" ,:mode => 0755
            output_path = "#{Rails.root}/public/medias/#{media.id.to_s}"
            flv_filename = "#{media.name}.flv"
            flv_file_path = "#{output_path}/#{flv_filename}"
            MediaManager.convert(local_file_path,output_path,flv_filename)  if file_type=~/(.*?)\.(mp4|wmv|MP4|WMV)$/ 
            FileUtils.cp local_file_path,flv_file_path  if file_type=~/(.*?)\.(flv|FLV)$/
            FileUtils.mkdir_p  "#{Rails.root}/public/medias/#{media.id.to_s}/thumbs" ,:mode => 0755
            image_list,image_path = MediaDetail.set_thumb(media,page=nil,site_id,flag="no_image",flag1="createfile_obj")
            
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
