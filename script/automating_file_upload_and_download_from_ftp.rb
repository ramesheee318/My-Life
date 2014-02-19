require 'rubygems'
require "ruby-debug"
require 'net/ftp'
require 'ftools' # smiller to fileutils used to create mkdir.
require 'fileutils'
require 'zip/zip' #  gem 'rubyzip', :require => 'zip/zip'
require 'find'

#Usable : Inside LAN ( 192.168.0.0/16)/ Locally.
#Internet Protocol Address (IP Address) :192.168.47.200
#FTP user name: ftpuser
#FTP user password: ftpuser123

# http://dev.mensfeld.pl/2011/12/using-ruby-and-zip-library-to-compress-directories-and-read-single-file-from-compressed-collection/

class AutomatingFileUploadAndDownloadFromFtp
 def self.ftp_upload(zip_dir, ftp_dir, ip, user, password)
    Net::FTP.open("#{ip}") do |ftp|
      ftp.login("#{user}","#{password}")
      puts "****************************** Successfully LOGIN ON FTP Server, TIME: #{Time.now.strftime("%H:%M:%S")} ****************************"
      puts "connected the ftp server"
      begin
        ftp.mkdir("DataUpload")
      rescue
        puts "folder already exists"
      end
      ftp.chdir("DataUpload")
      ftp.putbinaryfile(zip_dir, ftp_dir)
    end
      puts "*********** &&&&&&&&&& Successfully ftp connection closed &&&&&&&& ***************************"
  end

  def self.ftp_download(zip_dir, ftp_dir, ip, user, password)
    Net::FTP.open("#{ip}") do |ftp|
      ftp.login("#{user}","#{password}")
      puts "****************************** Successfully LOGIN ON FTP Server, TIME: #{Time.now.strftime("%H:%M:%S")} ****************************"
      puts "connected the ftp server"
      ftp.chdir("DataUpload")
      begin
         ftp.size("#{ftp_dir}")
         rescue
           puts "This zip file #{ftp_dir} not exists in FTP"
      end
      debugger
      ftp.getbinaryfile(zip_dir, ftp_dir, 1024)
    end
    puts "*********** &&&&&&&&&& Successfully ftp connection closed &&&&&&&& ***************************"
  end

 
 
  def self.zip(dir, remove_after)
    new_dir = dir.gsub("#{dir.split('/').last}","")
    zip_dir = "#{new_dir}#{(Time.now - 1.days).strftime("%Y-%m-%d")}.zip"
    puts "--------------START----------------->#{Time.now.strftime("%d-%m-%Y %H:%M:%S")}"
    Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE)do |zipfile|
      Find.find(dir) do |path|
        Find.prune if File.basename(path)[0] == ?.
        dest = /#{dir}\/(\w.*)/.match(path)
        # Skip files if they exists
        begin
          zipfile.add(dest[1],path) if dest
        rescue Zip::ZipEntryExistsError
        end
      end
      puts "-----------------END-------------->#{Time.now.strftime("%d-%m-%Y %H:%M:%S")}"
    end
    puts "-----------------TOTAL-------------->#{Time.now.strftime("%d-%m-%Y %H:%M:%S")}"
    FileUtils.rm_rf(dir) if remove_after
    return zip_dir
  end
  
   def self.unzip(zip, unzip_dir, remove_after)
     puts "--------------START----------------->#{Time.now.strftime("%d-%m-%Y %H:%M:%S")}"
    Zip::ZipFile.open(zip) do |zip_file|
      zip_file.each do |f|
        f_path=File.join(unzip_dir, f.name)
      if File.exists?(f_path) and FileUtils.rm_rf(f_path)
       zip_file.extract(f, f_path)
      else
        zip_file.extract(f, f_path)
      end
      end
      puts "-----------------END-------------->#{Time.now.strftime("%d-%m-%Y %H:%M:%S")}"
    end
    puts "-----------------TOTAL-------------->#{Time.now.strftime("%d-%m-%Y %H:%M:%S")}"
   `chmod -R 777 "#{unzip_dir}"`
  FileUtils.rm(zip) if remove_after
  end
  
end


