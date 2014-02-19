require 'nokogiri'
require 'open-uri'
require 'rss'  #---->rss feed parsing capabilities
require 'ruby-debug'
require 'uri'
class HtmlMigration
  
  puts "*************************************Starting************************************"
  
  def self.migrate(directories,options={})
    logger = Logger.new("#{Rails.root}/log/#{options[:site_short_name]}_html_migration_#{Time.sr_now.to_date}.log")
    logger_file =  Logger.new("#{Rails.root}/log/#{options[:site_short_name]}_#{options[:file_name]}.log")
    n=0
#    Dir["#{directories}/*"].each do | each_dir |
#    if File.directory?(each_dir)     
#    Dir["#{each_dir}/*.html"].each do |file_path |
     Dir["#{directories}/*.html"].each do |file_path |
      unless File.directory?(file_path)
        n=n+1
        puts "#{n} ==> #{file_path}"
        GC.start if n%50==0
puts " -----1"
          process_xml(file_path,options,logger,logger_file)
        end     
      end
#    end
#  end
  
end



def self.process_xml(file_path,options,logger,logger_file)
  url = "#{file_path}"
  doc = Nokogiri::HTML(open(url))
  old_id = url.split('/').last #.gsub(".html",'')
  
   ide_id = options[:magazine_short_name].gsub(' ','-')  if options[:magazine_short_name]  
  Ambient.init
  @site = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
  Ambient.current_site = @site  
  find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article","#{ide_id}_#{old_id}",@site.id])

   if find_id.blank?
  # puts "Article Already there in DB"
   # else
    article = Article.new()
    Time.zone = "New Delhi"
    article.sites = [@site]
    
    #Title
    article.title = url.split('/').last.gsub(".html",'') if !url.split('/').last.blank?
    
    
    # Source
    @source = @site.sources.find_by_name(options[:source_name])
    if @source.blank?
      @source = @site.sources.first
      if @source.blank?
        @source = Source.create(:name => options[:source_name])
        @source.data_proxy_ids = @source.data_proxy_ids + [@site.data_proxy_id]
      end
    end
    article.source_id = @source.id
    #Section
      @section = Section.find_by_name(options[:section_name])
      @section = Section.create(:name => options[:section_name] ,:alias_name => options[:section_name].downcase ,:entity_type => "Article" ) if @section.blank?
       logger.info("Section --> #{@section.name}")
#      @section.data_proxy_ids = @section.data_proxy_ids + [@site.data_proxy_id] if !@section.data_proxy_ids.include?(@site.data_proxy_id)
      @section.site_ids = @section.site_ids + [@site.data_proxy_id] if !@section.site_ids.include?(@site.data_proxy_id)
#       @site.sections << @section if !@section.data_proxy_ids.include?(@site.data_proxy_id)
        article.section_id = @section.id
    
    puts "----->2"
    #Author
    @author = @site.authors.find_by_email(options[:author_email])
    if @author.blank?
      @author =   Author.new()
      @author.firstname = "admin"
      @author.lastname = "ramesh"
      @author.email = options[:author_email]
      @author.save(:validate => false)
       @site.author_ids =  @site.author_ids + [@author.id]
    end
    
    article.author_ids = [@author.id]

    puts "----->3"
   #MagazineIssue
   
   if options[:issue_volume] 
    find_magazine = MagazineIssue.find(:first,:conditions=>["short_name=? and  source_id=?",options[:magazine_short_name],@source.id])
     if find_magazine.blank?
     find_magazine = MagazineIssue.create( :source_id => "#{@source.id}", :created_by => 1,:short_name => "#{options[:magazine_short_name]}", :description =>"", :date_of_publication => "#{Time.new.to_time.strftime("%d-%m-%Y %H:%M:%S")}", :title => "Inside Magazine")
     end
    article.magazine_issue_id = find_magazine.id 
   end

    #Content
    date = doc.xpath('//body')
