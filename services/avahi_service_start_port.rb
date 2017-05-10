require 'dnssd'

Signal.trap("INT") do
  puts "\nTerminated"
$stdout.flush
  exit
end

port=0;env=''
 ARGV.each_with_index do|a,i|
          port=ARGV[i+1].to_i if a=='-p'
	  env =ARGV[i+1]      if a=='-e'

end
puts "****** Start avahi register***"
puts "Port:#{port} and Name:Cleandesk_#{env}"
$stdout.flush
DNSSD.register! "Cleandesk_#{env}", '_cds._tcp', nil, port
puts "****** Completed avahi register***"
$stdout.flush
sleep
