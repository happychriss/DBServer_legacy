class AddToDocumentsDeleteAt < ActiveRecord::Migration
  def change
    add_column :documents, :delete_at, :date
  end

end
