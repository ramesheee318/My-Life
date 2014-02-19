require "spreadsheet/excel"
require 'action_mailer'

class SentMail < ActionMailer::Base
  def file(sender,to,file_names)

    subj = "Performance Test report on Live"
    recipients  to
    from        sender

    subject     subj
    body        "Hi All,
                   
                This is automated mail from script after analyzing the all sites home pages.
                The attached xls file is having all the urls with component details taking more that 0.2 sec and total time taken more than 2 Sec.

                Please find the attached xls file and go though it.


                Thanks,
                CMS Migration Team"

    file_names.collect do |file_name|
      attachment  :content_type => 'application/x-gzip',
      :body         => File.read(file_name),
      :filename     => file_name.gsub(/.*\//,'')
    end
  end
end

class SiteHomepagePerformanceReport
  def self.forsites
#`cd /opt/ruby/CMS/WPS/`
#`rvm use ruby-1.8.7-p370@wpsunicorn`
`echo 0 > /opt/ruby/CMS/WPS/log/performancetest.log`
begin
`/etc/init.d/unicorn_performance start wps_per`
rescue
 puts "port already in use"
end
site_names = Site.find(:all).collect{| aa | aa.name} - ["www.professionaladviser.com.hk", "www.professionaladviser.com.sg", "www.globalpensions.com", "www.broking.co.uk","www.custodyrisk.net","www.theactuary.com"]
sites = []
     for site_name in site_names
        if "#{site_name}" =~ /(^www.\w.*)/
        sites << "#{site_name}"
        end
     end
report_sheet = Spreadsheet::Excel.new("#{RAILS_ROOT}/tmp/site_homepage_performace_report_#{Time.now.strftime('%d-%m-%Y')}.xls")
#local_sh_path="/opt/ruby/CMS/article_performance"
 for site in sites
    @site = Site.find_by_name("#{site}")
    set_all_site_properties_enable(@site)
end
 	
process=1
while process < 4
`echo 0 > /opt/ruby/CMS/WPS/log/performancetest.log`
@worksheet = report_sheet.add_worksheet("#{process}-attempt")
#for site in sites
 # @site = Site.find_by_name("#{site}")
 # if @site
 # site_short_name= @site.short_name
  #debugger	
 # sh_path= "#{local_sh_path}/#{site_short_name}.sh"
  #if File.exists?(sh_path)
  
    #url_to_hit="wget http://localhost:3000/ --header="+"Host:#{@site.name}"+'--header="SR_REMOTE_ADDR:62.140.213.235"'
#	url_to_hit= "wget http://localhost:3000/ --header='Host:#{@site.name}' --header='SR_REMOTE_ADDR:62.140.213.235'"
    #debugger
#     puts url_to_hit
#    set_all_site_properties_enable(@site)	
   `cd /opt/ruby/CMS/article_performance/logs/ && sh /opt/ruby/CMS/article_performance/all_sites/all_site.sh`
#    system(url_to_hit)	 
  #else
  # puts "Site not find-->#{site}"
  #end
#end
process+=1
#debugger
log_file="/opt/ruby/CMS/WPS/log/performancetest.log"
generate_report_for_site(@worksheet,log_file)
end
#debugger
report_sheet.close
`cd /opt/ruby/CMS/article_performance/logs/ && rm *`  
begin
`/etc/init.d/unicorn_performance stop wps_per`
rescue
end
for site in sites
    @site = Site.find_by_name("#{site}")
    set_all_site_properties_disable(@site) 
end
report_file_path = "#{RAILS_ROOT}/tmp/site_homepage_performace_report_#{Time.now.strftime('%d-%m-%Y')}.xls"
 SentMail.deliver_file("infrastructure@ramesh.com",["neetinkumar@ramesh.com","pankaj@ramesh.com","senthilkumar@ramesh.com","dipti@ramesh.com"],report_file_path)
#SentMail.deliver_file("infrastructure@ramesh.com",["neetinkumar@ramesh.com"],report_file_path)

end
#/etc/init.d/unicorn_performance stop wps_per
  def self.set_all_site_properties_enable(site)
   property_default_mapping = {'performance_data_level' => 'debug','performance_data_to_log' => "true"}
   @site_properties = SiteProperty.find_all_by_site_id(site.id)
   @site_properties.each {|property|
        if( property_default_mapping[property.name] and not property_default_mapping[property.name].eql?(property.value) )
          puts "#{property.name} =====> #{property_default_mapping[property.name]} ==>#{site.name}\n"
          property.update_attributes( :value => property_default_mapping[property.name] )
        end
      }
      #puts "\n\n"
      unavail_properties = property_default_mapping.keys - @site_properties.collect{|property| property.name}
      #debugger	
      unavail_properties.collect{|property|
        add_properties = SiteProperty.create(:name => property, :value => property_default_mapping[property], :site_id => site.id )
        puts "Added New Properties =====> #{add_properties.name} =====> #{add_properties.value} ==>#{site.name}"
#	puts "new properties need to add -->#{property}"
      }	
  end

  def self.set_all_site_properties_disable(site)
     property_default_mapping = {'performance_data_to_log' => "false"}
     @site_properties = SiteProperty.find_all_by_site_id(site.id)
     @site_properties.each {|property|
        if( property_default_mapping[property.name] and not property_default_mapping[property.name].eql?(property.value) )
	  #debugger
          puts "disable ==> #{property.name} =====> #{property_default_mapping[property.name]} ==>#{site.name}\n"
	   #debugger
          property.update_attributes( :value => property_default_mapping[property.name] )
        end
      }	
  end

def self.generate_report_for_site(worksheet,logfile)
  #worksheet = report_sheet.add_worksheet("#{site_short_name}")
  worksheet.write(0, 0, "URL"); worksheet.write(0, 1, "Completed Time"); worksheet.write(0, 2, "Component");worksheet.write(0, 3, "Render Time");
   row_count=1
   url_count=1
   complete_count=1		
    file= File.open("#{logfile}","r")
    @components_time_taken= []
    @render_time_take =[]	
    while(line = file.gets)
#      @components_time_taken=[]
        @others_time_taken=[]
#	@render_time_take =[]
        if(line[/Processing/])
        elsif(matches = line.match(/\s(Component:)\s+([\w|,|-]*).*Total Time taken\s+=\s+(\w+.\w+).*(Served from Cache\?)\s+=\s+(\w+).*(Cached\?)\s+=\s+(\w+)/))
#      elsif(matches = line.match(  (    $1    )   (   $2  )                         (   $3  )  (         $4        )       ( $5)  )
          split =  $3.to_f
#          @components_time_taken << $3.to_f if $3.to_f
          if  split > 0.02
            #op_file.puts( $1 + $2.rjust(20) + $3.rjust(15)+','+$4.rjust(15)+$5.rjust(5)+','+$6.rjust(15)+$7.rjust(5))
	    #worksheet.write(row_count, 2, "#{line}");
	     @components_time_taken << "#{line}"
	    row_count+=1
          end
        elsif(line[/Site Name/])
        elsif(line.match(/((\d+.\d+)ms\))/))
         if $2.to_f > 200.00
           #op_file.puts(line)
         end
	#elsif(line[/Rendered .*\((\d+.\d+)ms\)/])
	#puts line
	#elsif(match = line.match(/Rendered/))
