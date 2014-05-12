pid_path_of_delayed_job = File.expand_path('../../tmp/pids/delayed_job.pid',  __FILE__)
puts "#{pid_path_of_delayed_job}"

def start_delayed_job
  #set up nil value in env variable    
  env = ARGV[1]
  # Don't  Process  class used to stop and start for delayed job(WHY it is chcek for all rails application in the server)
  #Process.spawn("ruby script/delayed_job start")
  system({ "RAILS_ENV" => env}, "ruby script/delayed_job start")
  puts "delayed_job ready."
end

def process_is_dead?
  begin
    pid = File.read(pid_path_of_delayed_job).strip
    Process.kill(0, pid.to_i)
    puts "cleaning up delayed job pid..."
    false
  rescue
    true
  end
end


if !File.exist?(pid_path_of_delayed_job) && process_is_dead?
  start_delayed_job
else
 pid = File.read(pid_path_of_delayed_job).strip
 puts "delayed job already running this port: #{pid.to_i}"
end

