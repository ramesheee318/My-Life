require 'rubygems'
#require "ruby-debug"

class PerformanceTest
  attr_reader :path_settings
  attr_reader :urls
  attr_reader :errors
  
  def initialize
    @path = {
      #:command_file => "/home/bala/Desktop/postgres_pt/production.log",
              :input_log_file => "/home/rameshs/Desktop/ttttt.log",
              :report_dir => "/home/oldbackup/home/rameshs/kailash/Desktop/today" }
    @urls=[]
  end
  
  def report
    return unless valid?(@path)
    #@urls = commands(@path[:command_file])
    #run(@path[:command_file])
    generate_report(@path[:input_log_file], @path[:report_dir])
  end
  
  def valid?(paths)
    not paths.collect do |key, path| 
      if File.exist?(path)
        true
      else
        puts "="*10 + key.to_s + " " + path
        false
      end
      end.include?(false)
    end
    
    def commands(command_path)
      log_file = File.open(command_path, "r")
      logs = log_file.read
      log_file.close
      logs.split("\n").collect{|url| url.strip}
    end
    
    def run(command_file_path)
      wgettrashfiles = `pwd`.strip + "/wgettrashfiles"
      `mkdir wgettrashfiles`
      system "wget -i #{command_file_path} -P #{wgettrashfiles}"
      system "rm -r #{wgettrashfiles}"
    end
    
    def generate_report(ip_file_path, op_file_path)      

      
      ip_file = File.open(ip_file_path, "r")

      op_file = File.open(op_file_path.gsub(/\/$/,"") + '/' + Time.now.strftime("%Y-%m-%d-%H%M%S-PerfomanceTest").to_s, "w")
      op_file.puts("Performance test report from live" + "\n\n\n\n" )
      op_file.puts("Url" +"," + "Component" + "\n\n" )

      
        #@sitename = ""
        #@username = ""
        @timetaken = ""
        #@processtime = ""
      while(line = ip_file.gets)
        @components_time_taken=[]
        @others_time_taken=[]
        
        if(line[/Processing/])
          #@processtime =line
          #op_file.puts(line + "\n")
          #@components_time_taken=[]
          #@others_time_taken=[]
        elsif(matches = line.match(/\s(Component:)\s+([\w|,|-]*).*Total Time taken\s+=\s+(\w+.\w+).*(Served from Cache\?)\s+=\s+(\w+).*(Cached\?)\s+=\s+(\w+)/))
          #      elsif(matches = line.match(  (    $1    )   (   $2  )                         (   $3  )  (         $4        )       ( $5)  )
          split =  $3.to_f
          @components_time_taken << $3.to_f if $3.to_f
          if  split > 0.02
            op_file.puts( $1 + $2.rjust(20) + $3.rjust(15)+','+$4.rjust(15)+$5.rjust(5)+','+$6.rjust(15)+$7.rjust(5))
          end
          #op_file.puts( $1 + $2.rjust(20) + $3.rjust(15) )
          #op_file.puts( $4.rjust(10))
        elsif(line[/Site Name/])
          #@sitename=line
        elsif(line[/User Name/])
          #@username=line
         ####@timetaken = []
        ####elsif(line[/Time taken for/])
        ####@timetaken << line
    #      op_file.puts(line)
          #elsif(line[/Time taken for/])
          # op_file.puts(line)
          #line[/.*\s=\s([0-9e].*)/].nil? ? "" : (@others_time_taken << $1.to_f)
          
        elsif(line[/Completed/])
          #op_file.puts("\nTotal Time Taken of Components  =  #{@components_time_taken.inject(0){|sum, time| sum + time}.to_s}s\n")
          line.match(/Completed in ((\d+)ms).*\[(http:.*)\]/)
          value = $1.to_i
          if value > 1000
 	    #op_file.puts(@processtime)            
            #op_file.puts(@sitename)
  	    #op_file.puts(@username)
            ####op_file.puts(@timetaken)
            op_file.puts("( "+ $1 + " )" + $3 + "\n\n")
          end
        end
      end
      
      op_file.close
      ip_file.close
    end
    
    def self.debug
      @perf_test = PerformanceTest.new
      @perf_test.report
    end
    
  end
  
  @perf_test = PerformanceTest.new
  @perf_test.report