#   new_con = date.first.to_s.gsub("%20"," ").gsub("\n","").gsub("\t","").gsub("\r","").gsub(/ (class=\S+")/, "")
    new_con = date.first.to_xhtml.to_s.gsub("%20"," ").gsub(/ (class=\S+")/, "").gsub("/>","\/    >").gsub("\n","").gsub("\t","").gsub("\r","")

###new_con = date.first.to_xhtml.to_s.gsub("%20"," ").gsub(/ (class=\S+")/, "").gsub("/>","\/    >").gsub("\n","").gsub("\t","").gsub("\r","")
    content_with_new_image_path,image_ids = replace_image(new_con,old_id,@site.id,logger,file_path,options)
    article.content = content_with_new_image_path
    article.image_id = image_ids

=begin
     puts "----->4"
    if options[:draft_flag]
      article.active =false
      article.is_draft =true

    else
      article.active =true
      article.is_draft =false  
    end
=end

   if !options[:issue_date].blank?
   article.publish_date = MagazineIssue.find(:first,:conditions=>["short_name=? and  source_id=?","Jun 2010","#{s.sources.first.id}"]).date_of_publication #Time.sr_now
   article.display_date = MagazineIssue.find(:first,:conditions=>["short_name=? and  source_id=?","Jun 2010","#{s.sources.first.id}"]).date_of_publication
#    else
#    article.publish_date = Time.sr_now
#    article.display_date = article.publish_date
    end



      article.active =true
      article.is_draft =false
      article.publish_date = Time.sr_now
      article.display_date = article.publish_date


    
     puts "----->5"
    if options[:content_format]
      article.format = "#{options[:content_format]}"
      else
        article.format = "html"
      end
      # updated_at_date
#       article.save_and_publish
debugger
      if article.save(:validate => false) 
       logger_file.info("File Path: #{url}")
        logger.info("Article Saved success fully -->id: #{article.id}")
        puts "Article Saved success fully -->id: #{article.id}"  
        @xmlmigratedata = XmlMigratedData.create(:model_type => "Article",:ext_id => "#{ide_id}_#{old_id}",:int_id => article.id,:publication_id => @site.id,:article_last_modify_date =>"",:old_url_part=>"",:previous_id=>"")  
        puts "XmlMigratedData Saved success fully -->id: #{@xmlmigratedata.id}"  
        logger.info("XmlMigratedData Saved success fully -->id: #{@xmlmigratedata.id}")
      else
        puts "Article not saved"
      end

    else
     

      article = Article.find(find_id.int_id) #rescue nil
   #if article != nil
    #else
    #    find_id.delete
   #end
#find_id.delete
     if options[:draft_flag]
      article.active =false
      article.is_draft =true
     else
      article.active =true
      article.is_draft =false
     end
   
#article.destroy   
      puts "Article now is draft mode #{article.id}"  if article.save(:validate => false)
       puts "Old id already there************************8"
    end
  end
  
  
  
  def self.replace_image(content,xml_article_id,site_id,logger,file_path,options)
    image_ids = []
    content.gsub!(/(<img[^>]*[^>]*>)/i) do |img_tag|
      puts "inline image found ----------------------->#{img_tag}"
      image = save_image(img_tag,xml_article_id,site_id,logger,file_path,options)
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
  
  
  def self.save_image(image,xml_article_id,site_id,logger,file_path,options)
    @image_flag = true
    begin
      image=~/<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
      img_src= $2
      extra_info = "#{$1} #{$3}"
      image_full_path = find_image_path(img_src,file_path,options)
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
          if File.exist?("#{image_full_path}")
            file_new = File.new("#{image_full_path}")
            @flag ="read"
            if image_name=~/\.([^\.]+)$/
              image=Image.image_migration(file_new,[image_name],img_alt,@flag,extra_info ="",caption=nil,title=nil,site_id)
            else
              mimetype = `file -ib "#{image_full_path}"`.gsub(/\n/,"")
              full_file_name = "#{image_name}.#{mimetype.split('/').last}"
              image=Image.image_migration(file_new,full_file_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)
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
  
  
  def self.find_image_path(imgsrc,file_path,options)
    data_path =  file_path.gsub("#{file_path.split('/').last}","")
    if imgsrc 
      image_src_rest =  imgsrc #.split('/').first
       image_full_path = URI.unescape(data_path+image_src_rest)
      if File.exists?(image_full_path)
      
        return image_full_path
      else
 log_img = Logger.new("#{Rails.root}/log/#{options[:site_short_name]}_missing_images_#{Time.sr_now.to_date}.log")
 log_img.info("File name:#{imgsrc}  ; Path Dose not exists? #{image_full_path}")
      end
    end
    return nil
  end
  
end

