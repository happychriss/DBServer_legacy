class Log < ActiveRecord::Base

  ERROR=1
  STATUS=0

  attr_accessible :message, :source, :messagetype

  def self.write_status(source,message)
    log = Log.new(:source => source, :message => message,:messagetype => STATUS )
    log.save!
  end

  def self.write_error(source,message)
    log = Log.new(:source => source, :message => message,:messagetype => ERROR )
    log.save!
  end

  def self.check_errors?
    Log.find_all_by_messagetype(ERROR).count>0
  end

  def self.clear_all
    Log.delete_all
  end


end
