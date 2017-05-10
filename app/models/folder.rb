class Folder < ActiveRecord::Base

  MIGRATION_FOLDER = 9999

  attr_accessible :name, :short_name , :cover_ind
  has_many :documents
  has_many :covers
  default_scope :order => 'name'
  default_scope where ("id < #{Folder::MIGRATION_FOLDER}")

end
