# Connection stores the DRB connection information, that is used to call remote objects like scanner / converter
# see lib ServiceConnector.rb

class Connector < ActiveRecord::Base

  attr_accessible :uri, :prio, :service, :uid
  validates_uniqueness_of :uid

  def self.find_service(service)
    Connector.find_all_by_service(service,:order => "prio desc").first # high prio, high number -> highest prio first
  end

end
