require 'rss'  #---->rss feed parsing capabilities
require 'open-uri'
require 'ruby-debug'


class HtmlParsing

  def self.for_bi(options)
    rss_content = ""        
    open(options[:urls].first) do |f|
      rss_content = f.read
    end
    rss = RSS::Parser.parse(rss_content, false)
    
    rss.items.each do |item|
      puts "+++++++++++++++++++++++++++++++++++++++++++++++++"
    article = Article.new()
      Ambient.init
      @site=Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
      Ambient.current_site = @site

debugger
    old_art = @site.articles.find_by_title "#{item.title}"
   
    if old_art.blank?
      article = Article.new()
#      Ambient.init
#      @site=Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
#      Ambient.current_site = @site
      Time.zone = "New Delhi"
      article.sites = [@site]
      
      # Source
      source = @site.sources.find_by_name(options[:source_name])
      if source.blank?
        source = @site.sources.first
        if source.blank?
          source = Source.create(:name => options[:source_name])
          source.data_proxy_ids = source.data_proxy_ids + [@site.data_proxy_id]
        end
      end
      article.source_id = source.id
      
      #Section
      section = @site.sections.find_by_name(options[:section_name])
      if section.blank?
        section = Section.create(:name => options[:section_name] ,:alias_name => options[:section_name].downcase ,:entity_type => "Article" )
        # article.section_id = section.id 
        section.data_proxy_ids = section.data_proxy_ids + [@site.data_proxy_id]
      end
      article.section_id = section.id
      
      
      
      #Category
      category = @site.categories.find_by_name(options[:category_name])
      if category.blank?
        category = Category.create(:parent_id=>0,:name=> options[:category_name],:full_name => options[:category_name],:full_alias_name => options[:category_name].downcase ,:alias_name=> options[:category_name].downcase)
        category.data_proxy_ids = category.data_proxy_ids + [@site.data_proxy_id]
      end
      article.category_ids = [category.id]
      
      
      #Tag
      tag = @site.tags.find_by_name(options[:tag_name])
      if tag.blank?
        tag = Tag.create(:name=> options[:category_name],:entity_type => "Article")
        tag.data_proxy_ids = tag.data_proxy_ids + [@site.data_proxy_id]
      end
      article.tag_ids =  [tag.id]
      
      #Author
      author = @site.authors.find_by_name(options[:author_name])
      if author.blank?
        author = @site.authors.find_by_email(options[:author_name] + "@ramesh.com")
        if author.blank?
          author =   Author.new()
          author.firstname = options[:author_name]
          author.lastname = options[:author_name]
          author.email = options[:author_name] + "@ramesh.com"
          author.sites = [@site]
          
          puts "Author -->#{author.id}" if author.save
        end
      end
      article.author_ids =  [author.id]
      
      
      puts "#{item.title}"
      
      article.title = item.title
      article.description = item.description
      puts "#{item.description}"
      @content = item.content_encoded
        inline_image_ids = []
        content_with_new_image_path,content_image_ids = replace_image(@content,@site.id,options) if @content

        article.content = content_with_new_image_path
        inline_image_ids << content_image_ids
        article.image_id = inline_image_ids.flatten
 
      puts "Article id =====>#{article.id}"  if article.save_and_publish
    end
  end
 end 
  
  
  
def self.replace_image(content,site_id,options)
image_ids = []
content.gsub!(/(<img[^>]*[^>]*>)/i) do |img_tag|
  puts "inline image found ----------------------->#{img_tag}"

  image = save_image(img_tag,site_id,options)
  if image
    image_tah = image.alt_tag.gsub(/-|_/,'')
   image.alt_tag = image_tah
    image.save
    image.update_attributes(:default_version_id => image.image_details.first.id,:thumbnail_version_id => image.image_details.last.id) if image.default_version_id==nil and image.thumbnail_version_id==nil
#if image.default_version_id==nil and image.thumbnail_version_id==nil
#image.default_version_id = image.image_details.first.id
#image.thumbnail_version_id  = image.image_details.last.id
#image.save
#puts "#{image.default_version_id}"
#end
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

  
  
  
  
  def self.save_image(image,site_id,options)
  @image_flag = true
  begin
    image=~/<img([^>]*)src=['|"]([^'|"]*)['|"]([^>]*)(.*)>/i
    img_src= $2
    extra_info = "#{$1} #{$3}"
    image_full_path = find_image_path(img_src)

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
          if options[:stand_alone] == true
            if image_name=~/\.([^\.]+)$/
              image=Image.image_migration_for_standalone(file_new,image_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
            else
              mimetype = `file -ib "#{image_full_path}"`.gsub(/\n/,"")
              full_file_name = "#{image_name}.#{mimetype.split('/').last}"
              image=Image.image_migration(file_new,full_file_name.to_a,img_alt,@flag,extra_info,caption=nil,title=nil,site_id) #fetch_file,file_name,img_alt,flag,extra_info,caption,title           
            end
          else
            if image_name=~/\.([^\.]+)$/
              image=Image.image_migration(file_new,[image_name],img_alt,@flag,extra_info,caption=nil,title=nil,site_id) #fetch_file,file_name,img_alt,flag,extra_info,caption,title
            else
              mimetype = `file -ib "#{image_full_path}"`.gsub(/\n/,"")
              full_file_name = "#{image_name}.#{mimetype.split('/').last}"
              image=Image.image_migration(file_new,[full_file_name],img_alt,@flag,extra_info,caption=nil,title=nil,site_id) #fetch_file,file_name,img_alt,flag,extra_info,caption,title           
            end
          end
          puts "internal image create with id --------> #{image.id}" if image
          XmlMigratedData.create(:model_type => "Image",:ext_id => img_src,:int_id => image.id,:publication_id => site_id) if image
          return image
        else
          puts "not found file"
         # logger.info("intenal image file not found for path #{image_full_path}")
          @image_flag=false
          return @image_flag
        end
      end
    end
  rescue => e
    puts "errorin image fetching"
  #  logger.error("Error in internal image creation ======> #{e}")
    @image_flag=false
  end
end
  
  
  
  
  def self.find_image_path(imgsrc)
    if imgsrc
      image_name=imgsrc.split("/").last
      fetch_file=Net::HTTP.get_response(URI.parse(URI.encode(imgsrc)))
      if fetch_file.class== Net::HTTPNotFound
        puts "image not found #{imgsrc}"
        #logger.error("Not save image for path==>#{img_src}==> for xml article id ==> #{old_id}")
        return nil
      else
        img_alt = image_name
        File.open("#{Rails.root}/NOKOGIRIMG/#{image_name}", "wb") { |f| f.write(fetch_file.body) }
        image_full_path="#{Rails.root}/NOKOGIRIMG/#{image_name}"
        return image_full_path
      end
    end
    
    return nil
  end
  
  
end  


