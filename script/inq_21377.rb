require 'ruby-debug'
require 'builder'
require 'application_helper'
Ambient.init()
Ambient.current_site = Site.find_by_short_name "inquirer"
File.open("#{RAILS_ROOT}/inquirer_rss_feeds.xml", 'w+') {|file|  #1
  xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
  xml.instruct!
  xml.rss :version => "2.0","xmlns:atom" => "http://www.w3.org/2005/Atom", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/", "xmlns:dsq" => "http://www.disqus.com/",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
  "xmlns:wp"=> "http://wordpress.org/export/1.0/" do #2
    xml.channel do #3
   ###  for article in Ambient.current_site.articles.limit(500).collect{|aa| aa  if !aa.comments.blank?}.compact
   ###   for article in Ambient.current_site.articles.find(:all, :page=>{:size=>1000,:auto=>true}).collect{|aa| aa if !aa.comments.blank?}.compact #4
     for article in Ambient.current_site.articles.find(:all,:conditions =>["created_at >=? and created_at <=?","2012-11-19 00:00:00","2012-12-10 23:59:59"])
         ###  if article.created_by != nil #5
         ###  if User.find(article.created_by).email.size <= 75 #6
     @comment_sizes =  article.comments.collect{|aa| aa if aa.description.size >= 3 and aa.description.size <= 70}.compact.collect{|ee| ee if !ee.email.blank? and ee.email.size <= 14}.compact
        ###        @comment_sizes =  article.comments.collect{|aa| aa if aa.description.size >= 3 and aa.description.size <= 2500}.compact
            if !@comment_sizes.blank? #7

              puts "-------->#{article.id}"
              xml.item do
                if !article.title.blank?
                  xml.title "#{article.title}"
                else
                  xml.title
                end

                xml.link "http://#{article.sites.first.name}#{article.url}" if !article.source_alais_name.blank? && !article.section.alias_name.blank?
                xml.content :encoded, "<!--[CDATA[" + article.content.gsub('--','-').gsub('&','').gsub('<','').strip + "]]-->" if !article.content.blank?
                xml.dsq :thread_identifier, article.id
                xml.wp :post_date_gmt, article.created_at.utc.to_formatted_s(:db)  #24 hour format
                xml.wp :comment_status, "open"
                @comment_sizes.each do |each_comment|
                  xml.wp(:comment) do

                    xml.wp :comment_id, each_comment.id

                    if !each_comment.user_name.blank?
                      xml.wp :comment_author, each_comment.user_name
                    else
                      xml.wp :comment_author
                    end

                    if !each_comment.email.blank?
                      xml.wp :comment_author_email, each_comment.email
                    else
                      xml.wp :comment_author_email
                    end

                    xml.wp :comment_author_url, "http://#{article.sites.first.name}" if article.sites.first.name

                    if !each_comment.ip_address.blank?
                      xml.wp :comment_author_IP, each_comment.ip_address
                    else
                      xml.wp :comment_author_IP
                    end
                    if !each_comment.created_at.blank?
                      xml.wp :comment_date_gmt, each_comment.created_at.utc.to_formatted_s(:db)
                    else
                      xml.wp :comment_date_gmt
                    end
                    if !each_comment.description.blank?
                      xml.wp :comment_content, each_comment.description.gsub(%r{</?[^>]+?>}, '')
                    else
                      xml.wp :comment_content
                    end
                    xml.wp :comment_approved, "1"
                    xml.wp :comment_parent  #, each_comment.id
                  end
                end
              end
            end #7
###         end  #6
###        end #5
      end #4
    end #3
  end #2
} #1