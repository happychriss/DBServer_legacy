class AddNoDeleteToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :no_delete, :boolean
  end
end
