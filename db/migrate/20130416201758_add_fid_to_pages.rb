class AddFidToPages < ActiveRecord::Migration
  def change
    add_column :pages, :fid, :integer
  end
end
