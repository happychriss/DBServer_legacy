class AddNoPdfToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :no_complete_pdf, :boolean, :default =>false
  end
end
