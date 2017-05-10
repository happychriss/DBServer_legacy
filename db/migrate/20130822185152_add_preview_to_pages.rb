class AddPreviewToPages < ActiveRecord::Migration
  def change
    add_column :pages, :preview, :boolean,:default => false
  end
end
