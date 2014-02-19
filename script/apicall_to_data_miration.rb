# encoding: utf-8
require "rubygems"
require "ruby-debug"
# rails r ApicallToMirationmethodForExport.article_export
class ApicallToDataMiration
  
  
 def self.export
    SeperateExportScript.generate_xml(Site.find_by_name("staging-itnext.kreatio.com"),
    params = { :menus => "menus"   , :sources => "sources"  , :sections => "sections"  , :properties => "properties"  , :categories => "categories"  , :pages => "pages"  , :data_lists => "data_lists"  , :authors => "authors"  ,  :containers => "containers"  ,  :ranklists => "ranklists" },
    "Api_Export")

  end

 def self.article_export
    ActualDataExport.generate_xml(Site.find_by_name("staging-itnext.kreatio.com"),
    params = {:action => "export_entire_data" },
    "Api_Data_Export")
  end

 
 def self.import
    SeperateImportScript.create(Site.find_by_name("demo-krmedia.kreatio.com"),
    params = { :ranklists => "ranklists" },
    #:menus => "menus"   , :sources => "sources"  , :sections => "sections"  , :properties => "properties"  , :categories => "categories"  , :pages => "pages"  , :data_lists => "data_lists"  , :authors => "authors"  ,  :containers => "containers"  ,  :ranklists => "ranklists" },
    "Api_Export")
  end

 def self.article_import
    @site = Site.find 1
    ImportEntireStaticArticles.migrate("#{Rails.root}/public/DataImport/#{@site.short_name}/#{Date.today.to_s}/Api_Data_Export/EntireData/XmlFolder/",
    { :check_old_articles=>true,
      :imageset_binary_path=>["#{Rails.root}/public/DataImport/#{@site.short_name}/#{Date.today.to_s}/Api_Data_Export/EntireData/IMG/"],
      :video_binary_path=>["#{Rails.root}/public/DataImport/#{@site.short_name}/#{Date.today.to_s}/Api_Data_Exporti/EntireData/XmlFolder/"],
      :inline_asset_path =>{"/IMG"=>"#{Rails.root}/public/DataImport/#{@site.short_name}/#{Date.today.to_s}/Api_Data_Export/EntireData/IMG/"},
      :site_short_name=>"#{@site.short_name}",
      :asset_flag=>true, # false means unpublish mode
      :draft_flag => "true",
      :old_url_mapping =>true,

    })
  end



# rails r ApicallToDataMiration.process_of_articleexport_to_ftpserver\(\"kreatio_demo\",\"192.168.47.200\",\"ftpuser\",\"ftpuser123\"\)
  def self.process_of_articleexport_to_ftpserver(short_name, ip, user, password)
    logger = Logger.new("#{Rails.root}/log/#{short_name}_daily_export.log")
    logger.info("#{short_name} :)--> Process starting time: #{Time.now.strftime("%d-%m-%Y %H:%M:%S")}")
    complite = ActualDataExport.generate_xml(Site.find_by_short_name(short_name),
    params = {:action => "daily_Published_data"},
    "DailyPublishedData")
    if complite[0] > 0
      logger.info("Article count => #{complite[0]}")
      #Zip
      before_file = complite[-1] #.split("/").last
      remove_after = false #If true: After created the zip file and remove the orginal dir.
      zip_dir = AutomatingFileUploadAndDownloadFromFtp.zip(before_file, remove_after)
      #FTP Upload
      debugger
      AutomatingFileUploadAndDownloadFromFtp.ftp_upload(zip_dir, "#{(Time.now - 1.days).strftime("%Y-%m-%d")}.zip", ip, user, password)
    else
      logger.info("Article count => 0")
    end
    logger.info("#{short_name} :)--> Process ended time: #{Time.now.strftime("%d-%m-%Y %H:%M:%S")}")
  end
  

# rails r ApicallToDataMiration.process_of_articleimport_from_ftpserver\(\"kreatio_demo\",\"2013-08-20\",\"192.168.47.200\",\"ftpuser\",\"ftpuser123\"\)
    def self.process_of_articleimport_from_ftpserver(short_name,date, ip, user, password)
    #Dowload FTP
    local_dir  = ( FileUtils.mkdir_p "#{Rails.root}/public/DataImport/#{short_name}/" ).first
    AutomatingFileUploadAndDownloadFromFtp.ftp_download("#{date}.zip","#{local_dir}#{date}.zip", ip, user, password)  #("#{(Time.now - 1.days).strftime("%Y-%m-%d")}.zip",)
    #UnZip
    if File.exists?("#{local_dir}#{date}.zip")
      zip = "#{local_dir}#{date}.zip"; unzip_dir = ( FileUtils.mkdir_p "#{local_dir}#{date}" ,:mode => 0777 ).first; remove_after = false #If true: After created the zip file and remove the orginal dir.
            `chmod -R 777 "#{unzip_dir}"`
      AutomatingFileUploadAndDownloadFromFtp.unzip(zip, unzip_dir, remove_after)
      ImportEntireStaticArticles.migrate("#{unzip_dir}",
      { :check_old_articles=>true,
        :imageset_binary_path=>["#{unzip_dir}/IMG/"],
        :video_binary_path=>["#{unzip_dir}"],
        :inline_asset_path =>{"/IMG"=>"#{unzip_dir}/IMG/"},
        :site_short_name=> "#{short_name}",
        :asset_flag=>true, # false means unpublish mode
        :draft_flag => "true",
        :old_url_mapping =>true
      })
    else
      puts "Not exists! #{local_dir}#{date}.zip"
    end
  end


  
  
end
