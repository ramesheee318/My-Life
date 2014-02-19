require 'xml/libxml'
require 'find'
require 'ruby-debug'
require 'open-uri'
require 'net/http'
require 'uri'

class MigrationForRssIdg

    def self.rss_url
      begining("http://rss.idgns.com/news.nsf/rss2idgml")
    end

   def self.begining(url)
     options = {:site_short_name => "idgconnect",:draft_mode => true,:imageset_path => "#{Rails.root}/HttpImage",:section_name => "News"}
     process_log = Logger.new("#{Rails.root}/log/rss_process_result.log")
     FileUtils.rm_r Dir.glob("#{Rails.root}/RssDownload/*") if  Dir.exists?("#{Rails.root}/RssDownload/")
     rss_path = download_rss_file(url)
     if rss_path != nil
      process_log.info("Rss file path #{Rails.root} <===> #{rss_path}")
      rss_doc_reader(rss_path,options,process_log)
     else
      process_log.info("return is nill #{Rails.root}")
     end
   end

   def self.rss_doc_reader(rss_path,options,process_log)
    begin
     doc = XML::Document.file("#{rss_path}")
     doc.find('/rss/channel/item').each do | each_item |
      process_log.info("********************************Begining****#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}******************************************")
      guid_title =  doc.find("#{each_item.path}/guid").first.content
      @xml_site_id = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
      find_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Article","#{guid_title}",@xml_site_id.id])
       if find_id != nil
        process_log.info("article find inside the rss migrated data for ext id #{find_id.ext_id} :: int id #{find_id.int_id}")
       else
        rss_feed_image_chcek(doc,each_item,options,process_log,guid_title) # Only image feed data migrtaion method
        # content_field(doc,each_item,options,process_log,guid_title) # all data migrtaion method
       end
      puts "*******************************END*******************************************"
     end
      rescue => e
       error_log =  Logger.info("#{Rails.root}/log/errors.log")
       puts "#{e.backtrace}"
       error_log.info("error message in xml parsing for file---->#{e.to_s}")  
       error_log.info("error in xml parsing for file---->#{file_path}-->#{e.backtrace}")  
     end 
  end
 
  def self.rss_feed_image_chcek(doc,each_item,options,process_log,guid_title)
      url_link = doc.find("#{each_item.path}/link").first.content
        if url_link.blank? #----->
        puts "Link Blank  !"
        else
        rss_content_path = download_rss_file(url_link)
        item_content = XML::Document.file("#{rss_content_path}")
        item_content.find('/idgml/contentpackage/contentitem').each do | each_field |   #1#
              if !item_content.find("#{each_field.path}/contentmetadata/relation/references").blank?
                if !item_content.find("#{each_field.path}/contentmetadata/relation/references/mediaref").blank?
                 if !item_content.find("#{each_field.path}/contentmetadata/relation/references/mediaref").first['source'].blank?
                 puts "Image Feed allow"
                 content_field(doc,each_item,options,process_log,guid_title)
                   end
                end
               end
            end
         end
    end

  def self.content_field(doc,each_item,options,process_log,guid_title)
  puts "ss"
    article = Article.new()
    # Title
    title = doc.find("#{each_item.path}/title").first.content rescue ""
    article.title = title.strip if title 
    process_log.info("Title:--> #{title}")
    puts "Title:--> #{title}"
    # Language
    if !doc.find("#{each_item.path}/language").blank?
      xml_language = doc.find('/article/language').first.content
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

    #Summary
    summary = doc.find("#{each_item.path}/description").first
    article.description = summary.first.content.to_s if !summary.first.blank?
    # Site
    site = Site.find(:first,:conditions=>['short_name=?',options[:site_short_name]])
    Time.zone = "New Delhi"
    article.sites = [site]

    # Source
    if !(source = site.sources.first).blank?
      source.data_proxy_ids = source.data_proxy_ids + [site.data_proxy_id] unless source.data_proxy_ids.include?(site.data_proxy_id)
    else
      source = Source.create(:name => options[:source_name])
      source.data_proxy_ids = source.data_proxy_ids + [site.data_proxy_id]
      process_log.info("Created the new Source -#{source.name}")
    end
    article.source_id = source.id if !source.blank?

    #Section
    section = site.sections.find_by_name(options[:section_name])
    article.section_id = section.id

   ###### Link Means Content field xml
    puts  doc.find("#{each_item.path}/link").first.content
    # Link
    url_link = doc.find("#{each_item.path}/link").first.content
     if url_link.blank? #----->
        puts "Link Blank  !"
        else
       rss_content_path = download_rss_file(url_link)
       item_content = XML::Document.file("#{rss_content_path}")
       item_content.find('/idgml/contentpackage/contentitem').each do | each_field |   #1#
      if !item_content.find("#{each_field.path}/contentmetadata/classification/keyword").blank?
         xml_tag_ids=[]
         item_content.find("#{each_field.path}/contentmetadata/classification/keyword").each do | each_tag |
         puts "#{each_tag.content}"
         find_tag = site.tags.find_by_name(each_tag.content.to_s)
       if !find_tag.blank?
            process_log.info("Tag already there in db -> #{each_tag.content}")
         xml_tag_ids << find_tag.id
        else
        find_tag=Tag.create(:name=> each_tag.content.to_s,:entity_type=>"Article")
        process_log.info("New Tag craeted  -> #{each_tag.content}")
        site.tags << find_tag
        xml_tag_ids << find_tag.id if find_tag        
        XmlMigratedData.create(:model_type => "Tag",:ext_id => "#{guid_title}",:int_id => find_tag.id,:publication_id => site.id )
       end
      end
           article.tag_ids = xml_tag_ids.uniq unless xml_tag_ids.blank?
       else    
         process_log.info("No Tag in Title: #{title}")
      end        
         puts "classification/keyword"
 
 
        puts "Author Alias Name"  
        if !(author_alias = item_content.find("#{each_field.path}/head/byline").first).blank?
          article.author_alias = author_alias.content if !author_alias.content.blank?
        end
     
           puts "Sub Tilte"
        if !(sub_title = item_content.find("#{each_field.path}/head/headline/hl2").first).blank?
          article.sub_title = sub_title.content if !sub_title.content.blank?
        end

        puts "Author"
        article.author_ids = [457]   
       # if !doc.find("#{each_item.path}/idgnsrss:creator").blank?
       #  doc.find("#{each_item.path}/idgnsrss:creator").each do |node|
       #  end
       #end 
        
           # Body
           contents_new = []
            if !item_content.find("#{each_field.path}/body").blank?
             item_content.find("#{each_field.path}/body").each do | each_page |
              contents_new <<  each_page
             end
              
            if !contents_new.blank?
             new_con = contents_new.join("<p><!-- pagebreak --></p>") #.gsub(/&lt;/,"<").gsub(/&gt;/,">")
             article.content = new_con.gsub(/<body>|<\/body>/,"").strip
            else
             process_log.info("Content Blank! in xml for file path #{title}")#
             puts "Content Blank! in xml for file path #{title}"
             article.content = "Content Blank ......!"
           end
         else
          process_log.info("Content Blank! in xml for file path #{title}")
          puts "Content Blank! in xml for file path #{title}"
          article.content = "Content Blank ......!"
         end
             
           puts "---> Title Image"
           title_image = []
           
            if !item_content.find("#{each_field.path}/contentmetadata/relation/references").blank?
              item_content.find("#{each_field.path}/contentmetadata/relation/references/mediaref").each do | each_image |
              title_image <<  each_image['source']
              end
             if !(imageset_id = title_image[0]).blank?
              puts "imageset find with id------------->#{imageset_id}"
              migrated_image_id = XmlMigratedData.find(:first,:conditions=>["model_type=? and ext_id=? and publication_id=?","Image","#{imageset_id.split('/').last}",site.id])
              if !migrated_image_id        
                file_full_path = image_fatched_from_http(imageset_id,options)
                   if file_full_path != nil
                  file_new = File.new("#{file_full_path}")
                  @flag ="read"
                  image_name = file_full_path.split("/").last
                  if image_name=~/\.([^\.]+)$/
                    image = Image.image_migration(file_new,Array(image_name),alt="",@flag,extra_info="",caption="",title="",site.id)
                  else
                    mimetype = `file -ib "#{file_full_path}"`.gsub(/\n/,"")
                    full_file_name = "#{image_name}.#{mimetype.split('/').last}"
                    puts "file full path after mime type --------------------------------------->convertion ----------------->#{full_file_name}"
                    image=Image.image_migration(file_new,Array(full_file_name),alt="",@flag,extra_info="",caption="",title="",site.id)
                  end
                  if image
                    puts "image saved with id inside the imageset or gallery---------------------->#{image.id}"
                    XmlMigratedData.create(:model_type => "Image",:ext_id =>imageset_id,:int_id => image.id,:publication_id =>site.id)
                    #return image
                  else
                    process_log.info("Validation errors images #{image.errors.full_messages.join(", ")}") if image
                    process_log.info("error in image saved imageset --> #{title}")
                    return nil
                  end
                else

                  puts "file not found ---->"
                  process_log.info("file not found --> #{title}")
                  #return nil
                end
              else

                image= Image.find(migrated_image_id.int_id)
                puts "------old image found id image set ------>#{image.id}" if image
              end
              article.image = ImageProperty.new(:image_id=>image.id,:alt_tag=>image.alt_tag) if image
            end
             else
               puts "Title image is blank? #{title}"
             end 

        end #1#
     end #----->
     
       puts " -----8"
        publish_date  = doc.find("#{each_item.path}/pubDate")
        article.publish_date = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.display_date = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.created_at = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
        article.updated_at = (publish_date.first.content.to_s).to_time.strftime("%Y-%m-%d %H:%M:%S") if !publish_date.blank? && !publish_date.first.blank? &&  !publish_date.first.content.to_s.blank?
       
 
      if options[:draft_mode]
          article.active =true
          article.is_draft =false  
        else
          article.active =false
          article.is_draft =true
        end
          article.format = "html"
        if article.save(:validate => false)
           puts "article saved with id -->#{article.id}"
          process_log.info("article saved with id -->#{article.id}")
          XmlMigratedData.create(:model_type => "Article",:ext_id => "#{guid_title}",:int_id => article.id,:publication_id => site.id,:article_last_modify_date =>"",:old_url_part=>"",:previous_id=>"")
