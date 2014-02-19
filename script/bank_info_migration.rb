require 'xml/libxml'
require 'find'
require 'ruby-debug'

class BankInfoMigration
  def self.country_method(country_old_id)
    return  Country.find(:first,:conditions => ["old_id =?", country_old_id]).id  rescue nil
  end

  def self.currency_method(currency_old_id)
    return  CurrencyName.find(:first,:conditions => ["old_id =?", currency_old_id]).id rescue nil
  end

  def self.timezone_method(timezone_old_id)
    return TimeZone.find(:first,:conditions => ["old_id =?", timezone_old_id]).id rescue nil
  end

  def self.region_method(region_old_id)
    return  Region.find(:first,:conditions => ["old_id =?", region_old_id]).id rescue nil
  end

  def self.socialmedia_method(socialmedia_old_id)
    return SocialMedia.find(:first,:conditions => ["old_id =?", socialmedia_old_id]).id rescue nil
  end

  def self.contact_detail_method(contact_detail_old_id)
    return ContactDetail.find(:first,:conditions => ["old_id =?", contact_detail_old_id]).id rescue nil
  end

  def self.central_bank_list_method(central_bank_list_old_id)
    return CentralBankList.find(:first,:conditions => ["old_id =?", central_bank_list_old_id]).id rescue nil
  end

  def self.monetory_policy_method(monetory_policy_old_id)
    return MonetoryPolicy.find(:first,:conditions => ["old_id =?", monetory_policy_old_id]).id rescue nil
  end






