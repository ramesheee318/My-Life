require 'net/imap'
require 'ruby-debug'
require 'mail'
require 'fileutils'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
imap = Net::IMAP.new('mail.ramesh.com',993,true)
imap.login('youremailaddress', 'your email password')
imap.select('Inbox')
# All msgs in a folder
#msgs = imap.search(["SINCE", "1-Jan-1969"])
msgs = imap.search(['FROM','where you get the mail sender address email(neetinkumar@ramesh.com)','UNSEEN'])
# Read each message
msgs.each do |msgID|
#debugger
body1 = imap.fetch(msgID, "RFC822")[0].attr["RFC822"]
#require 'mail'
  mail = Mail.new(body1)
  #attachment = mail.attachments.first
  #debugger
  attachments = mail.attachments
  for attachment in attachments
    if attachment.filename.split('.').last=="docx"
     @orginal_file_name= attachment.filename.split('.').first.split(" ").join("")
     fn = "/home/test/mail_downloaded_docs/#{attachment.filename}"
     @doc_file="/home/test/mail_downloaded_docs/#{attachment.filename}"	
     begin
       File.open( fn, "w+b", 0644 ) { |f| f.write attachment.decoded}
     rescue Exception => e
       puts "Error : Unable to save data for #{fn} because #{e.message}"
     end
#puts "11" 
#end
#imap.close
#puts "12"
#@doc_file="/home/test/mail_downloaded_docs/Inside-outside-sample-doc.docx"
	puts "#{@doc_file} ---> orginal file name-->#{@orginal_file_name}"
#`cd /home/test/doc_to_html_new`
#`sh #{Rails.root}/docx_to_html/docx2xhtml.sh #{@doc_file}`
	TMP_DIR=`mktemp -d --suffix=ramesh` #|| exit 1
	puts TMP_DIR
	`unzip "#{@doc_file}" -d #{TMP_DIR} >/dev/null`
	`cp #{Rails.root}/docx_to_html/kr-docx2html.xslt #{TMP_DIR}`
# FileUtils.cp("#{Rails.root}/docx_to_html/kr-docx2html.xslt","#{TMP_DIR}")
	`cp #{Rails.root}/docx_to_html/finish-up.xslt #{TMP_DIR}` 
# FileUtils.cp("#{Rails.root}/docx_to_html/finish-up.xslt","#{TMP_DIR}")
	`xsltproc #{TMP_DIR.sub("\n",'')}/kr-docx2html.xslt #{TMP_DIR.sub("\n",'')}/word/document.xml > #{TMP_DIR.sub("\n",'')}/stage1.xhtml`
	`xsltproc #{TMP_DIR.sub("\n",'')}/finish-up.xslt #{TMP_DIR.sub("\n",'')}/stage1.xhtml > #{TMP_DIR.sub("\n",'')}/#{@orginal_file_name}.xhtml`
	end
   end
 end
puts "no  message to be seen"
imap.close

