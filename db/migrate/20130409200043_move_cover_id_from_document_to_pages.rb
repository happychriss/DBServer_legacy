class MoveCoverIdFromDocumentToPages < ActiveRecord::Migration
def change
  remove_column :documents, :cover_id
  add_column :pages, :cover_id, :integer
end
end
