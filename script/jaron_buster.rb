  class JargonBustreXmlCreater
    def self.for_ca
        basedir="/home/kailash/Desktop"
  
      Dir.chdir(basedir)
        backup_folder= FileUtils.mkdir_p "jargon_buster_xml_creater"
        Dir.chdir("#{basedir}/#{backup_folder}")
        final_file_created_path="#{basedir}/#{backup_folder}"

        #@file = "#{final_file_created_path}/jargon_bustre.xml"        
       articles= Article.find_by_sql("select * from articles where section_id =89 and id in (select article_id from articles_sites where data_proxy_id =32) order by title asc;")
      #doc = XML::Document.new()
      for article_new in articles
        puts article_new.id
        doc = XML::Document.new()
        doc.root = XML::Node.new("ID#{article_new.id}")
        root = doc.root

        root << article_title = XML::Node.new('title')
        article_title << "#{article_new.title}"


        root << article_body = XML::Node.new('content')
        article_body << "#{article_new.article_contents.last.content}"


      @file.puts("#{doc}") 
       doc.save("#{final_file_created_path}/jargon_bustre.xml")

      end
        @file.close
        doc.save("#{final_file_created_path}/jargon_bustre.xml")
    else
     puts "No magazine issue find in database"
   
 end
end
_-------------------------_____________----------------------------------------------------------
class JargonBustreXmlCreater
    def self.for_ca
    
doc=File.open('/home/kailash/Desktop/jargon_buster_xml_creater/url.xml','a+')
       # @file = "#{final_file_created_path}/jargon_bustre.xml"        
#@url = []
    
       articles = Article.find_by_sql("select * from articles where section_id =89 and id in (select article_id from articles_sites where data_proxy_id =32) order by title asc;")
     doc = XML::Document.new()
  
    @articles.each do |articles_new|    
      #for articles_new in articles
   #    puts articles_new.id
      # articles.each do |articles_new|
      # articles do |articles_new|
       
     #  @url << articles_new
      #puts @url
       
        doc = XML::Document.new() 
         doc.root = XML::Node.new("ID#{articles_new.id}")
        root = doc.root
 
        root << article_title = XML::Node.new('{articles_new.title}')
        article_title << articles_new.title


        root << page_body = XML::Node.new('{articles_new.article_contents.last.content}')
        page_body << articles_new.article_contents.last.content

#end

      
     #@file.puts"#{articles_new}"
   
     #debugger
      #@file.puts("#{doc}")   #if article_new.id = true
   #  doc.save("#{final_file_created_path}/@url.xml")
doc.save("/home/kailash/Desktop/jargon_buster_xml_creater/url.xml")
      end
       
 end
end
-----------------------------------------------------------------------------------------------
class JargonBustreXmlCreater
    def self.for_ca
        basedir="/home/kailash/Desktop"
  
      Dir.chdir(basedir)
        backup_folder= FileUtils.mkdir_p "jargon_buster_xml_creater"
        Dir.chdir("#{basedir}/#{backup_folder}")
        final_file_created_path="#{basedir}/#{backup_folder}"

        @file = "#{final_file_created_path}/jargon_bustre.xml"        
       

 @articles = Article.find_by_sql("select * from articles where section_id =89 and id in (select article_id from articles_sites where data_proxy_id =32) order by title asc;")
@articles.each do |article|

	
@file.puts("<article>")
 
 @file.puts("<ID#{article.id}>")
 @file.puts("<title>#{article.title}</title>")
 @file.puts("<content>#{article.article_contents.last.content}</content>")
 @file.puts("</ID#{article.id}>")
 @file.puts("</article>")
end


     
        @file.close
     
   
 end
end
-----------------------(all articles create to one xml file)-----------------------------------------------------------------
class JargonBustreXmlCreater
    def self.for_ca
  	@date =  Date.today
  @local_file_path = FileUtils.mkdir_p "/home/kailash/Desktop"
  script_starting_time = Time.now
 	file = File.new("#{@local_file_path}/#{script_starting_time.strftime("%d-%m-%Y")}_JargonBuster.xml","w")
	@articles = Article.find_by_sql("select * from articles where section_id =89 and id in (select article_id from articles_sites where data_proxy_id =32) order by title asc;")
file.puts("<article>")
 @articles.each do |article|
 file.puts("<ID#{article.id}>")
 file.puts("<title>#{article.title}</title>")
 file.puts("<content>#{article.article_contents.last.content}</content>")
 file.puts("</ID#{article.id}>")
 end
file.puts("</article>")
file.close

 end
 end


