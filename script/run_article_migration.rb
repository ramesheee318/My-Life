#require 'dbm'
require 'fastercsv'
class RunArticleMigration
  
  def self.parse_source
    SourceMigration.migrate_xml("/home/neetin/Desktop/new_migration_work/unquote_sites/sources.xml") #(file_path)
  end
  
  def self.section_migration
    SectionMigration.migrate("/home/neetin/Desktop/new_migration_work/content-types.xml")
  end
  
  def self.parse_categroy
    CategoryMigration.migrate("/home/neetin/Desktop/new_migration_work/unquote_sites/category-tree-UNQUOTE.xml","unquote") #(file_path,site_short_name)
  end
  
  def self.comment_migration
    CommentMigration.parse_comment("/home/neetin/Desktop/new_migration_work/legalweek/LW-export-text-data-20090424/comments.xml","legalweek") #file_path,site_short_name
  end

  def self.parse_directory_listing_category
    DirectoryListingCategoryMigration.migrate_xml("/opt/ruby/backup/clickz_directory/categories.xml","ireviews") #(file_path)
  end
  
  
  def self.parse_directory_listing_location
    DirectoryListingLocationMigration.migrate_xml("/opt/ruby/backup/clickz_directory/locations.xml") #(file_path)
  end
  
  #"article directory path",
  #{:check_old_articles=>true, #true means check the article_id is there or not
  #:imageset_binary_path=>["image dump path"],
  #:video_binary_path=>["video dump path"],
  #site_short_name,
  #image_set_xml_path,
  #video_assest_xml_path,
  #:category_flag=>nil,#category flag is true if you want to migtarte the category for the articles form xmls (for post,broking,risk,fx-week,hfr no category) 
  #:category_assign_from_autonomy=>{:category_root_name=>"postonline"}, # if want to assign category from autonomy 
  #:asset_flag=>true, # if no assest put nil or false
  #:idx_creation=>nil}) #Want to create idx or not
  
  
 def self.simple_import
  SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/DQWeek",
    { :check_old_articles=> true,
      :imageset_binary_path=>["/home/customer/Cybermedia/CMS/XML/DQWeek/"],
      :inline_asset_path=>{"http://www.dqweek.com/images"=>"/home/customer/Cybermedia/CMS/CMS_Admin/XML/IMG","/images"=>"/home/customer/Cybermedia/CMS/CMS_Admin/XML/IMG"},
      :category_flag=>nil,
      :asset_flag=>false
    })
  end

 def self.import_for_dqc
