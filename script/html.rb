require 'nokogiri'
require 'open-uri'
require 'rss'  #---->rss feed parsing capabilities
require 'ruby-debug'

class Html
def self.iotest_migration(options)
 for  url in options[:urls]
      doc = Nokogiri::HTML(open(url))
      article = Article.new()
      Ambient.init
      @site=Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
      Ambient.current_site = @site
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
      section = @site.sections.find_by_alias_name(options[:section_name])
      if section.blank?
        section = Section.create(:name => options[:section_name] ,:alias_name => options[:section_name].downcase ,:entity_type => "Article" )
        # article.section_id = section.id 
        section.data_proxy_ids = section.data_proxy_ids + [@site.data_proxy_id]
      end
      article.section_id = section.id

     #Title
     article.title = url.split('/').last.gsub(".html",'') if !url.split('/').last.blank?
     
     #Content
    date = doc.xpath('//body')
    new_con = date.first.to_s.gsub("%20"," ").gsub("\n","").gsub("\t","").gsub("\r","") #.to_s.gsub("<p class=\"intro\">","").gsub("<div class=\"image\">","").gsub("<p class=\"body\">","").gsub("<div class=\"story\">","").gsub("<p class=\"credit\">","").gsub("<span class=\"body\">","").gsub("</span>","").gsub("</body>","").gsub("\n","").gsub("\t","").gsub("<p class=\"caption\">","").gsub("</div>","").gsub("\n","").gsub("\t","").gsub("</p>","").gsub("<body>","").gsub("<div id=\"concrete-intentions-tadao-ando\">","").gsub("\r","")
       content_with_new_image_path,image_ids = replace_image(new_con,tes,@site.id,logger,options)
       debugger
          article.content = content_with_new_image_path
      puts "Article id =====>#{article.id}"  if article.save_and_publish
    end
 end
 
 
 
 def self.replace_image(content,xml_article_id,site_id,logger,options)
  image_ids = []
  content.gsub!(/(<img[^>]*[^>]*>)/i) do |img_tag|
    puts "inline image found ----------------------->#{img_tag}"
    image = save_image(img_tag,xml_article_id,site_id,logger,options)
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
        image_name=img_src.split("/").last
        if File.exist?("#{image_full_path}")
          file_new = File.new("#{image_full_path}")
          @flag ="read"
          if image_name=~/\.([^\.]+)$/
            image=Image.image_migration(file_new,[image_name],img_alt,@flag,extra_info ="",caption=nil,title=nil,site_id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
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


def self.find_image_path(imgsrc,options)
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
 end