=begin
def self.socialmedia_method(old_id)
time_zone = TimeZone.find(:first,:conditions => ["name =?", old_id])
unless time_zone == nil
return nil
else
return time_zone.id
end
end
=end

  #### hash = {}
  # doc.root.find('/root/bankinfo/centralbank_bankdetails_tbls/centralbank_bankdetails_tbl').first.each do |aa|
  # hash["#{aa.name}"] = "#{aa.content}"
  # end
  # Methods
  # hash.clear

  #### (CentralBankList.column_names - ["id","","created_by","updated_by"]).collect{|aa| puts "central_bank_list.#{aa} = each_node.#{aa}"}
  #### (CentralBankList.column_names - ["id","","created_by","updated_by"]).collect{|aa| ":#{aa} => hash['']"}
  #### (CentralBankList.column_names - ["id","","created_by","updated_by"]).collect{|aa| puts "central_bank_list.#{aa} = each_node.find_first('').content "}
  def self.migration
    options = {:site_short_name => "test"}
    hash = {}
    site = Site.find 187
    logger = Logger.new("#{RAILS_ROOT}/log/#{options[:site_short_name]}_BankInformation_migration_#{Time.sr_now.to_date}.log")
    doc = XML::Document.file("/home/rameshs/Task/Central-Banking-XML-files/XML-dir/bankinfo.xml")
    if !doc.root.find('/root/bankinfo').blank? and doc.root.find('/root/bankinfo').each do | each_node |
    if each_node.find_first('bank_id') != nil
    old_id  = each_node.find_first('bank_id').content
    bank_name = each_node.find_first('bank_name').content
    central_bank_list =  "" #CentralBankList.find(:first,:conditions => ["name =? and data_proxy_id =?", bank_name,site.data_proxy_id])
    unless central_bank_list.blank?
    debugger
    unless central_bank_list.old_id.to_s == old_id
    logger.info("Updated existing country name: #{bank_name} ; old_id #{old_id}")  if central_bank_list.update_attributes(:old_id => old_id)
    end
    else
    each_node.to_a.first(72).compact.each do | first_72_fields |
    value = "#{first_72_fields.content}" rescue nil
    hash["#{first_72_fields.name}"] = value
    end
    central_bank_list =  CentralBankList.create(:name => hash['bank_name'], :short_name => hash['local_name'], :premium => hash[''], :status => hash['qcstatus'], :action => hash['is_active'], :office_hours => hash[''] , :time_zone => hash[''], :name_of_currency => hash[''], :name_and_number_of_subdenomination => hash['number_of_subdenomination'], :history => hash['brief_history'], :date_of_establishment => hash['dateOfEstab'], :image_id => hash[''], :directory_id => site.id, :data_proxy_id => site.id, :contact_detail_id => hash[''], :created_at => hash['createdon'], :updated_at => hash['modifiedon'], :url => hash[''], :currency_name_id => currency_method(hash['currency_id'])  , :time_zone_id => timezone_method(hash['timezone_id']) , :social_media_id => hash[''], :notes => hash[''], :old_id => hash['bank_id'], :number_of_subdenomination => hash['number_of_subdenomination'])
    unless central_bank_list.id != nil
    logger.info("New CentralBankList not created name: #{bank_name} ; old_id #{old_id}")
    else
    logger.info("New CentralBankList created name: #{bank_name} ; old_id #{old_id}")
    contact_detail = ContactDetail.create(:entity_id => central_bank_list.id, :phone_number => hash['phone'] , :fax_number => hash['fax'] , :name => hash[''], :email => hash['email'] , :entity_type => central_bank_list.class.name, :website_name => hash[''], :primary => hash[''], :created_at => hash['createdon'] , :updated_at => hash['modifiedon'] , :address1 => hash['address1'] , :address2 => hash['address2'] , :address3 => hash['address3'] , :address4 => hash['address4'] , :post_code => hash[''], :country => hash[''], :address5 => hash[''], :pr_contact => hash[''], :pr_email => hash[''], :pr_number => hash[''], :city => hash['city'] , :country_id => country_method(hash['country_id']), :region => hash[''], :zip => hash[''], :telex => hash[''], :telephone => hash['phone'] , :phone_number2 => hash['phone2'] , :phone_number3 => hash['phone3'] , :fax_number2 => hash['fax2'] , :fax_number3 => hash['fax3'] , :email2 => hash['email2'] , :extension => hash[''], :social_media => hash[''], :facebook => hash[''], :twitter => hash[''], :youtube => hash[''], :linkin => hash[''], :url => hash['web_url'] , :ext => hash[''], :region_id => region_method(hash['region_id']) , :social_media_id => hash[''], :old_id => hash['bank_id'], :facebook_url => hash[''], :twitter_url => hash[''], :youtube_url => hash[''], :linkin_url => hash[''])
    contact_detail.country_id = country_method(hash['country_id'])
    contact_detail.region_id = region_method(hash['region_id'])
    logger.info("New contact detail created name: #{bank_name} ; old_id #{old_id}") if contact_detail.save
    #has_one :central_bank_detail
    hash.clear
    if !each_node.find('centralbank_bankdetails_tbls').blank? and !each_node.find('centralbank_bankdetails_tbls/centralbank_bankdetails_tbl').blank?  and each_node.find('centralbank_bankdetails_tbls/centralbank_bankdetails_tbl').each do | centralbank_each_node |
    centralbank_each_node.to_a.compact.each do | each_field |
    value = "#{each_field.content}" rescue nil
    hash["#{each_field.name}"] = value
    end
    debugger
    #central_bank_detail = CentralBankDetail.create(:ownership => hash['ownership'], :monetary_policy => hash['monetarypolicy_id'], :supervision_policy => hash['supervisionPolicy'], :banking_sector => hash['bankingSector'], :insurance_sector => hash['insuranceSector'], :securities_sector => hash['securitiesSector'], :macro_prudential => hash['macroPrudential'], :pensions => hash['pensions'], :consumer_protection => hash[''], :exchange_rate_regime => hash['exchangeRateDesc'], :central_bank_basic_detail_id => hash[''], :created_at => hash['createdon'], :updated_at => hash['modifiedon'], :all_contact_id => hash[''], :central_bank_list_id => central_bank_list_method(hash['bank_id']), :ownership_id => hash[''], :exchange_rate_regime_id => hash['exchangeRate_id'], :monetary_policy_id => hash[''], :monetory_policy_id => monetory_policy_method(hash['monetarypolicy_id']), :notes => hash[''], :old_id => hash['details_id'])
    central_bank_detail = CentralBankDetail.create( :monetary_policy => hash[''], :supervision_policy => hash['supervisionPolicy'], :banking_sector => hash['bankingSector'], :insurance_sector => hash['insuranceSector'], :securities_sector => hash['securitiesSector'], :macro_prudential => hash['macroPrudential'], :pensions => hash['pensions'], :consumer_protection => hash[''], :central_bank_basic_detail_id => hash[''], :created_at => hash['createdon'], :updated_at => hash['modifiedon'], :all_contact_id => hash[''], :central_bank_list_id => central_bank_list_method(hash['bank_id']), :ownership_id => hash[''], :exchange_rate_regime_id => hash['exchangeRate_id'], :monetary_policy_id => hash[''], :monetory_policy_id => monetory_policy_method(hash['monetarypolicy_id']), :notes => hash[''], :old_id => hash['details_id'])
    debugger
    logger.info("New Central Bank Detail created name: #{hash['']} ; old_id #{hash['']}") if central_bank_detail.save
    #has_one :central_bank_detail
    hash.clear
    end;end;end

    if !each_node.find('centralbank_finacialinfo_tbls').blank? and !each_node.find('centralbank_finacialinfo_tbls/centralbank_finacialinfo_tbl').blank?  and each_node.find('centralbank_finacialinfo_tbls/centralbank_finacialinfo_tbl').each do | centralbank_finacial_each_node |
    centralbank_finacial_each_node.to_a.compact.each do | each_field |
    value = "#{each_field.content}" rescue nil
    hash["#{each_field.name}"] = value
    end
    debugger
    #     central_bankfinancial_detail = CentralBankFinancialDetail.create(:year => hash['financialyear'], :gross_domestic_product_and_price => hash['GDP_CurrentPrices'], :gross_domestic_product_capita_and_price => hash['GDP_PerCapita'], :total_investment => hash['TotalInvestment'], :gross_national_saving => hash['grossNationalSaving'], :inflation_and_avg_consumer_price_index => hash['inflation'], :inflation_and_avg_consumer_price => hash['inflation_per'], :volume_of_imports_goods_services => hash['ImportGoodsServices'], :volume_of_export_goods_services => hash['ExportGoodServices'], :value_of_oil_imports => hash['oil_imports'], :value_of_oil_exports => hash['oil_exports'], :unemployment_rate => hash['unemployment_rate'], :current_ac_balance => hash['CurrentBalance_usd'], :current_ac_balance_gdp => hash['CurrentBalance_per'], :staff_size => hash['staff_size'], :staff_ratio_to_population => hash['sr_population'], :staff_ratio_to_gdp => hash['gdp'], :total_reserves => hash['total_res1'], :gold_reserves => hash['gold_res2'], :fx_reserves => hash['fx_res'], :population => hash['population'], :central_bank_basic_detail_id => hash[''], :created_at => hash[''], :updated_at => hash['modifiedon'], :central_bank_list_id => central_bank_list_method(hash['bank_id']), :year1 => hash[''], :year_id => hash[''], :notes => hash[''], :old_id => hash['financial_id'], :gold_reserves1 => hash[''], :total_reserves1 => hash[''])
    central_bankfinancial_detail = CentralBankFinancialDetail.create(:gross_domestic_product_and_price => hash['GDP_CurrentPrices'], :gross_domestic_product_capita_and_price => hash['GDP_PerCapita'], :total_investment => hash['TotalInvestment'], :gross_national_saving => hash['grossNationalSaving'], :inflation_and_avg_consumer_price_index => hash['inflation'], :inflation_and_avg_consumer_price => hash['inflation_per'], :volume_of_imports_goods_services => hash['ImportGoodsServices'], :volume_of_export_goods_services => hash['ExportGoodServices'], :value_of_oil_imports => hash['oil_imports'], :value_of_oil_exports => hash['oil_exports'], :unemployment_rate => hash['unemployment_rate'], :current_ac_balance => hash['CurrentBalance_usd'], :current_ac_balance_gdp => hash['CurrentBalance_per'], :staff_size => hash['staff_size'], :staff_ratio_to_population => hash['sr_population'], :staff_ratio_to_gdp => hash['gdp'], :total_reserves => hash['total_res1'], :gold_reserves => hash['gold_res2'], :fx_reserves => hash['fx_res'], :population => hash['population'], :central_bank_basic_detail_id => hash[''], :created_at => hash[''], :updated_at => hash['modifiedon'], :central_bank_list_id => central_bank_list_method(hash['bank_id']), :year1 => hash[''], :year_id => hash[''], :notes => hash[''], :old_id => hash['financial_id'], :gold_reserves1 => hash[''], :total_reserves1 => hash[''])
    logger.info("New Central Bank Finacial created name: #{hash['']} ; old_id #{hash['']}")
    #has_one :central_bank_detail
    hash.clear
    end;end

    if !each_node.find('centralbank_otheroffices_tbls').blank? and !each_node.find('centralbank_otheroffices_tbls/centralbank_otheroffices_tbl').blank?  and each_node.find('centralbank_otheroffices_tbls/centralbank_otheroffices_tbl').each do | centralbank_otheroffices_each_node |
    centralbank_otheroffices_each_node.to_a.compact.each do | each_field |
    value = "#{each_field.content}" rescue nil
    hash["#{each_field.name}"] = value
    end
    debugger
    other_office =  OtherOffice.create(:office_type => hash['officeType'], :central_bank_basic_detail_id => hash[''], :all_contact_id => hash[''], :resourse_basic_detail_id => hash[''], :created_at => hash['createdon'], :updated_at => hash['modifiedon'], :entity_type => central_bank_list.class.name, :entity_id => central_bank_list.id, :notes => hash[''], :old_id => hash['office_id'])
    logger.info("New Central Bank Other Offices  created name: #{hash['']} ; old_id #{hash['']}")
    #has_one :central_bank_detail
    hash.clear
    end;end

    if !each_node.find('bankpeople_info_tbls').blank? and !each_node.find('bankpeople_info_tbls/bankpeople_info_tbl').blank?  and each_node.find('bankpeople_info_tbls/bankpeople_info_tbl').each do | bank_people_each_node |
    bank_people_each_node.to_a.compact.each do | each_field |
    value = "#{each_field.content}" rescue nil
    hash["#{each_field.name}"] = value
    end
    debugger
    PersonContact.create(:status => hash['people_status'], :title => hash['title'], :first_name => hash['fname'], :last_name => hash['lname'], :gender => hash[''], :job_title => hash['job_title_id'], :responsibility => hash[''], :biography => hash[''], :number_of_years => hash[''], :appointment_date => hash[''], :appointed_by => hash[''], :image_id => hash[''], :central_bank_basic_detail_id => hash[''], :resourse_basic_detail_id => hash[''], :all_contact_id => hash[''], :created_at => hash['createdon'], :updated_at => hash['modifiedon'], :entity_type => central_bank_list.class.name, :entity_id => central_bank_list.id, :responsibility_id => hash[''], :notes => hash[''], :old_id => hash['people_id'])
    logger.info("New Bank People created name: #{hash['']} ; old_id #{hash['']}")
    #has_one :central_bank_detail
    hash.clear
    end;end

    if !each_node.find('socialmdia_basicinfodata_tbls').blank? and !each_node.find('socialmdia_basicinfodata_tbls/socialmdia_basicinfodata_tbl').blank?  and each_node.find('socialmdia_basicinfodata_tbls/socialmdia_basicinfodata_tbl').each do | socialmdia_each_node |
    socialmdia_each_node.to_a.compact.each do | each_field |
    value = "#{each_field.content}" rescue nil
    hash["#{each_field.name}"] = value
    end
    debugger
    contact_detail = ContactDetail.create(:entity_id => central_bank_list.id, :entity_type => central_bank_list.class.name, :old_id => hash['id'],:created_at => hash['createdon'] , :updated_at => hash['modifiedon'] )
    logger.info("New Social Media created name: #{hash['']} ; old_id #{hash['']}")
    debugger
    #has_one :central_bank_detail
    hash.clear
    end;end

    #end
    end
    end
    end;end

  end
end