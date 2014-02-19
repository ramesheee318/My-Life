require "application_helper"
require 'libxml'
require 'find'
require 'ruby-debug'

class SimpleArticleImport
  
  def self.from_xml(directories,options={})
   # directories="/home/customer/Cybermedia/CMS/CMS_Admin/XML/"
    logger=Logger.new("#{RAILS_ROOT}/log/simple_article_migration.log")
    n=0
    directories.each do |directory|      
      Find.find(directory) do |file_path|
        unless File.directory?(file_path) 
          n=n+1
          GC.start if n%50==0          
          process_xml(file_path,logger,options)         
          end     
      end      
    end
   end 

  def self.process_xml(file_path,logger,options)
  doc = LibXML::XML::Document.file("#{file_path}")
  check_and_process_xml_doc(doc,logger,file_path,options)  
  end
  
    
    def self.check_and_process_xml_doc(doc,logger,file_path,options)
      site_short_name = {'DQWeek' => 'dq-week', 'DQChannels' => 'dq-channels' , 'DQEvent' => 'dq_event'}
      doc.find('channel').each do |node|
        title = doc.find(node.path+'/title').first.content
        if site_short_name[title] != nil
          @xml_site_id = Site.find(:first,:conditions=>['short_name=?',site_short_name[title]])
          doc.find(node.path+'/item').each do |each_field|
            # old_id = file_path.split('/').last.scan(/\d+.xml/).to_s.to_i
            old_id = (doc.find(each_field.path+'/articlelink').first.content.split('/') - ["0","",".",".."])[-1]
            find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article",old_id,@xml_site_id.id])
            if find_id == nil
              article = Article.new()
              article.title  = doc.find(each_field.path+'/articletitle').first.content.strip
              article.language =  Language.find_by_alias_name('en')
              author_alias = doc.find(node.path+'/authorname').first.content.strip
              article.author_alias = author_alias if author_alias !=""
              article.sites = [@xml_site_id]
              
              article_description =   doc.find(each_field.path+'/articledescription').first.content.strip
              article.description = article_description if article_description !=""
              article_content = doc.find(each_field.path+'/articlecontent').first.content
              
              article.content= article_content if article_content !=""
              old_url=[]
               (doc.find(each_field.path+'/articlelink').first.content).gsub("#{doc.find(node.path+'/link').first.content}",'').each do |xml_urls|
                if xml_urls.to_s !=""
                  xml_url = OldUrl.new()
                  xml_url.old_url = xml_urls.to_s
                  old_url << xml_url
                end
              end
              
              article_meta = doc.find(each_field.path+'/metadescription').first.content.strip
              article.meta_keywords = article_meta if article_meta !=""
              article.section_id = (@xml_site_id.sections.find_by_name "News").id

              source = (@xml_site_id.sources.find_by_alais_name(site_short_name[doc.find(each_field.path+'/source').first.content]))
              article.source_id = source.id if source
              #   tag = (doc.find(each_field.path+'/articlelink').first.content.split('/') - ["0","",".",".."])[-1].to_i
              xml_tag_ids=[] 
              tag_name =  ((doc.find(each_field.path+'/articlelink').first.content.split('/') - ["0","",".",".."])[2]).gsub('-',' '){|name| name}.strip
              find_tag = @xml_site_id.tags.find(:first,:conditions=>['name =? and entity_type =?',tag_name,"Article"])
              xml_tag_ids << find_tag.id if find_tag
              unless find_tag
                find_tag=Tag.find(:first,:conditions=>['name =? and entity_type =?',tag_name,"Article"])  || find_tag=Tag.create(:name=>tag_name,:entity_type=>"Article")
                @xml_site_id.tags << find_tag
                xml_tag_ids << find_tag.id if find_tag        
                XmlMigratedData.create(:model_type => "Tag",:ext_id => old_id,:int_id => find_tag.id,:publication_id => @xml_site_id.id )
              end
           
              article.tag_ids = xml_tag_ids unless xml_tag_ids.blank?
              debugger

            publish_date=doc.find(each_field.path+'/pubdate')
              article.publish_date=(publish_date.first.content.to_s).to_time.strftime("%d-%m-%Y %H:%M:%S") if publish_date and publish_date.first and not publish_date.first.content.to_s.empty?
           

              if options[:draft_flag]
             article.active =false
             article.is_draft =true
             else
             article.active =true
             article.is_draft =false  
              end
          
            if options[:category_flag]
          
             end    


              if article.save
              debugger  
                XmlMigratedData.create(:model_type => "Article",:ext_id => old_id,:int_id => article.id,:publication_id => @xml_site_id.id,:old_url_part=>"",:previous_id=>"",:old_urls=>old_url)  
                
                puts "article successfully save --->#{article.id}"
                logger.info("article successfully save --->#{article.id}")
              else
                logger.info("article not successfully save --->#{file_path.split('/').last}")
              end
            else
              puts "article id found--------->Int =  #{find_id.int_id}" 
            end
            
          end
        else
          logger.info("Site Short name not matched on xml file --> #{file_path.split('/').last}")
          
          puts "Site Short name not matched on xml file --> #{file_path.split('/').last}"
        end
      end
    end
    
   
end
