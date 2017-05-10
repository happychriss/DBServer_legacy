class AddCoverIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :cover_id, :integer
  end
end
