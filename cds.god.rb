CDSERVER_ROOT="//home/cds/CDServer"
CDDAEMON_ROOT="//home/cds/CDDaemon"
CDSERVER_PID = "//tmp"
CDSERVER_LOG= "#{CDSERVER_ROOT}/log"
NGINX_ROOT="/usr/local/nginx/sbin" #config in /usr/local/nginx/conf/nginx.conf
THIN_ROOT="//home/cds/.rvm/gems/ruby-2.1.0/bin/thin"
THIN_CONFIG=File.join(CDSERVER_ROOT,"thin_nginx.yml")
RVM_BIN="//home/cds/.rvm/bin"


## e.g. bootup_rake in RVM Bin folder
def rvm_bin(daemon)
  return File.join(RVM_BIN,"bootup_"+daemon+" ")
end

God.watch do |w|
  w.name          = "sphinx"
  w.group         ='cds'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.interval      = 60.seconds
  w.dir           = CDSERVER_ROOT
  w.env 	  = {'RAILS_ENV' => "production" }
  w.start         = rvm_bin('rake')+"ts:start"
  w.stop          = rvm_bin('rake')+"ts:stop"
  w.restart       = rvm_bin('rake')+"ts:restart"
  w.pid_file      = File.join(CDSERVER_,PID'searchd.production.pid')
  w.keepalive
end

God.watch do |w|
  w.name          = 'sidekiq'
  w.group         = 'cds'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.stop_grace    = 10.seconds
  w.interval      = 60.seconds
  w.dir           = CDSERVER_ROOT
  w.start         = rvm_bin('bundle')+"exec sidekiq -e production -c 3 -P #{CDSERVER_PID}/sidekiq.pid"
  w.stop          = rvm_bin('bundle')+"exec sidekiqctl stop #{CDSERVER_PID}/sidekiq.pid 5"
  w.keepalive
  w.log           = File.join(CDSERVER_LOG, 'sidekiq.log')
  w.behavior(:clean_pid_file)
#  w.env           = {'HOME' => '/root'} ## for gpg
end

God.watch do |w|
  w.name          = 'clockwork'
  w.group         = 'cds'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.stop_grace    = 10.seconds
  w.interval      = 60.seconds
  w.dir           = CDSERVER_ROOT

  w.start         = rvm_bin('bundle')+"exec clockwork ./services/cdserver_maintenance_job.rb & echo $! > #{CDSERVER_PID}/clockwork.pid"
  w.stop          = "kill -QUIT `cat #{CDSERVER_PID}/clockwork.pid`"
  w.keepalive
  w.log           = File.join(CDSERVER_LOG, 'clockwork.log')
  w.behavior(:clean_pid_file)
  w.env           = {'RAILS_ENV' => "production" }
  w.pid_file      = "#{CDSERVER_PID}/clockwork.pid"
end

God.watch do |w|
  w.name          = "thin"
  w.group         ='cds'
  w.dir           = CDSERVER_ROOT
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.interval      = 60.seconds
  w.start         = rvm_bin('thin')+"start --config ./thin_nginx.yml --log #{CDSERVER_LOG}/thin.log --pid //tmp/thin.pid"
  w.stop          = rvm_bin('thin')+"stop --pid //tmp/thin.pid"
  w.restart       = rvm_bin('thin')+"restart"
  w.pid_file      = "//tmp/thin.pid" 
  w.log           = "#{CDSERVER_LOG}/thin.log"  
  w.keepalive
end

#fayae - privat pub gem from ryan
God.watch do |w|
  w.name          = "private_pub"
  w.group         ='cds'
  w.dir           = CDSERVER_ROOT
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.interval      = 60.seconds
  w.env           = {'RAILS_ENV' => "production" }
  w.start         = rvm_bin('rackup')+"private_pub.ru -s thin -E production -P #{CDSERVER_PID}/private_pub.pid"

  w.log           = File.join(CDSERVER_LOG, 'private_pub.log')
  w.pid_file      = "#{CDSERVER_PID}/private_pub.pid"
#   w.stop_signal = 'KILL'
  w.keepalive
end

#avahi daemon to regester the converter and scanner
God.watch do |w|
  w.name 	  = "avahi"  
  w.group         ='cds'
  w.dir           = CDSERVER_ROOT  
  w.start = rvm_bin('bundle')+"exec ruby #{CDSERVER_ROOT}/services/avahi_service_start_port.rb -p 8082 -e production"
  w.log           = "#{CDSERVER_LOG}/avahi.log"  
  w.keepalive
end

################# Not part of CDServer #########################################################################
#scanner server, in case scanner is connected with cubietrack
God.watch do |w|
  w.start_grace   = 10.seconds
  w.name 	  ='scanner_daemon'
  w.group         ='cds'
  w.dir           = CDDAEMON_ROOT
  w.start         = rvm_bin('bundle')+"exec ruby #{CDDAEMON_ROOT}/cdclient_daemon.rb --service Scanner --uid 101 --prio 1 --subnet 192.168.1 --port 8971 --avahiprefix production --unpaper_speed y"
  w.log           = "#{CDDAEMON_ROOT}/cdscanner.log"  
  w.keepalive
end

God.watch do |w|
  w.start_grace   = 10.seconds
  w.name 	  ='hardware_daemon'
  w.group         ='cds'
  w.dir           = CDDAEMON_ROOT
  w.start         = rvm_bin('bundle')+"exec ruby #{CDDAEMON_ROOT}/cdclient_daemon.rb --service Hardware --uid 102 --prio 0 --subnet 192.168.1 --port 8972 --avahiprefix production --gpio_server ct --gpio_port 8780"
  w.log           = "#{CDDAEMON_ROOT}/cdhardware.log"
  w.keepalive
end
