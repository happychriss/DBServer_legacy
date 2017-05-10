class RemoveColumnPreview < ActiveRecord::Migration
def change
  remove_column :pages, :preview
end
end
