require "spreadsheet/excel"

["www.fxweek.com","bjpredesign.notquitelive.incbase.net","cpc.channelweb.co.uk","www.globalpensions.com","www.avcj.com","www.custodyrisk.net","www.computing.co.uk","www.waterstechnology.com","www.computeractive.co.uk","www.v3.co.uk","cms.searchenginewatch.com","www.accountancyage.com","www.unquote.com","www.postonline.co.uk","www.investmentweek.co.uk","www.gtforum.com","www.mortgagesolutions.co.uk","www.professionalpensions.com","www.theinquirer.net","www.legalweek.com","www.clickz.com","www.insuranceinsight.com","www.businessgreen.com","www.bjp-online.com","www.risk.net","www.broking.co.uk","www.theactuary.com","www.channelweb.co.uk","www.financialdirector.co.uk","www.yourmoney.com","www.incisivemedia.com","www.wsandb.co.uk","www.investmenteurope.net","www.covermagazine.co.uk","www.ifaonline.co.uk","www.centralbanking.com","www.yourmortgage.co.uk"].each do | site |
  begin
s=Site.find_by_name(site)
f = Spreadsheet::Excel.new("#{RAILS_ROOT}/tmp/report_of_#{s.short_name}.xls")
puts "get #{"#{RAILS_ROOT}/tmp/report_of_#{s.short_name}.xls"}"
worksheet = f.add_worksheet("#{s.name}")
worksheet.write(0, 0, "Source Name"); worksheet.write(0, 1, "year"); worksheet.write(0, 2, "count of articles")
worksheet.write(0, 5, "Section Name"); worksheet.write(0, 6, "Count of article"); worksheet.write(0, 7, "Year")
first = s.articles.find(:first,:order => "created_at ASC").created_at.strftime('%Y')
last  = s.articles.find(:first,:order => "created_at DESC").created_at.strftime('%Y')
 row = 1
 s.sources.each do | source |
 (first..last).each do | year |
 count =s.articles.by_source(source.id).published_date_range("#{year}-01-01 00:00:00","#{year}-12-31 23:59:59").count
 #puts "#{source.name}  #{year}  ==#{count}"
 worksheet.write(row, 0, "#{source.name}"); worksheet.write(row, 1, "#{year}"); worksheet.write(row, 2, "#{count}")  
 row += 1
 end
end 

 row_n = 1
 s.sections.each do | section |
  (first..last).each do | year |
  count =s.articles.by_sections(section.id).published_date_range("#{year}-01-01 00:00:00","#{year}-12-31 23:59:59").count
  #puts "#{section.name}  #{year}  ==#{count}"
  worksheet.write(row_n, 5, "#{section.name}"); worksheet.write(row_n, 6, "#{year}"); worksheet.write(row_n, 7, "#{count}")
  row_n += 1
 end
end
f.close
rescue
  puts site 
end  
end



require "spreadsheet/excel"
#["www.fxweek.com","bjpredesign.notquitelive.incbase.net","cpc.channelweb.co.uk","www.globalpensions.com","www.avcj.com","www.custodyrisk.net","www.computing.co.uk","www.waterstechnology.com","www.computeractive.co.uk","www.v3.co.uk","cms.searchenginewatch.com","www.accountancyage.com","www.unquote.com","www.postonline.co.uk","www.investmentweek.co.uk","www.gtforum.com","www.mortgagesolutions.co.uk","www.professionalpensions.com","www.theinquirer.net","www.legalweek.com","www.clickz.com","www.insuranceinsight.com","www.businessgreen.com","www.bjp-online.com","www.risk.net","www.broking.co.uk","www.theactuary.com","www.channelweb.co.uk","www.financialdirector.co.uk","www.yourmoney.com","www.incisivemedia.com","www.wsandb.co.uk","www.investmenteurope.net","www.covermagazine.co.uk","www.ifaonline.co.uk","www.centralbanking.com","www.yourmortgage.co.uk"]
["www.insuranceinsight.com"].each do | site |
  begin
s=Site.find_by_name(site)
f = Spreadsheet::Excel.new("#{RAILS_ROOT}/tmp/report_of_#{s.short_name}.xls")
puts "get #{"#{RAILS_ROOT}/tmp/report_of_#{s.short_name}.xls"}"
worksheet = f.add_worksheet("#{s.name}")
worksheet.write(0, 0, "website"); worksheet.write(0, 1, "source"); worksheet.write(0, 2, "content type")
worksheet.write(0, 3, "year"); worksheet.write(0, 4, "Count of articles created in this year")
first = s.articles.find(:first,:order => "created_at ASC").created_at.strftime('%Y')
last  = s.articles.find(:first,:order => "created_at DESC").created_at.strftime('%Y')
row = 1
    s.sources.each do | source |
      s.sections.each do | section |
       (first..last).each do | year |
       count =  s.articles.by_source(source.id).by_sections(section.id).published_date_range("#{year}-01-01 00:00:00","#{year}-12-31 23:59:59").count
#       puts "Sourec: #{source.name} > content type: #{section.name} > year: #{year} > Count of articles: #{count} "
       worksheet.write(row, 0, "#{s.name}"); worksheet.write(row, 1, "#{source.name}"); worksheet.write(row, 2, "#{section.name}")
       worksheet.write(row, 3, "#{year}"); worksheet.write(row, 4, "#{count}")  
 row += 1
       end
      end
    end  
f.close
rescue
  puts site 
end  
end