process_log.info("Xml Data Migration :ext_id => #{guid_title},:int_id => #{article.id}")

             mapping_cat = {"Business Issues"=>"Business Management","Business Issues/Financial results"=>"Accounting and Finance","Business Issues/Investments"=>"Accounting and Finance","Business Issues/Layoffs"=>"Human Resources","Business Issues/Personnel"=>"Human Resources","Business Issues/Restructuring"=>"Human Resources","Business Issues/SEC Filings"=>"Accounting and Finance","Business Management"=>"Business Management","Business Management/Accounting"=>"Accounting and Finance","Business Management/Auditing"=>"Accounting and Finance","Business Management/Budgeting and forecasting"=>"Budgeting, Planning & Forecasting","Business Management/Capital markets"=>"Accounting and Finance","Business Management/Cash management"=>"Accounting and Finance","Business Management/CFO Careers"=>"Accounting and Finance","Business Management/Corporate social responsibility"=>"Business Management","Business Management/Financial regulation and compliance"=>"Regulatory Compliance","Business Management/Governance"=>"IT Governance","Business Management/Investor relations"=>"Accounting and Finance","Business Management/Mergers and acquisitions"=>"Business Management","Business Management/Reporting"=>"Accounting and Finance","Business Management/Risk management"=>"Risk Management (IT Planning & Management)","Business Management/Tax"=>"Accounting and Finance","Components"=>"IT & Systems Management","Components/Batteries / fuel cells"=>"IT & Systems Management","Components/Boards -- other"=>"Storage & Data Center Solutions","Components/Displays"=>"IT & Systems Management","Components/Graphics boards"=>"IT & Systems Management","Components/Input-Output"=>"IT & Systems Management","Components/Memory"=>"Storage & Data Center Solutions","Components/Motherboards"=>"IT & Systems Management","Components/Processors"=>"Microprocessor","Consumer Electronics"=>"IT & Systems Management","Consumer Electronics/Accessories"=>"IT & Systems Management","Consumer Electronics/Digital camcorders"=>"IT & Systems Management","Consumer Electronics/Digital cameras"=>"IT & Systems Management","Consumer Electronics/E-readers"=>"IT & Systems Management","Consumer Electronics/GPS"=>"IT & Systems Management","Consumer Electronics/Handhelds / PDAs"=>"IT & Systems Management","Consumer Electronics/Media players / recorders"=>"IT & Systems Management","Consumer Electronics/Media players / recorders/Digital video recorders"=>"IT & Systems Management","Consumer Electronics/Media players / recorders/Portable media players"=>"IT & Systems Management","Consumer Electronics/Smartphones"=>"Handheld Devices","Consumer Electronics/Smartphones/Accessories"=>"Handheld Devices","Consumer Electronics/Smartphones/Android"=>"Handheld Devices","Consumer Electronics/Smartphones/BlackBerry"=>"Handheld Devices","Consumer Electronics/Smartphones/iPhone"=>"Handheld Devices","Consumer Electronics/Smartphones/Smartphone Applications"=>"Handheld Devices","Consumer Electronics/TVs"=>"IT & Systems Management","Distribution"=>"IT & Systems Management","Entertainment"=>"IT & Systems Management","Environment"=>"Green Business","Environment/Electronics manufacturing"=>"Manufacturing and Process Management","Environment/Electronics recycling"=>"Green Business","Environment/Green data center"=>"Data Center (Green Business)","Environment/Health and safety"=>"Green Business","Games"=>"IT & Systems Management","Games/Game platforms"=>"IT & Systems Management","Games/Game platforms/PS2"=>"IT & Systems Management","Games/Game platforms/PS3"=>"IT & Systems Management","Games/Game platforms/Wii"=>"IT & Systems Management","Games/Game platforms/Xbox"=>"IT & Systems Management","Games/Game platforms/Xbox360"=>"IT & Systems Management","Games/Game Software"=>"IT & Systems Management","Games/Gaming Peripherals"=>"IT & Systems Management","Games/Handhelds"=>"IT & Systems Management","Games/Handhelds/Game Boy Advance"=>"IT & Systems Management","Games/Handhelds/Nintendo DS"=>"IT & Systems Management","Games/Handhelds/PSP"=>"IT & Systems Management","Games/Mobile Games"=>"IT & Systems Management","Games/Online Services"=>"IT & Systems Management","Games/PC-based Games"=>"IT & Systems Management","Government"=>"Business Management","Government/E-Government"=>"Business Management","Government/E-voting"=>"Business Management","Government/Government use of IT"=>"Business Management","Government/Legislation"=>"Business Management","Government/Regulation"=>"Business Management","Government/Trade"=>"Business Management","Hardware Systems"=>"IT & Systems Management","Hardware Systems/Configuration / maintenance"=>"Configuration Management","Hardware Systems/Desktop PCs"=>"Desktop Management","Hardware Systems/Desktop PCs/Mac desktops"=>"Desktop Management","Hardware Systems/Desktop PCs/Windows desktops"=>"Desktop Management","Hardware Systems/High performance"=>"IT & Systems Management","Hardware Systems/High performance/Clusters"=>"Clustering","Hardware Systems/High performance/Supercomputers"=>"IT & Systems Management","Hardware Systems/Laptops"=>"Laptops/Notebooks","Hardware Systems/Laptops/Mac laptops"=>"Laptops/Notebooks","Hardware Systems/Laptops/Netbooks"=>"Laptops/Notebooks","Hardware Systems/Laptops/Windows laptops"=>"Laptops/Notebooks","Hardware Systems/Servers"=>"Servers ","Hardware Systems/Servers/Blades"=>"Blade Servers","Hardware Systems/Servers/High-end servers"=>"Servers ","Hardware Systems/Servers/Low-end servers"=>"Servers ","Hardware Systems/Servers/Mainframes"=>"Mainframe Servers","Hardware Systems/Servers/Midrange"=>"Midrange Servers","Hardware Systems/Tablets"=>"Handheld Devices","Hardware Systems/Tablets/Android tablets"=>"Handheld Devices","Hardware Systems/Tablets/iPad"=>"Handheld Devices","Hardware Systems/Tablets/Tablet Accessories"=>"Handheld Devices","Industry Verticals"=>"Business Management","Industry Verticals/Agriculture"=>"Business Management","Industry Verticals/Automotive"=>"Business Management","Industry Verticals/Education"=>"Business Management","Industry Verticals/Energy"=>"Business Management","Industry Verticals/Finance"=>"Financial Management Solutions","Industry Verticals/Health care"=>"Healthcare","Industry Verticals/Manufacturing"=>"Manufacturing and Process Management","Industry Verticals/Marketing"=>"Business Management","Industry Verticals/Public utilities"=>"Business Management","Industry Verticals/Real estate"=>"Business Management","Industry Verticals/Retail"=>"Business Management","Industry Verticals/Transportation"=>"Business Management","Internet"=>"Internet","Internet/Advertising"=>"Business Management","Internet/Analytics"=>"Analytics Software","Internet/Cloud computing"=>"Cloud Computing","Internet/Cloud computing/Development platforms"=>"Software & Web Development","Internet/Cloud computing/Infrastructure Services"=>"Infrastructure Management","Internet/Cloud computing/Managed Services"=>"Managed Services","Internet/Cloud computing/Software as a service"=>"software as a service","Internet/Cloud computing/Web Services"=>"Web Services","Internet/E-commerce"=>"ecommerce Services","Internet/Internet-based applications and Services"=>"Internet","Internet/Internet-based applications and Services/Instant Messaging"=>"Instant Messaging/IM","Internet/Internet-based applications and Services/Mail"=>"Email Management","Internet/Internet-based applications and Services/Maps"=>"Internet","Internet/Internet-based applications and Services/Music and audio"=>"Internet","Internet/Internet-based applications and Services/Social media"=>"Social Media Marketing","Internet/Internet-based applications and Services/Social Networking"=>"Social Networks","Internet/Internet-based applications and Services/Telephony/conferencing"=>"Web, Video and Audio Conferencing","Internet/Internet-based applications and Services/Video"=>"Web, Video and Audio Conferencing","Internet/Internet service providers"=>"Internet","Internet/Search engines"=>"Search Engines","IT Management"=>"Human Resources","IT Management/Careers"=>"Human Resources","IT Management/CIO role"=>"Human Resources","IT Management/IT strategy"=>"Business Management","IT Management/Regulatory compliance"=>"Regulatory Compliance","IT Management/Staff management"=>"Workforce Planning and Management","IT Management/Training"=>"Training and Development","Legal"=>"Business Management","Legal/Antitrust"=>"Business Management","Legal/Civil lawsuits"=>"Business Management","Legal/Criminal"=>"Business Management","Legal/Cybercrime"=>"Cybercrime","Legal/Intellectual Property"=>"Business Management","Legal/Intellectual Property/Copyright"=>"Business Management","Legal/Intellectual Property/Digital rights management"=>"Business Management","Legal/Intellectual Property/Patent"=>"Business Management","Mobile"=>"Mobile Communications","Mobile/Mobile Applications"=>"Mobile Applications","Mobile/Mobile OSes"=>"Mobile Applications","Mobile/Mobile OSes/Android"=>"Mobile Applications","Mobile/Mobile OSes/BlackBerry OS"=>"Mobile Applications","Mobile/Mobile OSes/Chrome OS"=>"Mobile Applications","Mobile/Mobile OSes/iOS"=>"Mobile Applications","Mobile/Mobile OSes/Windows Phone"=>"Mobile Applications","Networking"=>"Networking & Communications","Networking/Broadband"=>"Networking & Communications","Networking/LAN"=>"LAN","Networking/Management/Access control"=>"Access Control","Networking/Management/Activity management"=>"Business Activity Monitoring (BAM)","Networking/Management/Traffic management"=>"Network Traffic Management","Networking/Networking hardware/Routers"=>"Routers","Networking/Networking hardware/Switches"=>"Switches","Networking/Peer-to-peer"=>"Networking & Communications","Networking/Unified communications"=>"Unified Communications","Networking/VPN"=>"VPN","Networking/Wireless/Bluetooth"=>"Wireless Technologies","Networking/Wireless/Mobile Applications"=>"Mobile Applications","Networking/Wireless/Network infrastructure"=>"Infrastructure Management","Networking/Wireless/RFID"=>"RFID-- Radio Frequency Identification","Networking/Wireless/UWB"=>"Wireless Technologies","Networking/Wireless/WiMax"=>"Wireless Technologies","Networking/Wireless/WLANs / Wi-Fi"=>"Wi-Fi","Peripherals"=>"IT & Systems Management","Peripherals/Adapters and chargers"=>"IT & Systems Management","Peripherals/Headphones and headsets"=>"IT & Systems Management","Peripherals/Input devices"=>"IT & Systems Management","Peripherals/Modems"=>"IT & Systems Management","Peripherals/Monitors"=>"IT & Systems Management","Peripherals/Multifunction devices"=>"IT & Systems Management","Peripherals/Printers"=>"IT & Systems Management","Peripherals/Projectors"=>"IT & Systems Management","Peripherals/Scanners"=>"IT & Systems Management","Peripherals/Speakers"=>"IT & Systems Management","Peripherals/Webcams"=>"IT & Systems Management","Popular Science"=>"IT & Systems Management","Robotics"=>"IT & Systems Management","Security"=>"Security","Security/Access control and authentication"=>"Access Control","Security/Antispam"=>"Anti-Spam","Security/Antivirus"=>"Anti-Virus Solutions","Security/Biometrics"=>"Biometrics","Security/Compliance monitoring"=>"IT Compliance","Security/Data breach"=>"Data Privacy and Security","Security/Data protection"=>"Enterprise Data Protection","Security/Desktop Security"=>"Desktop Management","Security/Encryption"=>"Encryption ","Security/Exploits / vulnerabilities"=>"Threat and Vulnerability Management","Security/Firewalls"=>"Firewalls","Security/Forensics"=>"Security","Security/Fraud"=>"Fraud Detection & Prevention","Security/Identity fraud / theft"=>"Identity Fraud & Theft","Security/Intrusion/Detection / prevention"=>"Intrusion Detection and Prevention","Security/Malware"=>"Malware","Security/Mobile Security"=>"Wireless Security","Security/Online safety"=>"Security","Security/Patch management"=>"Patch Management","Security/Patches"=>"Patch Management","Security/Physical Security"=>"Security","Security/PKI"=>"Encryption ","Security/Privacy"=>"Data Privacy and Security","Security/Scams"=>"Security","Security/Spyware"=>"Anti-Spyware","Services/Application Services"=>"IT Services","Services/Computing Services"=>"IT Services","Services/Hosted"=>"Hosting Services","Services/Integration"=>"IT Services","Services/Outsourcing/Offshoring"=>"Outsourcing","Software"=>"Software & Web Development","Software/Application development/Development tools"=>"Application Development","Software/Application development/Languages and standards"=>"Application Development","Software/Application development/Web services development"=>"Web Services Architecture","Software/Applications/Browsers"=>"Software","Software/Applications/Business intelligence"=>"Business Intelligence","Software/Applications/Business process management"=>"Business Process Management (BPM)","Software/Applications/Collaboration"=>"Project Management And Collaboration","Software/Applications/Content management"=>"Content Management","Software/Applications/Customer relationship management"=>"CRM","Software/Applications/Data management"=>"Master Data Management","Software/Applications/Data mining"=>"Data Mining","Software/Applications/Data protection"=>"Enterprise Data Protection","Software/Applications/Data warehousing"=>"Data Warehousing","Software/Applications/Databases"=>"Databases","Software/Applications/Disaster recovery"=>"Disaster Recovery","Software/Applications/Document management"=>"Document Management","Software/Applications/E-mail"=>"Email Management","Software/Applications/Enterprise resource planning"=>"Enterprise Resource Planning (ERP)","Software/Applications/Financial / tax"=>"Accounting and Finance","Software/Applications/Graphics / multimedia"=>"Software & Web Development","Software/Applications/HR"=>"Human Resources","Software/Applications/Media player Software"=>"Software & Web Development","Software/Applications/Music"=>"Software & Web Development","Software/Applications/Office suites"=>"Software & Web Development","Software/Applications/Online analytical processing"=>"OLAP","Software/Applications/Photo /  video"=>"Web, Video and Audio Conferencing","Software/Applications/Portals"=>"Web Portal Solutions","Software/Applications/Product lifecycle management"=>"Information Lifecycle Management","Software/Applications/Project management"=>"Project Management Solutions","Software/Applications/Security suites"=>"Security","Software/Applications/Speech"=>"Software & Web Development","Software/Applications/Spreadsheets"=>"Software & Web Development","Software/Applications/Supply chain management"=>"Supply Chain Management","Software/Applications/Word processors"=>"Software & Web Development","Software/Architecture/Enterprise architecture"=>"Enterprise Architecture Management (EAM)","Software/Architecture/Event-driven architecture"=>"Enterprise Architecture Management (EAM)","Software/Architecture/Grid computing"=>"Grid Computing","Software/Architecture/SOA"=>"Service Oriented Architecture (SOA)","Software/Architecture/Web-oriented architecture"=>"Service Oriented Architecture (SOA)","Software/Freeware / shareware"=>"Open Source","Software/Installation"=>"Application Deployment","Software/Maintenance"=>"Systems Maintenance","Software/Middleware/Application servers"=>"Application Servers","Software/Middleware/Data integration"=>"Data Integration","Software/Middleware/Enterprise application integration"=>"Enterprise Application Integration Middleware","Software/Middleware/Enterprise service busses"=>"Enterprise Service Business","Software/Open source"=>"Open Source","Software/Operating systems/DOS"=>"Software","Software/Operating systems/Linux"=>"Software","Software/Operating systems/Mac OS"=>"MAC OS","Software/Operating systems/Palm"=>"Software","Software/Operating systems/Symbian"=>"Software","Software/Operating systems/Unix"=>"Software","Software/Operating systems/Windows"=>"Microsoft Windows","Software/Operating systems/Windows/Windows 7"=>"Microsoft Windows","Software/Operating systems/Windows/Windows desktop"=>"Microsoft Windows","Software/Operating systems/Windows/Windows server"=>"Microsoft Windows","Software/System management"=>"Systems Management Services","Software/Utilities/Backup"=>"Backup Systems and Services","Software/Utilities/Compression"=>"Systems Management Services","Software/Utilities/Defragmentating"=>"Systems Management Services","Software/Utilities/Diagnostics"=>"Systems Management Services","Software/Utilities/Encryption"=>"Encryption","Software/Utilities/System suites"=>"Systems Management Services","Software/Utilities/Tracking / antitracking"=>"Systems Management Services","Software/Utilities/Tune-up / optimization"=>"Systems Management Services","Software/Voice recognition"=>"Networking & Communications","Software/Web servers"=>"Web Servers","Storage"=>"Storage & Data Center Solutions","Storage/Drives/HDD"=>"Storage Hardware","Storage/Drives/SSD"=>"Storage Hardware","Storage/Network-attached Storage"=>"Network Attached Storage (NAS)","Storage/Personal storage Peripherals"=>"Storage & Data Center Solutions","Storage/Storage Management"=>"Storage Management","Storage/Storage servers"=>"Servers ","Storage/Tape Storage"=>"Tape Drives and Libraries","Telecommunication"=>"Networking & Communications","Telecommunication/3G"=>"Networking & Communications","Telecommunication/4G"=>"Networking & Communications","Telecommunication/Broadband/Cable modem"=>"Networking & Communications","Telecommunication/Broadband/DSL"=>"Networking & Communications","Telecommunication/Broadband/Powerline broadband"=>"Networking & Communications","Telecommunication/Carriers"=>"Networking & Communications","Telecommunication/Satellite"=>"Networking & Communications","Telecommunication/Telephony"=>"Networking & Communications","Telecommunication/VoIP"=>"VoIP","Virtualization"=>"Virtualization","Virtualization/Application Virtualization"=>"Virtualization","Virtualization/Desktop Virtualization"=>"Desktop Virtualization","Virtualization/Server Virtualization"=>"Server Virtualization","Virtualization/Storage Virtualization"=>"Storage Virtualization"}
 
            item_content.find("/idgml/contentpackage/contentitem/contentmetadata/classification/taxonomy").each do | each_cate |
            parent = item_content.find("#{each_cate.path}/taxonomy.source").first.content
            cat_id = []
            item_content.find("#{each_cate.path}/taxonomy.path").each do | each_cate_child |# Cat
            puts "#{each_cate_child.content}"
            if (find_category = mapping_cat["#{each_cate_child.content}"]) # mapping            
            cat_name = find_category #.split("/").join(" >> ")  if find_category
            process_log.info("category found => from xml: #{each_cate_child.content}-  to mapping: #{cat_name}")
            new_cat = WplTaxonomy.find_by_name(cat_name) if cat_name
            if !new_cat
              new_cat = WplTaxonomy.categories.find_by_display_name(cat_name) if cat_name
            end
             if !new_cat.blank?
               puts "Already there for category"   
               cat_id << new_cat.id if new_cat
             else  # mapping
              ##category = WplTaxonomy.create(:parent_id=>0,:name=> cat_name,:display_name => cat_name ,:full_alias_name => cat_name.downcase,:alias_name=> cat_name.downcase)      
              ##category.data_proxy_ids = category.data_proxy_ids + [site.data_proxy_id] unless category.data_proxy_ids.include?(site.data_proxy_id)
             ## cat_id << category.id
              process_log.info("category not in db => from xml: #{each_cate_child.content}-")
              end   # mapping
          
           else
             process_log.info("category not found in mapping file ---->#{each_cate_child.content}  File ==>#{guid_title}")
          end  
        end # Cat
           article.article_contents.last.update_attributes(:wpl_taxonomy_ids => cat_id.uniq) unless cat_id.blank?
       end
     
           #Region
     array_region = []
     hash_region = {"Africa/Middle East" => ["Africa"],"Africa" => ["Africa"],"Antarctica" => ["Global"], "Asia/Pacific" => ["Asia"],"Europe" => ["Europe"],"Latin America" => ["South America"],"North America" => ["North America"]}
           if !item_content.find("/idgml/contentpackage/contentitem/contentmetadata/subject/subjectlocation/location/region").blank? # Region
               item_content.find("/idgml/contentpackage/contentitem/contentmetadata/subject/subjectlocation/location/region").each do | each_region |
                 array_region <<  each_region.content.to_s        
               end
                if array_region[0] != nil
                reg_name = Region.find_by_name("Global")  if array_region.count > 1
                reg_name = Region.find_by_name(hash_region["#{array_region[0]}"].flatten[0]) if reg_name == nil
  article.article_contents.last.update_attributes(:region => "#{reg_name.id}")
                else
                    process_log("Region not found in array --> #{guid_title}")
                end
              else
                  process_log.info("Region not found --> #{guid_title}")
             end # Region
  #Solr Index 
  Ambient.init
  Ambient.current_site = site
  process_log.info("Article index done") if article.index_to_search_engine
  puts "Article index done"
