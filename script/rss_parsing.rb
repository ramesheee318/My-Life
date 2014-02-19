require 'nokogiri'
require 'open-uri'
require 'rss'  #---->rss feed parsing capabilities
require 'ruby-debug'

class RssParsing
  def self.bbc_migration(options)
    
    for  url in options[:urls]
      puts "********************************************8888888888888888888888"
      doc = Nokogiri::HTML(open(url))
      article = Article.new()
debugger      
      doc.xpath("//h1[@class='#{options[:class_for_title]}']").each do |title|
        puts "Title: #{title.content}"
        article.title = title.content
puts "#{title.content}"
      end
      Ambient.init
      
      # Site   
      @site=Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
      Ambient.current_site = @site
      Time.zone = "New Delhi"
      article.sites = [@site]
      
      # Source
      source = @site.sources.first
       if !source.blank?
        source.data_proxy_ids = source.data_proxy_ids + [@site.data_proxy_id] unless source.data_proxy_ids.include?(@site.data_proxy_id)
      else
        source = Source.create(:name => "Rss")
        source.data_proxy_ids = source.data_proxy_ids + [@site.data_proxy_id] 
      end  
      article.source_id = [source.id] 
      
      #Section
      section = @site.sections.first
      if !section.blank?
        section.data_proxy_ids = section.data_proxy_ids + [@site.data_proxy_id] unless section.data_proxy_ids.include?(@site.data_proxy_id)
      else
        section = Section.create(:name => options[:section_name] ,:alias_name => options[:section_name].downcase,:entity_type => "Article" )
        section.data_proxy_ids = section.data_proxy_ids + [@site.data_proxy_id] 
      end
      article.section_id = [section.id] 
      
      #Category
      category = @site.categories.first
      if !category.blank?
        category.data_proxy_ids = category.data_proxy_ids + [@site.data_proxy_id] unless category.data_proxy_ids.include?(@site.data_proxy_id)
      else
        category = Category.create(:parent_id=>0,:name=> options[:category_name],:full_name => options[:category_name],:full_alias_name => options[:category_name].downcase ,:alias_name=> options[:category_name].downcase)      
        category.data_proxy_ids = category.data_proxy_ids + [@site.data_proxy_id] 
      end
      
      article.category_ids = [category.id] 
      
      
      #Tag
      tag = @site.tags.first
      if !tag.blank?
        tag.data_proxy_ids = tag.data_proxy_ids + [@site.data_proxy_id] unless tag.data_proxy_ids.include?(@site.data_proxy_id)
      else
        tag = Tag.create(:name=> options[:category_name],:entity_type => "Article")      
        tag.data_proxy_ids = tag.data_proxy_ids + [@site.data_proxy_id] 
      end
      article.tag_ids = [tag.id] 
      
      #Author
      author = @site.authors.first #_by_firstname(options[:tag_name])
      if author.blank?
        author =   Author.new()
        author.firstname = options[:author_name]
        author.lastname = options[:author_name]
        author.email = options[:author_name] + "@kreatio.com"
        author.sites = [@site]
        
        puts "Author -->#{author.id}" if author.save(false)
      end
      
      article.author_ids = [author.id]  if !author.blank?
      
      
      #Description
      doc.xpath("//p[@class='#{options[:class_for_description]}']").each do |des|
        puts "Description:  #{des.content}"
        article.description = des.content
puts "#{des.content}"
      end
     debugger 
      #Content
      date = doc.xpath('//span[@class="story-date"]').remove
      list = date.xpath('//li').remove
      head2 = list.xpath('//h2').remove
      head1= head2.xpath('//h1').remove
      head3= head1.xpath('//h3').remove
      a = head3.xpath('//a').remove
      form = a.xpath('//form').remove
      form.xpath("//div[@class='#{options[:class_for_content]}']").each do | method_span |
        x = Nokogiri::HTML(method_span.content)
        x.xpath('//p').each do |c|
          puts "Content:--- #{ c.content.gsub("\n","").gsub("\t","")}"
          article.content = c.content.gsub("\n","").gsub("\t","")
puts "#{c.content}"
puts "<-------------------------------------------------------------------------->"

puts "<-------------------------------------------------------------------------->"

        end
      end
      
      #Image
      img_array = []
      doc.xpath("//div[@class='#{options[:class_for_image]}']").each do | image_link |
        image_link.traverse do |el|
          puts [el[:src], el[:href]].grep(/\.(gif|jpg|png|pdf)$/i)
          [el[:src], el[:href]].grep(/\.(gif|jpg|png|pdf)$/i).map{|l| URI.join(el, l).to_s}.each do |link|
            img_array.push link
          end
        end
      end
      
      if !img_array[0].blank?
        img = "wget #{img_array[0]}"
        system(img)
        
         (FileUtils.mkdir_p "#{Rails.root}/NOKOGIRIMG").first
        `mv #{Rails.root}/#{img_array[0].split('/').last} #{Rails.root}/NOKOGIRIMG`
        if File.exists?("#{Rails.root}/NOKOGIRIMG/#{img_array[0].split('/').last}")
          ["#{Rails.root}/NOKOGIRIMG/"].each do |data_path|
            if File.exist?("#{data_path}#{img_array[0].split('/').last}")
              @file_full_path = "#{data_path}#{img_array[0].split('/').last}"
            else
              puts "Not Exists!"
            end
          end
          if @file_full_path
            file_new = File.new("#{@file_full_path}")
            @flag ="read"
            image_name = img_array[0].split('/').last
            alt = img_array[0].split('/').last.split('.').first.gsub(/-|_/, '')
            
            image = Image.image_migration(file_new,[image_name],alt,@flag,extra_info="",caption="",title="",@site.id)#fetch_file,file_name,img_alt,flag,extra_info,caption,title
            if image != nil
              article.image = ImageProperty.create(:image_id=>image.id,:alt_tag=>image.alt_tag,:entity_type=>"Article")
            else
              puts "Image is nil"
            end
          end
        end
        
      else
        puts "Images dose not on data"
      end
      
     debugger 
      puts "Article id =====>#{article.id}"  if article.save_and_publish
    end
  end
  
  
  
  def self.rss_feed_migration(options)
    rss_content = ""        
    open(options[:ress_feed_path].first) do |f|
      rss_content = f.read
    end
    rss = RSS::Parser.parse(rss_content, false)
    rss.items.each do |item|
      puts "#{item.link}"
#      puts "#{item.description}"
#      puts "#{item.enclosure}"
#      puts "+++++++++++++++++++++++++++++++++++++++++++++++++"
    end
  end
  
end
