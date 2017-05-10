class AddFolderIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :folder_id, :integer
  end
end
