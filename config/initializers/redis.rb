$redis = Redis.new(:host => 'localhost', :port => 6379)
$redis.set("upload_count","0")
$redis.set("backup_count","0")

