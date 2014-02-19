require "rubygems"
require "ruby-debug"
require "builder"
require 'iconv'
require 'find'
require 'open-uri'
require 'net/http'
require 'uri'
class ExportForIwkDataSql

  def self.export
    dir_path = ( FileUtils.mkdir_p "#{Rails.root}/../IWKExport" ).first
    ( FileUtils.mkdir_p "#{Rails.root}/../IWKExport/doc" ).first; ( FileUtils.mkdir_p "#{Rails.root}/../IWKExport/images" ).first


#   {"/News" => "News"}.each do |k,v|
#     {"/Gc_Print_Archive" => "Gc_Print_Archive"}.each do |k,v|
{"/VideoEmbed" => "VideoEmbed"}.each do |k,v|
    logger  = Logger.new("#{Rails.root}/log/suggets.log")
    ##  {"/News" => "News","/Blogs" => "Blogs","/PRNewswire" => "PRNewswire","/LearningCenter" => "LearningCenter"}.each do |k,v|
      #****#SfCmsContentBase.find_all_by_Application("#{k}").each do | each_section_content |
      (SfCmsContentBase.find(:all,:conditions =>["Application = ? and ID =?","#{k}","D81DAD12-EBDA-4F55-A40B-02F1E285CDB5"])).each do | each_section_content |
      #logger .class.name
      puts "ID: -------> #{each_section_content.ID}"
      logger.info("ID: -------> #{each_section_content.ID}")
        section_base_path = ( FileUtils.mkdir_p "#{dir_path}/#{v}" ).first
        #logger
        File.open("#{section_base_path}/#{each_section_content.ID}.xml", 'w+') {|file|
        #logger
          xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
          xml.instruct!
          xml.article do
            xml.article_id  "#{each_section_content.ID}"
            xml.language("Language" => "en")
            xml.content_type("id" => "#{each_section_content.Application}")
            xml.mime_type("format" => "#{each_section_content.MimeType}")
            xml.old_url("Url" => "#{each_section_content.Url}" , "LoweredUrl" => "#{each_section_content.LoweredUrl}")

            if !(gcmeta_data = SfGCMetaData.find_all_by_ContentID "#{each_section_content.ID}").blank?
            xml.GCMetaData do # loop
            gcmeta_data.each do | content_field |
  

 if content_field.KeyValue == "Author"
                    if !content_field.ShortText.blank?
                      xml.Author do
                        a = 0
                        Array(content_field.ShortText).each do | each_author |
                          a = a + 1
                          xml.author("count" => "#{a}", "ShortText" => "#{each_author}") if each_author
                          logger.info("Author: -------> #{each_author}") if each_author
                        end
                      end
                    else
                    #logger Author ShortText blank
                    end
                  else
                  #logger Author not in table
                  end

    if content_field.KeyValue == "Title"

                    xml.Title do
                      xml.LongText "#{content_field.LongText}" if content_field.LongText
                      logger.info("Title 1: -------> #{content_field.LongText}") if content_field.LongText
                      xml.ShortText "#{content_field.ShortText}" if content_field.ShortText rescue ""
                      logger.info("Title 2: -------> #{content_field.ShortText}") if content_field.ShortText
                    end
                  else
                  #logger Title Blank!
                  end
                  if content_field.KeyValue == "Expiration_Date"
                    xml.Expiration_Date "#{content_field.DateTimeValue}" if content_field.DateTimeValue
                  else
                  #logger
                  end

   puts "Keywords"
                  if content_field.KeyValue == "Keywords"
                    xml.Keywords "#{content_field.LongText}" if content_field.LongText
                  else
                  #logger LongText
                  end

   puts "Publication_Date"

                  if content_field.KeyValue == "Publication_Date"
                    xml.Publication_Date "#{content_field.DateTimeValue}" if content_field.DateTimeValue
                  else
                  #logger LongText
                  end

#Source && Source URl
   if content_field.KeyValue == "SourceURL"

              xml.Title do
                xml.LongText "#{content_field.LongText}" if content_field.LongText
                logger.info("SourceURL 1: -------> #{content_field.LongText}") if content_field.LongText
                xml.ShortText "#{content_field.ShortText}" if content_field.ShortText rescue ""
                logger.info("SourceURL 2: -------> #{content_field.ShortText}") if content_field.ShortText
              end
            else
            #logger Title Blank!
            end


 if content_field.KeyValue == "Source"
                    xml.Source "#{content_field.ShortText}" if content_field.ShortText
                  else
                  #logger LongText
                  end

  if content_field.KeyValue == "Summary"
                    xml.Summary "#{content_field.ShortText}" if content_field.ShortText
                    xml.Summary "#{content_field.LongText}" if content_field.LongText
                  else
                  #logger LongText
                  end

  if content_field.KeyValue == "DownloadUrl"
                    if content_field.ShortText
                      puts "rrrrrrrrrrrrrrrrrrrr"
                      debugger
                      puts "PDF: #{content_field.ShortText}"
                      if content_field.ShortText =~ /[^L].+]([a-z0-9_.-i\/]+?.*)/i
                        logger.info("DownloadUrl: -------> #{$1}") if $1
                        image_link = "#{$1}"
                        puts "ttttttttttttttttttt"
                        doc_img = image_create(image_link,dir_path,content_field.ContentID)
                        xml.DownloadUrl "#{doc_img}" if doc_img
                      end
                    else
                    # no image
                    end
                  else
                  #logger LongText
                  end


  if content_field.KeyValue == "PDF"
                    if content_field.ShortText
                      puts "rrrrrrrrrrrrrrrrrrrr"
                      debugger
                      puts "PDF: #{content_field.ShortText}"
                      if content_field.ShortText =~ /[^L].+]([a-z0-9_.-i\/]+?.*)/i
                        logger.info("DownloadUrl: -------> #{$1}") if $1
                        image_link = "#{$1}"
                        puts "ttttttttttttttttttt"
                        doc_img = image_create(image_link,dir_path,content_field.ContentID)
                        xml.DownloadUrl "#{doc_img}" if doc_img
                      end
                    else
                    # no image
                    end
                  else
                  #logger LongText
                  end
 #Iframe
                    if content_field.KeyValue == "Code"
                      if content_field.LongText
                        puts "Iframe"
                        xml.iframe  URI.decode(content_field.LongText) rescue ""
                      else
                        puts "Blank"
                      end
                    end
                    
                    
 if content_field.KeyValue == "BigThumbnail"
                    if content_field.ShortText
                      puts "IMG: #{content_field.ShortText}"
                      if content_field.ShortText =~ /[^L].+]([a-z0-9_.-i\/]+?.*)/ #/[^L].+]([a-z0-9_.-i\/]+?.*)/i
                        image_link = "#{$1}"
                        logger.info("Thumbnail: -------> #{$1}") if $1
                        doc_img = image_create(image_link,dir_path,content_field.ContentID)
                        xml.Thumbnail "#{doc_img}" if doc_img
                      else
                if content_field.KeyValue == "Thumbnail"
                          if content_field.ShortText
                            puts "IMG: #{content_field.ShortText}"
                            if content_field.ShortText =~ /[^L].+]([a-z0-9_.-i\/]+?.*)/ #/[^L].+]([a-z0-9_.-i\/]+?.*)/i
                              image_link = "#{$1}"
                              logger.info("Thumbnail: -------> #{$1}") if $1
                              doc_img = image_create(image_link,dir_path,content_field.ContentID)
                              xml.Thumbnail "#{doc_img}" if doc_img
                            end
                          else
                          # no image
                          end
                        else
                        #logger Thumbnail
                        end

                        
                      end
                    else
                    # no image
                    end
                  else
                  #logger Thumbnail
                  end


                    

            if content_field.KeyValue == "Thumbnail"
                 if content_field.ShortText
                 puts "IMG: #{content_field.ShortText}"
                  if content_field.ShortText =~ /[^L].+]([a-z0-9_.-i\/]+?.*)/ #/[^L].+]([a-z0-9_.-i\/]+?.*)/i
                  image_link = "#{$1}"
                  logger.info("Thumbnail: -------> #{$1}") if $1
                  doc_img = image_create(image_link,dir_path,content_field.ContentID)
                  xml.Thumbnail "#{doc_img}" if doc_img
                  end
                 else
                 # no image
                 end
            else
            #logger Thumbnail
            end
            end 
           end  # loop
            else
            #logger Blank!
            end



 
 if !(content = SfCmsTextContent.find_by_ID "#{each_section_content.ID}").blank?
              cont =  image_find(content.Content,dir_path,gcmeta_data)
              debugger
              xml.content cont.gsub(/<p>&nbsp;<\/p>\s<p>&nbsp;<\/p>/,"")
            else
            #logger
            end

          

 # Tag
  if !(tags = SfCmsTaggedContent.find_all_by_ContentID "#{each_section_content.ID}").blank?
    xml.tags do
      tags.each do |tag|
        xml.tag SfCmsTag.find_by_ID("#{tag.TagID}").TagName if SfCmsTag.find_by_ID("#{tag.TagID}").TagName
      end
    end
  else
  #logger
  end

 if each_section_content.ParentID != nil
            #logger SfCmsContentThumbnail
            else
            #logger
            end
          end
        }
      end
    end
  end
  
