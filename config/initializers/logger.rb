Rails.logger = Logger.new(STDOUT)

def log(msg)
  Rails.logger.info(Time.now.to_s+" : " +msg.to_s)
end