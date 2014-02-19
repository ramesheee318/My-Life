require 'rubygems'

    file= File.open("/home/rameshs/Desktop/ttttt.log","r")
    @components_time_taken= []
    @render_time_take=[]
@test1 = []
@test2 = []

    while(line = file.gets)
        @others_time_taken=[]
        if(line[/Processing/])
        elsif(matches = line.match(/\s(Component:)\s+([\w|,|-]*).*Total Time taken\s+=\s+(\w+.\w+).*(Served from Cache\?)\s+=\s+(\w+).*(Cached\?)\s+=\s+(\w+)/))
          split =  $3.to_f

          if  split < 0.02
             @test1 << "#{line}"
          end

          if  split > 0.02
             @components_time_taken << "#{line}"
             @test1 << "#{line}"
          end
        elsif(line[/Site Name/])
        elsif(line.match(/((\d+.\d+)ms\))/))
         if $2.to_f > 200.00
        #puts $2
         end

              

        if line.match(/Rendered .*\((\d+.\d+)ms\)/)
          if $1.to_f < 400.00
                       @test2 << "#{line}"

           end


           if $1.to_f > 400.00
            @render_time_take << "#{line}" #if line.match(/Rendered .*\((\d+.\d+)ms\)/)

           end
          end

        elsif(line[/End rendering/])
        elsif(line[/Completed/])
          line.match(/Completed in ((\d+)ms).*\[(http:.*)\]/)
          value = $1.to_i
 if value < 2000
    puts "#{$3}"
    puts "#{$1}"
    puts "#{@test1}"
    puts "#{@test2}"

 @test1 = []
 @test2 = []
 end

puts "==================================="
          if value > 2000
             if value > 5000
             end
             puts "#{$3}"
             puts "#{$1}"
             puts  "#{@components_time_taken}"
             puts "#{@render_time_take}"
             @components_time_taken= []
             @render_time_take = []
          end
        end
    end

