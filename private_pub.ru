# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "faye/mixins/logging"
require "private_pub"

Faye::WebSocket.load_adapter('thin')

#Enable logging
#Faye.logger = Logger.new(STDOUT)


PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")
run PrivatePub.faye_app


#You can use nginx, but it does not support WebSockets. This means the Faye client will be unable to
# use WebSockets and will be fal back to a slower network transport.                                                                                                                                                          It's not Thin you're putting into production mode, it's Rack. In development mode, Rack adds some middlewares that are incompatible with async servers -- Faye uses Thin's async responses for long-polling and sockets.
#
#    You could probably spin thin up using the `thin` executable instead, although I've not tried
# so I don't know what middlewares get added in that case.
#


