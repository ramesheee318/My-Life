#  /usr/local/rubyencoder-1.3/bin/./rubyencoder -r -b  --ruby 1.9.3 /home/code/rameshs/app/
require 'net/ssh'
require 'net/sftp'
require 'ruby-debug'
require 'rubygems'
require 'ftools'
#ruby script/runner Encryption.local_file
class Encryption
  def self.local_file
    remote_host = '192.168.10.12'
    remote_user = 'code'
    remote_pass = 'code@ramesh'
    version = '1.9.3'
    ##############Local server deatils############################################
    user_folder_name = ("#{Rails.root}").split('/')[2]
    basedir = "/home/#{user_folder_name}/"
    Dir.chdir(basedir)
debugger
    report_folder = (FileUtils.mkdir_p "Encryptions").first
    report_path="#{basedir}/#{report_folder}"
debugger
    Dir.chdir("#{report_path}")
    puts "================#{Time.now.strftime("%d/%m/%y :%I:%M:%S %p")}==============="
     inside_folder_path = (FileUtils.mkdir_p "encryption").first
    local_file_path = "/home/busind/CMS/Admin/lib/migration_sec.rb"
    which_file = local_file_path.split('/').last
    file_dir  =  File.dirname("#{local_file_path}")
    Net::SSH.start( remote_host, remote_user, :password => remote_pass ) do |ssh|
      ssh.exec!("pwd") 
      puts "Success-fully connected to remote server"
      ssh.exec!("cd /home/code/ && mkdir Ecryption_folder")
      ssh.exec!("cd /home/code/Ecryption_folder/ && pwd")
      ssh.exec! "cd /home/code/Ecryption_folder/ && mkdir #{user_folder_name}"
      ssh.exec!("cd /home/code/Ecryption_folder/#{user_folder_name}/ && mkdir #{inside_folder_path}")
      ssh.exec!("cd /home/code/Ecryption_folder/#{user_folder_name}/#{inside_folder_path}  && pwd")
      
      ssh.sftp.upload!("#{file_dir}/#{which_file}", "/home/code/Ecryption_folder/#{user_folder_name}/#{inside_folder_path}/#{which_file}")
      
      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      puts "This #{which_file} file there #{user_folder_name}/#{inside_folder_path}/#{which_file}"
      puts "Encryption done for #{which_file} on remote server"  if ssh.exec! "/usr/local/rubyencoder-1.3/bin/./rubyencoder -r -b  --ruby #{version} //home/code/Ecryption_folder/#{user_folder_name}/#{inside_folder_path}/#{which_file}"
      puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      # else
      #  puts "This #{single_file} file not there  #{user_folder_name}/#{inside_folder_path}/#{single_file}"
      #end
      
      ssh.sftp.download!("/home/code/Ecryption_folder/#{user_folder_name}/#{inside_folder_path}/#{which_file}", "#{report_path}/#{inside_folder_path}/#{which_file}")
      puts "f+e+t+c+h+e+d"
      
      
      ssh.exec! "cd /home/code/Ecryption_folder/#{user_folder_name} && rm -rf *"
      
      puts "========================================"
      puts "||   FILE REMOVED FROM REMOTE SERVER   ||"
      puts "|| *****************************************SUCCESS-FULLY DOWNLOADED ||" 
      puts "======================================================================"
      
      
    end
  end
end