puts   ""
     def self.image_find(content,dir_path,ids)
       puts "******************"
puts "#{content}"
     content.gsub!(/(<img[^>]*[^>]*>)/i)  do | cont |
       if cont =~ /<img.*src=['|"][^L].+]([a-z0-9_.-i\/]+?.*)['|"]\s+\/>/
         image_link = "#{$1}"
puts "<><><><><><><><><><><><<><><><><><<#{$1}"

        doc_img = image_create(image_link,dir_path,ids)
         if doc_img != nil
         puts "#{doc_img}"
           cont.sub(/src=['|"][^L].+]([a-z0-9_.-i\/]+?.*)['|"]/,"src='#{doc_img}'")
         else
puts "<><><><><><><><><><><><<><><><><><<#{$1}"
           cont.sub(/src=['|"][^L].+]([a-z0-9_.-i\/]+?.*)['|"]/,"src='#{$1}'")
         end
       end

     ##################

    if cont =~ /<img.*src=(['|"][^L].+([a-z0-9_.-i\/]+?.*)['|"]\s+)\/>/
         image_link = "#{$1}"
puts "<><><><><><><><><><><><<><><><><><<#{$1}"
debugger
        doc_img = image_fatched_from_http(image_link,dir_path)
        if doc_img != nil
         puts "#{doc_img}"
           cont.sub(/src=['|"][^L].+([a-z0-9_.-i\/]+?.*)['|"]/,"src='#{doc_img}'")
         else
debugger ##
puts "<><><><><><><><><><><><<><><><><><<#{$1}"
           cont.sub(/src=['|"][^L].+([a-z0-9_.-i\/]+?.*)['|"]/,"src='#{$1}'")
        end
    end

     end
puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
     return content
   end
  

   def self.image_create(id,dir_path,ids)
    title =  SfGCMetaData.find(:first,:conditions =>["Application =? and KeyValue =? and ContentID =?","/SponsoredWP","Title",ids]).ShortText  rescue ""
    title =  SfGCMetaData.find(:first,:conditions =>["Application =? and KeyValue =? and ContentID =?","/SponsoredWP","Title",ids]).LongText if !title
    if !(image =  SfCmsBinaryContent.find_by_ID "#{id}").blank?
      if !(image_ext =  SfCmsContentThumbnail.find_by_ParentID(image.ID)).blank?
        image_name =  Util.convert_to_url_string(image_ext.Title)
        enc_img_cont =  ActiveSupport::Base64.encode64("#{image.ContentValue}")
        File.open("#{dir_path}/images/#{image_name.gsub(/-|_/,"")}#{image_ext.Extension}", "wb") { |f| f.write(ActiveSupport::Base64.decode64(enc_img_cont))}
        return "/images/#{image_name.gsub(/-|_/,"")}#{image_ext.Extension}"
      else
        puts "dsdddddd"
        debugger
        doc_hash  = {"PDF" => "pdf","PK" => "docx"}
        enc_img_cont =  ActiveSupport::Base64.encode64("#{image.ContentValue}")
        if p = (image.ContentValue =~ /^.*PDF/)
          if p == 0
            File.open("#{dir_path}/doc/#{title.gsub(/-|_|\//,"")}.pdf", "wb") { |f| f.write(ActiveSupport::Base64.decode64(enc_img_cont))}
            puts "sssss"
            return "/doc/#{title}.pdf"
          end
        elsif x = (image.ContentValue =~ /^.*PK/)
          if x == 0
            File.open("#{dir_path}/doc/#{title}.docx", "wb") { |f| f.write(ActiveSupport::Base64.decode64(enc_img_cont))}
            puts "TTTTT"
            return "/doc/#{title}.docx"
          end
        else
          File.open("#{dir_path}/doc/#{title}.pdf", "wb") { |f| f.write(ActiveSupport::Base64.decode64(enc_img_cont))}
          puts "ssssss"
          return "/doc/#{title}.pdf"
        end
      end
    else
    end
  end



  def self.image_fatched_from_http(imgsrc,path)
    data_path =  ( FileUtils.mkdir_p  "#{path}/HttpDownload" ).first
    log_img = Logger.new("#{Rails.root}/log/image_find_#{Time.now.to_date}.log")
    log_img_err = Logger.new("#{Rails.root}/log/image_does_not_find_#{Time.now.to_date}.log")
    if imgsrc =~ /(http|Http|https|Https):\/\/[a-z0-9_.-i\/].*/i
#      image_full_path = "#{data_path}/" + imgsrc.split('/').last.split('.ashx').first.gsub(".","")
      if imgsrc
         if imgsrc =~ /((http|Http|https|Https):\/\/[a-z0-9_.-i\/]+?.*?)\"/
       puts "$==> #{$1}"
       image_decode = $1.gsub(/&amp;/, "&").gsub(/&lt;/, "<").gsub(/&gt;/, ">").gsub(/&apos;/, "'").gsub(/&quot;/, '"')
       puts "Decode #{image_decode}"
#        image_name=URI.encode(image_decode.split('/').last.split('.ashx').first)
image_name=URI.encode(image_decode.split('/').last.split('.ashx').first.gsub(/.ashx|.sflb/,""))
       puts "Image => #{imgsrc}"
        url = URI.parse(image_decode)
        puts "URL:#{url}"
        http = Net::HTTP.new(url.host, url.port)
        fetch_file=Net::HTTP.get_response(url)

         if fetch_file.class== Net::HTTPNotFound
          puts "image not found #{url}"
          log_img_err("image not found #{url}")
          return nil
         else
          img_alt = image_name
          File.open("#{data_path}/#{image_name}.jpg", "wb") { |f| f.write(fetch_file.body) }
          log_img.info("Image  exists in HttpImage  #{image_name}")
          puts "Created New Image**************************"
          image_full_path="#{Rails.root}/HttpImage/#{image_name}"
         return "HttpDownload/#{image_name}.jpg"
         end
         end #%#
      end
      return nil
    end
  end

  end
#end