#	puts line
#	  debugger
#	   puts "renderd"
#	  line.match(/Rendered/)
	  if line.match(/Rendered .*\((\d+.\d+)ms\)/)
	   if $1.to_f > 400.00
            @render_time_take << "#{line}" #if line.match(/Rendered .*\((\d+.\d+)ms\)/)
           end
	  end 
        elsif(line[/End rendering/])
          #op_file.puts(line)
        elsif(line[/Completed/])
          #op_file.puts("\nTotal Time Taken of Components  =  #{@components_time_taken.inject(0){|sum, time| sum + time}.to_s}s\n")
          line.match(/Completed in ((\d+)ms).*\[(http:.*)\]/)
	  #worksheet.write(complete_count, 1, "#{$2}");
          value = $1.to_i
          #if value > 2000
            #op_file.puts(@processtime)            
            #op_file.puts(@sitename)
            #op_file.puts(@username)
            ####op_file.puts(@timetaken)
            #op_file.puts("( "+ $1 + " )" + $3 + "\n\n")
#	     debugger
	     worksheet.write(url_count, 0, "#{$3}");	     
	     worksheet.write(url_count, 1, "#{$1}");
             worksheet.write(url_count, 2, "#{@components_time_taken}");
	     worksheet.write(url_count, 3, "#{@render_time_take}");
	     url_count+= 1
	     @components_time_taken= []
	     @render_time_take = []		
          #end
        end	
    end 
end

end
