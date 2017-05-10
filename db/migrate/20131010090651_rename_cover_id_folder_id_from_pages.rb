class RenameCoverIdFolderIdFromPages < ActiveRecord::Migration
  def change
    rename_column :pages, :folder_id, :org_folder_id
    rename_column :pages, :cover_id, :org_cover_id
  end
end