## SimpleArticleImporti
###   DqcArticleImport
   SimpleArticleImportWithoutOc.from_xml("/home/customer/Cybermedia/CMS/XML/DQC/DQChannel",
    { :check_old_articles=> true,
      :file_name => "DQChannel",
      :imageset_binary_path=>["/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders"],
      :inline_asset_path=>{"../../aug01/html/2010"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2010","../../../dqci2008/oct01/dqchannels%2030sept/html/images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","/2004"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2004","/2007"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2007","2008"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2008","2009"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2009","2010"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2010","2011"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2011","/images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","http://dqchannels.ciol.com/2007"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2007","http://dqchannels.ciol.com/2008"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2008","http://dqchannels.ciol.com/images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","yellowbullet_jun_302k3.gif"=>"/images/annual/yellowbullet_jun_302k3.gif"},
      :category_flag=>nil,
      :asset_flag=>false,
       :site_short_name =>"dqchannels" 
    })
 end



 def self.find_hrml_tag_issue
   OldNewUrl.from_xml("/home/customer/Cybermedia/CMS/XML/DQC/DQChannel",
    { :check_old_articles=> true,
      :file_name => "DQChannel",
      :imageset_binary_path=>["/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders"],
      :inline_asset_path=>{"../../aug01/html/2010"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2010","../../../dqci2008/oct01/dqchannels%2030sept/html/images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","/2004"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2004","/2007"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2007","2008"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2008","2009"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2009","2010"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2010","2011"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2011","/images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","http://dqchannels.ciol.com/2007"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2007","http://dqchannels.ciol.com/2008"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/2008","http://dqchannels.ciol.com/images"=>"/home/customer/Cybermedia/CMS/XML/DQC/All_image_folders/images","yellowbullet_jun_302k3.gif"=>"/images/annual/yellowbullet_jun_302k3.gif"},
      :category_flag=>nil,
      :asset_flag=>false,
       :site_short_name =>"dqchannels"
    })
	
 end


def self.find_hrml_tag_issue_fordataquest
 OldNewUrl.from_xml("/home/customer/Cybermedia/CMS/XML/DQ/DataQuest",
    { :check_old_articles=> true,
      :file_name => "DataQuest",
      :inline_asset_path=>{"/dqtop20/2003/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","/dqtop20/2004" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2004","/dqtop20/2005/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","http://www.dqindia.com/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","http://www.dqindia.com/images06" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images06","http://www.dqindia.com/images07" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images07","http://www.dqindia.com/images08" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images08","../images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","/2004" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2004","/2006" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2006","/2007" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2007","/2010" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2010","/2012" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2012","/2011" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2011","/images04" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images04","/images07" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images07","/images06" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images06","/images010" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images010","/images08" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images08","/images09" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images09","/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images"},
      :category_flag=>nil,
      :asset_flag=>false,
       :site_short_name =>"dataQuest"
    })

end



# RunArticleMigration

 def self.import_for_dq
#   SimpleArticleImport
##   DqcArticleImport
   SimpleArticleImportWithoutOc.from_xml("/home/customer/Cybermedia/CMS/XML/DQ/DataQuest",
    { :check_old_articles=> true,
      :file_name => "DataQuest",
      :inline_asset_path=>{"/dqtop20/2003/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","/dqtop20/2004" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2004","/dqtop20/2005/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","http://www.dqindia.com/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","http://www.dqindia.com/images06" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images06","http://www.dqindia.com/images07" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images07","http://www.dqindia.com/images08" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images08","../images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images","/2004" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2004","/2006" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2006","/2007" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2007","/2010" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2010","/2012" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2012","/2011" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/2011","/images04" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images04","/images07" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images07","/images06" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images06","/images010" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images010","/images08" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images08","/images09" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images09","/images" => "/home/customer/Cybermedia/CMS/XML/DQ/All_image_folders/images"},
      :category_flag=>nil,
      :asset_flag=>false,
       :site_short_name =>"dataQuest"
    })
 end



# RunArticleMigration

 def self.import_for_ciol
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Enterprise",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
       :site_short_name =>"ciol"
    })
 end


  def self.import_for_ciol2
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-News",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-News",
       :site_short_name =>"ciol"
    })
 end



   def self.import_for_ciol3
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Uncategorized",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Uncategorized",
       :site_short_name =>"ciol"
    })
 end


def self.import_for_ciol4
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Storage",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Storage",
       :site_short_name =>"ciol"
    })
 end



   def self.import_for_ciol5
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Semicon",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Semicon",
       :site_short_name =>"ciol"
    })
 end

   def self.import_for_ciol6
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Android",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Android",
       :site_short_name =>"ciol"
    })
 end


def self.import_for_ciol7
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-SMB",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-SMB",
       :site_short_name =>"ciol"
    })
 end


def self.import_for_ciol8
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Security",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Security",
       :site_short_name =>"ciol"
    })
 end


def self.import_for_ciol9
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Cloud and Virtualization",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Cloud\ and\ Virtualization",
       :site_short_name =>"ciol"
    })
 end

def self.import_for_ciol10
    SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Networking",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Networking",
       :site_short_name =>"ciol"
    })
 end


def self.import_for_ciol11
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Developer",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Developer",
       :site_short_name =>"ciol"
    })
 end


   def self.import_for_ciol12
   SimpleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Mobility",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :file_name => "Section-Mobility",
       :site_short_name =>"ciol"
    })
 end


