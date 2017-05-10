class Tag < ActiveRecord::Base
 has_many :taggings, :dependent => :destroy
 attr_accessible :name
end
