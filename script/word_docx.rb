require 'rubygems'
require 'ruby-debug'
require 'nokogiri'
#  sudo apt-get install  xsltproc

class WordDocx

 def self.argument_define_portion
 client_dir = "/home/kreatio/IT/"  
 params = { :site_short_name => "itnext",:sectionname => "TBD",:draft_flag => true }
  logger = Logger.new("#{Rails.root}/log/#{params[:site_short_name]}_#{Date.today.to_s}_worddocx.log")
 initial_process( client_dir,params,logger )
 end

 def self.initial_process( client_dir,params,logger )
   global_dir = Dir.glob("#{client_dir}/*") - ['..', '.']
   global_dir.each do | each_dir |
   check_process( each_dir,params,logger )
   end
 end

 def self.check_process( each_dir,params,logger )
  if File.file?(each_dir) and  File.extname(each_dir) == ".docx" # File
    process_of_docx_convert_to_xhtml( each_dir,params,logger )
  elsif File.directory?(each_dir) # dir
    logger.info("\033[02m Each Dir Path:#{each_dir}")
    return initial_process( each_dir,params,logger )
  else
   logger.info("\033[03m (<*> V <*>) File Not Matching File Module .So Please have a look this problem #{each_dir}")
   puts "\033[40m (<*> V <*>) File Not Matching File Module .So Please have a look this problem #{each_dir}"
  end
 end

 
 def self.process_of_docx_convert_to_xhtml( doc_file,params,logger )
#    debugger
    orginal_file_name = doc_file.split('.').first.split(" ").join("").split("/").last
    puts "#{doc_file}"
    tmp_dir = `mktemp -d`
    logger.info("tmp_dir")
    logger.info("unziped") if `unzip "#{doc_file}" -d #{tmp_dir} >/dev/null`
    logger.info("file copied : #{Rails.root}/docx_to_xhtml/kr-docx2html.xslt #{tmp_dir}") if `cp #{Rails.root}/docx_to_xhtml/kr-docx2html.xslt #{tmp_dir}`
    logger.info("file copied : #{Rails.root}/docx_to_xhtml/finish-up.xslt #{tmp_dir}") if `cp #{Rails.root}/docx_to_xhtml/finish-up.xslt #{tmp_dir}`
    `xsltproc #{tmp_dir.sub("\n",'')}/kr-docx2html.xslt #{tmp_dir.sub("\n",'')}/word/document.xml > #{tmp_dir.sub("\n",'')}/stage1.xhtml`
    `xsltproc #{tmp_dir.sub("\n",'')}/finish-up.xslt #{tmp_dir.sub("\n",'')}/stage1.xhtml > #{tmp_dir.sub("\n",'')}/#{orginal_file_name}.xhtml`
    logger.info("xhtml file generated")
    logger.info("#{tmp_dir.sub("\n",'')}/#{orginal_file_name}.xhtml")
#    debugger
    process_of_issue_creation(doc_file,params,logger,"#{tmp_dir.sub("\n",'')}/#{orginal_file_name}.xhtml")
    end

def self.process_of_issue_creation(doc_file,params,logger,xhtml_file)
   mag_obj =  doc_file.split('.').first.split(" ").join("-").split('/')[-2] =~ /Issue-(\d+)-(\D+)-(\d+)/i

   if mag_obj != nil
    publish_date =  $1+" "+$2+" "+ $3
    site = Site.find_by_short_name(params[:site_short_name])
    find_magazine = MagazineIssue.find(:first,:conditions=>["short_name=? and  source_id=?","#{$2} #{$3}",site.source_ids.first])
    find_magazine = MagazineIssue.create( :source_id => site.source_ids.first, :short_name => "#{$2} #{$3}", :description =>"", :date_of_publication => "#{Time.new.to_time.strftime("%d-%m-%Y %H:%M:%S")}", :title => "#{$2} #{$3}") unless !find_magazine.blank?
     if find_magazine == nil
      raise ArgumentError.new("\033[02m Magazine shoult not nill.So please have look .#{doc_file}")
     else
   successfull_migrated_article =  start_of_migration_process(find_magazine,doc_file,site,logger,xhtml_file,publish_date)
      if successfull_migrated_article == "Article not saved"
         
  logger.info("New Article Not sucess fully created -->Magazine Name: #{find_magazine} | Orginal docx path#{doc_file} , xhtml:#{xhtml_file}")
      else
      logger.info("New Article sucess fully created i---> Magazine Name: #{find_magazine} xml_id: #{successfull_migrated_article.ext_id},   Article:#{successfull_migrated_article.int_id} | Orginal docx path#{doc_file} , xhtml:#{xhtml_file}")
      end
     end
   else
     raise "Exit code, Bacause Reg-Express not matching  #{doc_file.split('.').first.split(" ").join("").split('/')[-2]}"
   end    
      
  end



def self.start_of_migration_process(find_magazine,doc_file,params,logger,xhtml_file,publish_date)
 doc = Nokogiri::HTML(open(xhtml_file))
 old_id = doc_file.split('.').first.split(" ").join("").split("/").last 
 Ambient.init
 site = Site.find 19
 Ambient.current_site = site
  find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","MagazineArticle",old_id,site.id])

   if find_id.blank?
   # puts "Article Already there in DB"
   # else
    article = Article.new()
    Time.zone = "New Delhi"
    article.sites = [site]

    #Title
    article.title = doc.xpath("//td")[11].content

    # Source
     article.source_id = site.sources.first.id

    #Section
    article.section_id = 53 # [site.sections.find(53).id]
    article.description = doc.xpath("//td")[13].content
    puts "----->2"
    #Author
     article.author_alias = doc.xpath("//td")[15].content
    puts "----->3"
   #MagazineIssue
    article.magazine_issue_id = find_magazine.id
    #Content
    dup_doc = doc.dup
    logger.info("doc duplicated")
    # removing the first table from the xhtml
    dup_doc.css("table").first.remove
    logger.info("first table temoved")
    # after taking body content, removing starting and ending body tags
    article_content_wo_image = dup_doc.css("body").to_html.gsub!("<body>", "").gsub!("</body>", "")
    logger.info("content gsubed")
    article.content = article_content_wo_image
    if params[:draft_flag]
      article.active =false
      article.is_draft =true
    else
      article.active =true
      article.is_draft =false
    end
        article.format = "html"
    article.display_date = publish_date.to_time.strftime("%d-%m-%Y %H:%M:%S")
    article.publish_date= publish_date.to_time.strftime("%d-%m-%Y %H:%M:%S")
    article.created_at = Time.now.to_time.strftime("%d-%m-%Y %H:%M:%S")
    article.updated_at = Time.now.to_time.strftime("%d-%m-%Y %H:%M:%S")

#debugger
      if article.save(:validate => false)
        logger.info("Article Saved success fully -->id: #{article.id}")
        puts "Article Saved success fully -->id: #{article.id}"
        @xmlmigratedata = XmlMigratedData.create(:model_type => "MagazineArticle",:ext_id => old_id,:int_id => article.id,:publication_id => site.id)
        puts "XmlMigratedData Saved success fully -->id: #{@xmlmigratedata.id}"
        logger.info("XmlMigratedData Saved success fully -->id: #{@xmlmigratedata.id}")
        return @xmlmigratedata
      else
        puts "Article not saved"
         return "Article not saved"
      end
    else
      puts "Old id already there************************8"
     return find_id
    end
end


end




#File.expand_path(each_dir)

#(Dir.entries("/home/rameshs/Client") - ['..', '.']).collect{|aa| File.expand_path(aa)}.collect{|bb| bb if File.extname(bb) == ".docx" }
