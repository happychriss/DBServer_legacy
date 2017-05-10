class RenameNoCompletePdfFromDocuments < ActiveRecord::Migration
  def change
    rename_column :documents, :no_complete_pdf, :complete_pdf
  end

end