def self.import_for_double
 DoubleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Uncategorized",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :id =>271,
      :asset_flag=>false,
      :site_short_name =>"ciol",
      :file_name => "Section-Uncategorized"
    })
end

def self.import_for_double1
 DoubleArticleImport.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Developer",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :id => 270,  
      :asset_flag=>false,
      :site_short_name =>"ciol",
      :file_name => "Section-Developer"
    })
end




#ArticleLink
 def self.fine_for_articlelink
 ArticleLink.from_xml("/home/customer/Cybermedia/CMS/XML/CIOL/Section-Security",
    { :check_old_articles=> true,
      :inline_asset_path=> "/home/customer/Cybermedia/CMS/XML/CIOL",
      :category_flag=>nil,
      :asset_flag=>false,
      :site_short_name =>"ciol"
      
    })
end


  def self.parse_post_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/fd",
    { :check_old_articles=>nil,
      :imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"postonline",
      :image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/ins/INS-supplementary-20090501/imagesets-POST.xml",
      :video_assest_xml_path=>"/home/neetin/Desktop/new_migration_work/ins/INS-supplementary-20090501/assets-POST.xml",
      :category_flag=>nil,
      :category_assign_from_autonomy=>{:category_root_name=>"postonline"},
      :asset_flag=>true,
      :old_url_mapping=>true,
      :idx_creation=>nil
    })
  end
 
















    # RunArticleMigration
  def self.parse_importforcoverdata
    ImportForCoverData.migrate("/home/ramesh1/Demo/Client/Cybermedia/cybermedia_stg/migreation/Demo/2012-06-13/ARTICLES/XML",
    { :check_old_articles=>true,
      :imageset_binary_path=>["/home/ramesh1/Demo/Client/Cybermedia/cybermedia_stg/migreation/Demo/2012-06-13/ARTICLES"],
      :video_binary_path=>["/home/ramesh1/Demo/Client/Cybermedia/cybermedia_stg/migreation/Demo/2012-06-13/ARTICLES"],
      :inline_asset_path =>{"/IMG"=>"/home/ramesh1/Demo/Client/Cybermedia/cybermedia_stg/migreation/Demo/2012-06-13/ARTICLES/IMG"},
      :site_short_name=>"ramesh",
      :site_based_category_flag=>false,
      :asset_flag=>true,
      :old_url_mapping=>true
    })
  end
  
  
  def self.parse_broking_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/broking",
    {:check_old_articles=>nil,
      :imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"broking",
      :image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/deleta_dump/suplimentry/imagesets-BROKING.xml",
      :video_assest_xml_path=>"/home/neetin/Desktop/new_migration_work/deleta_dump/suplimentry/assets-BROKING.xml",
      :category_flag=>nil,
      :category_assign_from_autonomy=>{:category_root_name=>"Broking"},
      :asset_flag=>true,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_risk_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/risk_mag",
    {:imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>"",
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"risk",
      :image_set_xml_path=>"/media/disk/migration_work/risk_on_apr3/RISK-supplementary-20090403/imagesets-RISK.xml",
      :video_assest_xml_path=>"/media/disk/migration_work/risk_on_apr3/RISK-supplementary-20090403/assets-RISK.xml",
      :category_flag=>nil,
      :category_assign_from_autonomy=>{:category_root_name=>"Risk.net"},
      :asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_hfr_articles
    NewArticleMigration.migrate("/media/disk/migration_work/risk_on_apr3/hfr/hfr-site",
    {:imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>"",
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"hfr",
      :image_set_xml_path=>"/media/disk/migration_work/risk_on_apr3/hfr/HFR-supplementary-20090403/imagesets-HFR.xml",
      :video_assest_xml_path=>"",
      :category_flag=>nil,
      :category_assign_from_autonomy=>{:category_root_name=>"risk"},
      :asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_fxweek_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/new_migration_work/risk_division/fx-week-site/july6/fxweek-site",
    {:imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>"",
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com","/images"=>""},
      :site_short_name=>"fxweek",
      :image_set_xml_path=>"/media/disk/migration_work/risk_on_apr3/fx-week/FXW-supplementary-20090403/imagesets-FXWK.xml",
      :video_assest_xml_path=>"",
      :category_flag=>nil,
      #:category_assign_from_autonomy=>{:category_root_name=>"risk"},
      :asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_mortgage_solution
    NewArticleMigration.migrate("/home/neetin/Desktop/maybe_delete/ms_article/ar",
    {:imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>["/home/neetin/Desktop/maybe_delete/ms_video"],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com","/images"=>""},
      :site_short_name=>"mortgage_solutions",
      :image_set_xml_path=>"/home/neetin/Desktop/maybe_delete/ms_article/sup/imagesets-MS-FULL-20090719.xml",
      :video_assest_xml_path=>"/home/neetin/Desktop/maybe_delete/ms_article/sup/assets-MS-FULL-20090719.xml",
      :category_flag=>nil,
      :asset_flag=>true,
      :old_url_mapping=>nil,
      :idx_creation=>nil})
  end
  
  def self.parse_central_banking_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/new_migration_work/central_banking/jun26/extra_check",
    {:check_old_articles=>nil,
      :imageset_binary_path=>[""],
      :video_binary_path=>[""],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"central_banking",
      :image_set_xml_path=>"",
      :video_assest_xml_path=>"",
      :category_flag=>true,
      :asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_creation=>true})
  end
  
  def self.parse_ifaonline_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/new_migration_work/investment/gr/ifa-site",
    { :imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com","/media/disk/data_dump/www/net/www.incisiverwg.com"],
      :video_binary_path=>["/media/disk/data_dump/www/net/www.incisiverwg.com","/media/disk/data_dump/www/net/db.riskwaters.com"],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"ifaonline",
      :image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/investment/INV-supplementary-20090423/imagesets-IFA.xml",
      :video_assest_xml_path=>"/home/neetin/Desktop/new_migration_work/investment/INV-supplementary-20090423/assets-IFA.xml",
      :author_xml_path =>"/home/neetin/Desktop/new_migration_work/investment/jun12/authors-IFA-FULL-20090607.xml",
      :author_flag => true,
      :category_flag=>true,
      :asset_flag=>true,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_professional_pension_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/new_migration_work/investment/pp-site/professional-pensions",
    { :imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>["/media/disk/data_dump/www/net/www.incisiverwg.com"],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"professional_pensions",
      :image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/investment/INV-supplementary-20090423/imagesets-PP.xml",
      :video_assest_xml_path=>"",
      :category_flag=>true,
      :asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_global_pension_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/new_migration_work/investment/gb-site/global-pensions",
    { :imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>["/media/disk/data_dump/www/net/www.incisiverwg.com"],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"professional_pensions",
      :image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/investment/INV-supplementary-20090423/imagesets-PP.xml",
      :video_assest_xml_path=>"",
      :category_flag=>true,
      :asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_mortgage_solution_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/ms_article",
    { :imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>["/media/disk/data_dump/www/net/www.mortgagesolutions-online.com"],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"mortgage_solutions",
      :image_set_xml_path=>"/home/neetin/Desktop/ms_article/sup/imagesets-MS-FULL-20090719.xml",
      :video_assest_xml_path=>"/home/neetin/Desktop/ms_article/sup/assets-MS-FULL-20090719.xml",
      :category_flag=>true,
      :asset_flag=>true,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  def self.parse_investement_week_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/new_migration_work/investment/investmentweek/inv-week-site/inv_week_articles_media",
    { :imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :video_binary_path=>[""],
      :inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"investmentweek",
      :image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/investment/investmentweek/imagesets-IW-FULL-20090614..xml",
      :video_assest_xml_path=>"",
      :category_flag=>true,
      :asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  #RunArticleMigration
  def self.parse_legalweek_article_lv
    MtArticleMigration.migrate("/home/neetin/Desktop/MTonaug19/lv_article",
    { :inline_asset_path =>{"http://www.legalweekblogs.com"=>"/home/neetin/Desktop/MTonaug19"},
      :site_short_name=>"legalweek",
      :category_flag=>true,
      :old_url_mapping=>true,
      :idx_file_name=>"legal_village",
      :idx_creation=>true
    })
  end
  
  #RunArticleMigration
  def self.parse_legalweek_blog_legalvillage
    MtArticleMigration.migrate("/home/neetin/Desktop/MTonaug19/lv_article",
    { #:imageset_binary_path=>["/media/disk-1/legalweek_imgae_binary_onapr23"],
      #:video_binary_path=>[""],
      :inline_asset_path =>{"http://www.legalweekblogs.com"=>"/home/neetin/Desktop/MTonaug19"},
      :site_short_name=>"legalweek",
      #:image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/legalweek/LW-export-text-data-20090424/imagesets.xml",
      #:video_assest_xml_path=>"",
      :category_flag=>true,
      #:asset_flag=>nil,
      :old_url_mapping=>true,
      :idx_file_name=>"legal_village",
      :idx_creation=>true})
  end
  
  #RunArticleMigration
  def self.parse_incisive_articles
    CorporateArticleMigration.migrate("/home/neetin/Desktop/corportae_aug20/corporate_export/products",
    { :check_old_articles=>nil,
      :imageset_binary_path=>["/home/neetin/Desktop/corportae_aug20/corporate_export/"],
      :video_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      :inline_asset_path =>{"http://db.riskwaters.com/global/corp07/_imgs/"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/",
                           "/images"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/",
                           "http://db.riskwaters.com/data/incisive/branding/buttons/"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/",
                           "http://db.riskwaters.com/data/credit/branding/icons/"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/",
                           "http://db.riskwaters.com/data/incisive/stories/"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/",
                           "http://db.riskwaters.com/data/incisive/images/"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/",
                           "http://db.riskwaters.com/data/incisive/press/"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/",
                           "http://www.incisivemedia.com/images/"=>"/home/neetin/Desktop/corportae_aug20/corporate_export/images/"},
      :site_short_name=>"incisive_media",
      :image_set_xml_path=>"/home/neetin/Desktop/corportae_aug20/corporate_export/imagesets.xml",
      :category_flag=>true,
      :old_url_mapping=>nil,
      :idx_creation=>nil
    })
  end
  
  #RunArticleMigration
  
  def self.parse_unquote_articles
    NewArticleMigration.migrate("/home/neetin/Desktop/new_migration_work/unquote_sites/unquote-site",
    {:check_old_articles=>true, 
      #:imageset_binary_path=>["/media/disk/data_dump/www/net/db.riskwaters.com"],
      #:video_binary_path=>[""],
      #:inline_asset_path =>{"http://db.riskwaters.com"=>"/media/disk/data_dump/www/net/db.riskwaters.com","http://www.incisiverwg.com"=>"/media/disk/data_dump/www/net/www.incisiverwg.com","http://www.incisivemedia.com"=>"/media/disk/data_dump/www/net/www.incisivemedia.com"},
      :site_short_name=>"unquote",
      #:image_set_xml_path=>"/home/neetin/Desktop/new_migration_work/investment/investmentweek/imagesets-IW-FULL-20090614..xml",
      #:video_assest_xml_path=>"",
      :category_flag=>true,
      :asset_flag=>true,
      #:old_url_mapping=>true,
      :idx_creation=>nil})
  end
  
  #RunArticleMigration
  def self.assign_training_articles
    site = Site.find(12)
    ArticleCategorySuggest.asign_training_articles_to_category(site,"Admin","474710921618013901") #site,user_name,category_root_name
  end
  
  def self.create_idx
    IdxCreation.idx_by_site_name("accountancy_age")  #site_short_name
  end
  #RunArticleMigration
  def self.create_url_mapping
    SiteUrlMapping.map_old_new_url("risk")
  end
  
  def self.delete_articles
    DeleteArticles.by_site(site_short_name) #site_short_name
  end
  #RunArticleMigration
  def self.assign_category_basedon_text
    site = Site.find(4)
    ArticleCategorySuggest.by_content_text(site,"Broking") #site,category_root_name
  end
  #RunArticleMigration
  def self.assign_category_basedon_site_categories
    site = Site.find(12)
    ArticleCategorySuggest.by_category_autonomy(site,"474710921618013901") #site,category_root_name
  end
  
  def self.virtualhost
    CreateVhostFile.forsite("broking",
    {:vhost_request=>[{:s_name=>"postmag.co.uk",:s_alais=>"insurancewindow.net",:need_extra_redirets=>"post_mag.txt"},{:s_name=>"reinsurancemagazine.com"},{:s_name=>"re-world.com"}],
      :redirect_to=>"broking.incbase.net",
      :public_path=>"/export/cache/Sites/broking/public",
      :log_creation_path=>"/opt/apache/logs",
      :hardware_balancer=>false,
      :number_of_mongrel_port=>10,
      :starting_port=>5000,
      :mongrel_server_ip=>"62.140.213.235",
      :legacy_url_mapping=>false
    })
  end
  #RunArticleMigration
  
  def self.virtualhost_creation
    CreateVhostFile.for_site("risk",
    {:vhost_request=>[{:s_name=>"asiarisk.com.hk",:s_alais=>["asiarisk.hk","asiarisk.com.hk"],:need_extra_redirets=>"asia_risk.txt"}],
      #      {:s_name=>"creditmag.com",:s_alais=>["credit-markets.com","mortgageriskmagazine.com","creditamericas.com","creditnews-us.com","uscreditmag.com"],:need_extra_redirets=>"credit_rewrite.txt"},
      #      {:s_name=>"energyrisk.com",:s_alais=>["eprm.com","eprmonline.com"],:need_extra_redirets=>"energy_risk.txt"},
      #      {:s_name=>"life-pensions.com",:s_alais=>["lifeandpensions.com","blog.life-pensions.com"],:need_extra_redirets=>"life_pensions_risk.txt"},
      #      {:s_name=>"opriskandcompliance.com",:s_alais=>["opriskandcompliance.com","baselalert.com","baselalert.org"],:need_extra_redirets=>"OP_risk.txt"},
      #      {:s_name=>"structuredproductsonline.com",:s_alais=>["structurednotes.co.uk"],:need_extra_redirets=>"structured_products"},
      #      {:s_name=>"risk.co.uk",:s_alais=>["blog.risk.net","risknews.net","risk-news.com"],:need_extra_redirets=>"Risk_redirects"}],
      #:redirect_to=>"risk.net",
      :public_path=>"/home/bala",
      :log_creation_path=>"/home/neetin/logs",
      :extra_redirects_file_name=>"risk_extra_redirects.txt",
      :hardware_balancer=>false,
      :software_balancer=>false,
      :software_balancer_name=>"mongrel_cluster_sites",
      :inline_mongrel_cluster=>true,
      :inline_mongrel_cluster_access_name=>"mongrel_cluster",
      :number_of_mongrel_port=>30,
      :starting_port=>5000,
      :mongrel_server_ip=>"127.0.0.1",
      :etag_switch_off=>false,
      :header_expiry=>false,
      :legacy_url_mapping=>true,
      :legacy_url_mapping_name=>["first","second","third"],
      :rewrite_query_string => [{:query_string_pattern=> "^page=323598&gclid=.*",
        :redirect_rule=> { "/public/showPage.html" => "/static/risk-magazine-subscribe?"}}],
      :rewrite_binary_dump=>"RewriteCond  %{DOCUMENT_ROOT}/old_binary_dump/from_241/www/net/db.riskwaters.com/%{REQUEST_FILENAME} -f
        RewriteRule  ^(.*)$ /old_binary_dump/from_241/www/net/db.riskwaters.com/%{REQUEST_FILENAME} [L]
        RewriteCond  %{DOCUMENT_ROOT}/old_binary_dump/from_241/www/net/www.incisivemedia.com/%{REQUEST_FILENAME} -f
        RewriteRule  ^(.*)$ /old_binary_dump/from_241/www/net/www.incisivemedia.com/%{REQUEST_FILENAME} [L]"  
    })
  end
  
  def self.brokenlink
    BrokenLinksChecker.for_site("risk","/home/neetin/Desktop/risk_access.log")
  end
  
  def self.tag_import
    site = Site.find(7)
    file= File.new("#{RAILS_ROOT}/tmp/risk_tag_list.csv","w")
    site.tags.each do |t| 
      file.puts("#{t.name}-->#{t.articles.count}")
    end
    file.close
  end
  
  #RunArticleMigration
  def self.assign_latest_issue
    sites = Site.find(:all)
    for site in sites
      sources = site.sources.find(:all)
      for source in sources
        magazine_issue= source.magazine_issues.find(:first,:order=>"date_of_publication desc")
        if magazine_issue
          articles_count= site.articles.find_all_by_magazine_issue_id(magazine_issue.id).size
          if articles_count and articles_count > 0
            if source.current_issue_id!=magazine_issue.id
              source.update_attributes(:current_issue_id=>magazine_issue.id)
              puts "source update id -->#{source.id}-->with magazine issue_id-->#{magazine_issue.id}"
            else
              puts "source id is same as current id for-->#{source.name}-->with magazine issue_id-->#{magazine_issue.id}"
            end
          end
        else
          puts "magazine_issue not found for source is -->#{source.id}"
        end
      end
    end
  end
  
  #RunArticleMigration
  def self.delete_cache_files
    site_name=["postonline","broking"]
    DeleteSiteCache.delete_cache(site_name)
  end
  # RunArticleMigration
  def self.dbm_read
    File.open('/home/neetin/new_workspace/CMS/tmp/url_mapping_for_central_banking_2009-09-02.txt', 'r') do |f1|  
      while line = f1.gets  
        debugger 
        puts line
      end  
    end  
  end
  
  def self.import_source_new
    SourceNewImport.migrate("/home/neetin/Desktop/new_migration_work/unquote_sites/sources.xml",{})
  end

   def self.create_idx_blog
    IdxCreation.idx_by_blog_alias_name("dave-the-dealer-blog") #(blog alias_name)
   end

   def self.blog_create_url_mapping
      SiteUrlMapping.blog_map_old_new_url("leadership-strategy-blog") #(blog alias_name)
   end

# RunArticleMigration
def self.update_highlight_value
  @site = Site.find_by_short_name('incisive_corporate')
  puts @site.short_name
 ## @article = @site.articles
  ## puts @article.count

 @article =[2700384, 2700350, 3006088, 3006089, 3006091, 3006092, 2700436, 3006094, 3006095, 3006090, 3006093, 2700493, 3006098, 3006097, 3006096, 2700435, 2500001, 2700466, 2700326]  
for aa in @article
##  for article in  @article    
  article =  @site.articles.find(aa)
   puts "Article = #{article.id}"
 
    #puts "AC = #{article.article_contents.first.article_id}"      
  if article.published_version_id || article.latest_version_id
      article_content = article.article_contents.find(article.published_version_id || article.latest_version_id)
 
      highlited_full_value = Util.highlighted_summary_text(article_content)
      #puts highlited_full_value
      #article_content.update_attributes(:text_for_highlighting=>'#{highlited_full_value}')
       ArticleContent.update_all({:text_for_highlighting=> highlited_full_value}, {:id => article_content.id}) 
      puts "Updated Article content === #{article_content.id}"
      end    
  end
end

# RunArticleMigration

  def self.ip_access_data_dump
    FasterCSV.open("/opt/ruby/ip_access_data_dump.csv", "w") do |csv|
      @subscriber = SubscriberInstitution.find(:all, :page=>{:size=>100,:auto=>true})
      csv << ["Id", "First Name", "Last Name", "Email Id", "Start Ip", "End Ip", "Subscription Name", "Subscription Type", "Start Date", "End Date"]
      for subscriber in @subscriber
        puts subscriber.first_name
        csv << [subscriber.id,
                subscriber.first_name,
                subscriber.last_name,
                subscriber.email_id]
        subscriber.ipaddresses.collect do |ip_address|
          csv << [" ", " ", " ", " ",
                  ip_address.start_ip,
                  ip_address.end_ip]
        end
        subscriber.subscriptions.collect do |subscription|
          csv << [" ", " ", " " , " ", " ", " ",
                  subscription.name,
                  subscription.subscription_type,
                  subscription.start_date,
                  subscription.end_date]
        end
      end
    end
  end

#  def self.site_author_list
#    logger = Logger.new("#{RAILS_ROOT}/log/site_author_list.log")
#    FasterCSV.open("/opt/ruby/site_author_list.csv", "w") do |csv|
#      sites = Site.all
#      sites.collect do |site|
#        site_author_ids = site.author_ids
#        articles = site.articles.find(:page => {:size => 100, :auto => true})
#        articles.collect do |article|
#          article.authors.collect do |author|
#            if site_author_ids.include(author.id)
#              logger.error("#{author.id}, #{author.email}, yes")
#              puts "available"
#              #csv << [author.id, author.email, "yes"]
#            else
#              puts "not available"
#              logger.error("#{author.id}, #{author.email}, no")
#              csv << [author.id, author.email, "no"]
#            end
#          end
#        end
#      end
#    end
#  end

  def self.site_author_list
    FasterCSV.open("/opt/ruby/site_author_list.csv", "w") do |csv|
      csv << ["Site Id", "Author Id"]
      sites = Site.all
      sites.collect do |site|
        authors = ArticleAuthor.find_by_sql("select author_id,count(article_id) from article_authors where article_id in (select article_id from articles_sites where data_proxy_id =#{site.data_proxy_id}) and author_id not in (select author_id from authors_sites where site_id=#{site.id}) group by author_id")
        authors.collect do |author|
          csv << [site.id, author.author_id]
        end
      end
    end
  end

  def self.assign_authors_to_sites
    logger = Logger.new("#{RAILS_ROOT}/log/site_author_assign.log")
    Ambient.init
    f = File.open("/opt/ruby/site_author_list.csv", "r")
    f.lines.each do |line|
      begin
      row = line.split(',')
      author = Author.find(row[1])
      Ambient.current_site = Site.find(row[0])
      author.sites << Ambient.current_site
      logger.error("#{Ambient.current_site.id} -----> #{author.id}")
      author.save
      rescue
      end
    end
  end

  def self.remaining_concurrent_login_update
    subscribers = Subscriber.find(:all, :conditions => ["remaining_concurrent_logins is null"], :page=>{:size=>100,:auto=>true})
    for subscriber in subscribers
      puts subscriber.id
      subscriber.remaining_concurrent_logins = 100
      subscriber.save
    end
  end

  def self.fixing_removed_role
    assigned_roles = SiteUserRole.find_all_by_role_id(28)
    assigned_roles.collect do |role|
      puts role.user_id
      role.delete
    end
  end
## ruby script/runner RunArticleMigration.section
 def self.section
   AutomateMigrationScript.for_section({  ##As following we must given to site short name(proxy) 
    :site_short_name => 'ciol',
    :section_name=>'Resource Center',               #compulsory and beginning with capital letter
    :section_alias_name => 'resource-center',              #beginning with small letter
    :entity_type =>'Article',          #compulsory
    :template_id => 1})                 #compulsory)
  end
## ruby script/runner RunArticleMigration.source
 def self.source
  AutomateMigrationScript.for_source({
      :site_short_name => 'biospecindia',
      :name  => 'Biospecindia',
      :alais_name => 'biospecindia'})
 end
     
end

