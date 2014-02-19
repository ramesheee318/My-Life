require 'xml/libxml'
require 'find'
require 'ruby-debug'

class CentralBankingXmlMigration
  
 def self.master_step_by_step
  CentralBankingXmlMigration.country_migration({:site_short_name => "central_banking",:file_path => "/home/rameshs/Task/Central-Banking-XML-files/XML-dir/country_tbl.xml"})
  # CentralBankingXmlMigration.currency_migration({:site_short_name => "",:file_path =>})
  # CentralBankingXmlMigration.monetary_policy_migration({:site_short_name => "",:file_path =>})
  # CentralBankingXmlMigration.region_migration({:site_short_name => "",:file_path =>})
  # CentralBankingXmlMigration.responsibilities_migration({:site_short_name => "",:file_path =>})
  # CentralBankingXmlMigration.services_provided_migration({:site_short_name => "",:file_path =>})
  # CentralBankingXmlMigration.socialmedia_migration({:site_short_name => "",:file_path =>})
  # CentralBankingXmlMigration.timezone_migration({:site_short_name => "",:file_path =>})
  end   
  
  def self.country_migration(options)
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_country_migration_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file(options[:file_path])
    if !doc.root.find('/root/country_tbl').blank? and doc.root.find('/root/country_tbl').each do | each_node |
    if each_node.find_first('country_id') != nil
    old_id  = each_node.find_first('country_id').content rescue nil
    name = each_node.find_first('country_name').content rescue nil
    country = Country.find(:first,:conditions => ["name =?", name])
    unless country.blank?
    debugger
    unless country.old_id.to_s == old_id
    logger.info("Updated existing country name: #{name} ; old_id #{old_id}")  if country.update_attributes(:old_id => old_id)
    end
    else
    debugger
    country = Country.new
    country.region_id  = each_node.find_first('region_id').content rescue nil
    country.country_code  = each_node.find_first('country_code').content rescue nil
    country.name  = name
    country.old_id = old_id
    country.display_order  = each_node.find_first('display_ordr').content rescue nil
    country.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    country.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    country.is_active  = each_node.find_first('is_active').content rescue nil
    debugger
    unless country.save
    logger.info("New Country not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New Country created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end
  end

  def self.currency_migration(options)
    logger = Logger.new(options[:file_path])
    doc = XML::Document.file("/home/rameshs/Task/Central-Banking-XML-files/XML-dir/currency_tbl.xml")
    if !doc.root.find('/root/currency_tbl').blank? and doc.root.find('/root/currency_tbl').each do | each_node |
    if each_node.find_first('currency_id') != nil
    old_id  = each_node.find_first('currency_id').content rescue nil
    name = each_node.find_first('currency_name').content rescue nil
    currency = CurrencyName.find(:first,:conditions => ["name =?", name])
    unless currency.blank?
    debugger
    unless currency.old_id.to_s == old_id
    logger.info("Updated existing currency name: #{name} ; old_id #{old_id}")  if currency.update_attributes(:old_id => old_id)
    end
    else
    debugger
    currency = CurrencyName.new
    currency.currency_code  = each_node.find_first('currency_code').content rescue nil
    currency.name  = name
    currency.old_id = old_id
    currency.sterling_rate = each_node.find_first('sterling_rate').content rescue nil
    currency.ecu_rate = each_node.find_first('ecu_rate').content rescue nil
    currency.month = each_node.find_first('month').content rescue nil
    currency.year = each_node.find_first('year').content rescue nil
    currency.display_order  = each_node.find_first('display_ordr').content rescue nil
    currency.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    currency.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    currency.is_active  = each_node.find_first('is_active').content rescue nil
    debugger
    unless currency.save
    logger.info("New currency not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New currency created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end
  end

  def self.monetary_policy_migration(options)
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_monetary_policy_migration_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file(options[:file_path])
    if !doc.root.find('/root/monetary_policy_tbl').blank? and doc.root.find('/root/monetary_policy_tbl').each do | each_node |
    if each_node.find_first('id') != nil
    old_id  = each_node.find_first('id').content rescue nil
    name = each_node.find_first('monPolicy_name').content rescue nil
    monetary_policy = MonetoryPolicy.find(:first,:conditions => ["name =?", name])
    unless monetary_policy.blank?
    debugger
    unless monetary_policy.old_id.to_s == old_id
    logger.info("Updated existing monetary policy name: #{name} ; old_id #{old_id}")  if monetary_policy.update_attributes(:old_id => old_id)
    end
    else
    debugger
    monetary_policy = MonetoryPolicy.new
    monetary_policy.name  = name
    monetary_policy.old_id = old_id
    monetary_policy.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    monetary_policy.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    debugger
    unless monetary_policy.save
    logger.info("New monetary policy not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New monetary policy created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end
  end

  def self.region_migration(options)
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_region_migration_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file(options[:file_path])
    if !doc.root.find('/root/region_tbl').blank? and doc.root.find('/root/region_tbl').each do | each_node |
    debugger
    if each_node.find_first('region_id') != nil
    old_id  = each_node.find_first('region_id').content rescue nil
    name = each_node.find_first('region_name').content rescue nil
    region = Region.find(:first,:conditions => ["name =?", name])
    unless region.blank?
    debugger
    unless region.old_id.to_s == old_id
    logger.info("Updated existing region name: #{name} ; old_id #{old_id}")  if region.update_attributes(:old_id => old_id)
    end
    else
    debugger
    region = Region.new
    region.code  = each_node.find_first('region_code').content rescue nil
    region.name  = name
    region.old_id = old_id
    region.is_active  = each_node.find_first('is_active').content rescue nil
    region.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    region.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    debugger
    unless region.save
    logger.info("New region not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New region  created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end

  end

  def self.responsibilities_migration(options)
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_responsibilities_migration_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file(options[:file_path])
    if !doc.root.find('/root/responsibilities_tbl').blank? and doc.root.find('/root/responsibilities_tbl').each do | each_node |
    if each_node.find_first('id') != nil
    old_id  = each_node.find_first('id').content rescue nil
    name = each_node.find_first('res_name').content rescue nil
    responsibility = Responsibility.find(:first,:conditions => ["name =?", name])
    unless responsibility.blank?
    unless responsibility.old_id.to_s == old_id
    debugger
    logger.info("Updated existing responsibility name: #{name} ; old_id #{old_id}")  if responsibility.update_attributes(:old_id => old_id)
    end
    else
    debugger
    responsibility = Responsibility.new
    responsibility.res_code  = each_node.find_first('res_code').content rescue nil
    responsibility.name  = name
    responsibility.old_id = old_id
    responsibility.is_active  = each_node.find_first('is_active').content rescue nil
    responsibility.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    responsibility.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    debugger
    unless responsibility.save
    logger.info("New responsibility not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New responsibility created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end
  end

  def self.services_provided_migration(options)
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_services_provided_migration_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file(options[:file_path])
    if !doc.root.find('/root/services_provided_tbl').blank? and doc.root.find('/root/services_provided_tbl').each do | each_node |
    if each_node.find_first('services_id') != nil
    old_id  = each_node.find_first('services_id').content rescue nil
    name = each_node.find_first('sevices_name').content rescue nil
    services_provided = ServiceProvided.find(:first,:conditions => ["name =?", name])
    unless services_provided.blank?
    debugger
    unless services_provided.old_id.to_s == old_id
    logger.info("Updated existing services_provided name: #{name} ; old_id #{old_id}")  if services_provided.update_attributes(:old_id => old_id)
    end
    else
    services_provided = ServiceProvided.new
    services_provided.service_description  = each_node.find_first('services_description').content rescue nil
    services_provided.name  = name
    services_provided.old_id = old_id
    services_provided.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    services_provided.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    debugger
    unless services_provided.save
    logger.info("New services_provided not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New services_provided created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end
  end

  def self.socialmedia_migration(options)
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_socialmedia_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file(options[:file_path])
    if !doc.root.find('/root/socialmedia_tbl').blank? and doc.root.find('/root/socialmedia_tbl').each do | each_node |
    if each_node.find_first('id') != nil
    old_id  = each_node.find_first('id').content rescue nil
    name = each_node.find_first('media_name').content rescue nil
    socialmedia = SocialMedia.find(:first,:conditions => ["name =?", name])
    unless socialmedia.blank?
    debugger
    unless socialmedia.old_id.to_s == old_id
    logger.info("Updated existing socialmedia name: #{name} ; old_id #{old_id}")  if socialmedia.update_attributes(:old_id => old_id)
    end
    else
    debugger
    socialmedia = SocialMedia.new
    socialmedia.name  = name
    socialmedia.old_id = old_id
    socialmedia.is_active  = each_node.find_first('is_active').content rescue nil
    socialmedia.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    socialmedia.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    debugger
    unless socialmedia.save
    logger.info("New socialmedia not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New socialmedia created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end
  end

  def self.timezone_migration(options)
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_timezone_migration_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file(options[:file_path])
    if !doc.root.find('/root/timezone_tbl').blank? and doc.root.find('/root/timezone_tbl').each do | each_node |
    if each_node.find_first('id') != nil
    old_id  = each_node.find_first('id').content rescue nil
    name = each_node.find_first('zone_name').content rescue nil
    time_zone = TimeZone.find(:first,:conditions => ["name =?", name])
    unless time_zone.blank?
    debugger
    unless time_zone.old_id.to_s == old_id
    logger.info("Updated existing timezone name: #{name} ; old_id #{old_id}")  if time_zone.update_attributes(:old_id => old_id)
    end
    else
    debugger
    time_zone = TimeZone.new
    time_zone.zone_code  = each_node.find_first('zone_code').content rescue nil
    time_zone.name  = name
    time_zone.old_id = old_id
    time_zone.created_at  = each_node.find_first('createdon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    time_zone.updated_at  = each_node.find_first('modifiedon').content.to_time.strftime("%d-%m-%Y %H:%M:%S") rescue nil
    debugger
    unless time_zone.save
    logger.info("New timezone not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New timezone created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    end;end
  end


def self.access_level_migration
    doc = XML::Document.file("/home/rameshs/Task/Central-Banking-XML-files/XML-dir/cb_xml_data_27112013/access_level_tbl.xml")
    hash = {}
    if !doc.root.find('/ROOT/row').blank? and doc.root.find('/ROOT/row').each do | each_node |
      each_node.to_a.compact.each do | each_field | 
      value = "#{each_field.content}" rescue nil
      hash["#{each_field["name"]}"] = value
      end
      if hash['access_id'] != nil
    old_id  = hash['access_id']
    name = hash['access_right']
    socialmedia = SocialMedia.find(:first,:conditions => ["name =?", name])
    unless socialmedia.blank?
    debugger
    unless socialmedia.old_id.to_s == old_id
    logger.info("Updated existing socialmedia name: #{name} ; old_id #{old_id}")  if socialmedia.update_attributes(:old_id => old_id)
    end
    else
    debugger
     socialmedia = SocialMedia.create(:name => )
    debugger
    unless socialmedia.save
    logger.info("New socialmedia not created name: #{name} ; old_id #{old_id}")
    else
    logger.info("New socialmedia created name: #{name} ; old_id #{old_id}")
    end
    end
    end
    hash.clear
     end;end
end
  
     

#resource List

end