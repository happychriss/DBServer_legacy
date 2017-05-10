class AddShortnameCoverInToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :cover_ind, :boolean
    add_column :folders, :short_name, :string
  end
end
