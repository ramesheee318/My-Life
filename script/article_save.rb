    if article.save(:validate => false)
      puts "#{article.id}"
         
        
            if doc.find('/article/imagesets').first
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
       
        
            if doc.find('/article/gallery').first.content.to_s !="" and doc.find('/article/gallery').first.content.to_s !="\n"
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
      
     
       
      if !doc.find('/article/comments/comment').blank?
        doc.find('/article/comments/comment').each do |node1|
          xpath = node1.path
          doc.find(xpath+'/comment').each do |node|
            comment_oldid = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Comment",node['id'],@site.id])
            if comment_oldid !=nil
              comment=Comment.find_by_id(comment_oldid.int_id)
              comment.update_attributes(:article_id=>article.id,:entity_type=>"Article") if comment
            else
              #logger.info("comment not found id----->#{node['id']} for #{old_id}")
              comment = Comment.new()
              c_old_id = node['id']
              p_date=  doc.find(xpath+'/posted-date')
              comment.created_at= (p_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if p_date and p_date.first and not p_date.first.content.to_s.empty?
              comment.updated_at= (p_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if p_date and p_date.first and not p_date.first.content.to_s.empty?
              title= doc.find(xpath+'/title').first.content
              comment.title = title.to_s if title
              message = doc.find(xpath+'/message').first.content
              comment.description = message.to_s if message
              cname = doc.find(xpath+'/commenter-name').first.content
              comment.user_name = cname.to_s if cname
              cemail = doc.find(xpath+'/commenter-email').first.content
              comment.email = cemail.to_s if cemail
              status = doc.find(xpath+'/status').first.content
              comment.status = status.to_s if status
              if comment.save
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
      end
     
      

       puts "article saved with id -->#{article.id}"
      logger.info("article saved with id -->#{article.id}")
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
      #logger.info("Validation errors article_content #{article_content.errors.full_messages.join(", ")}")
    end
