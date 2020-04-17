require 'socket'
require 'timeout'
task_1_new = true #not done

puts "Start Script"
server = TCPServer.new 8085 # Server bind to port 2000
puts "Server Port opened"

loop do
  client = server.accept # Wait for a client to connect
  puts "Accepted connection"
  res = client.readline
  task, value = res.split(':')
  value=value.chop.chop
  puts "Got: #{value} for task:#{task}"
  case task
  when '1'
    if task_1_new
	puts "New"
      task_1_new = false
      tres=""
	begin
      status=Timeout::timeout(30) {
	     tres = %x[veracrypt //media/ssd_external/xm3.vc //tst_share --password=#{value} --non-interactive --fs-options="uid=1003,gid=1005,umask=0002" 2>&1]
	}
     rescue Timeout::Error
	puts "Error Timeout"
        tres="O:Timeout"
        task_1_new=true
	end
	puts "done with:"+tres+"<-"
      client.puts "N:"+tres+"."+"\n"
    else
	puts "Old"
      task_1_new = true
     tres = %x[veracrypt -d /media/ssd_external/xm3.vc]
puts "done with:"+tres+"<-"
      client.puts "O:"+tres+"."+"\n"
    end
  else
    puts "Unkown request: #{res}"

  end

  client.close
end