#          process_log.info("article saved with id -->#{article.id}")
#          XmlMigratedData.create(:model_type => "Article",:ext_id => "#{guid_title}",:int_id => article.id,:publication_id => site.id,:article_last_modify_date =>"",:old_url_part=>"",:previous_id=>"")  
        end
    process_log.info("********************************END******************************************")
  end

  def self.download_rss_file(url)
    rss_log = Logger.new("#{Rails.root}/log/rss_download_result.log")
    orginal_rss = url.split('/').last
    if url
      Dir.chdir(FileUtils.mkdir_p("#{Rails.root}/RssDownload").first) if !File.directory?("#{Rails.root}/RssDownload")
      Dir.chdir("#{Rails.root}/RssDownload")
      if !File.exists?("#{Rails.root}/RssDownload/#{orginal_rss}")
        system(`wget wget --http-user connect_appdev  --http-password 'tRatr2' "#{url}"`)
      else
        puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
      end
      rss_path = ("#{Rails.root}/RssDownload/#{orginal_rss}")
      if File.exists?("#{rss_path}")
        rss_log.info("Rss downloaded #{orginal_rss}")
      return rss_path
      else
        rss_log.info("Rss not downloaded #{orginal_rss}")
        return nil
      end
    end
  end


def self.image_fatched_from_http(imgsrc,options)
      data_path = options[:imageset_path]
  log_img = Logger.new("#{Rails.root}/log/image_find_#{Time.now.to_date}.log")
      log_img_err = Logger.new("#{Rails.root}/log/image_does_not_find_#{Time.now.to_date}.log")
  if imgsrc =~ /((http|Http|https|Https):\/\/[a-z0-9_.-i\/].*(.jpg|.jpeg|.png|.gif|.JPG|.JPEG|.PNG|.GIF))/i
   image_full_path = "#{data_path}/" + imgsrc.split('/').last
    Dir.chdir("#{Rails.root}")
    if imgsrc
   image_name=URI.encode(imgsrc.split("/").last)
   url = URI.parse(URI.encode(imgsrc))
   http = Net::HTTP.new(url.host, url.port)
   fetch_file=Net::HTTP.get_response(url)

      if fetch_file.class== Net::HTTPNotFound
        puts "image not found #{url}"
        log_img_err("image not found #{url}")
        return nil
      else
        img_alt = image_name
        (FileUtils.mkdir_p "#{Rails.root}/HttpImage").first
        File.open("#{Rails.root}/HttpImage/#{image_name}", "wb") { |f| f.write(fetch_file.body) }
         log_img.info("Image  exists in HttpImage  #{image_name}")
         puts "Created New Image**************************"
        image_full_path="#{Rails.root}/HttpImage/#{image_name}"
        return image_full_path
      end
    end
  return nil
  end
 end


end

