class AddOcrToPages < ActiveRecord::Migration
  def change
    add_column :pages, :ocr, :boolean,  :default => false
    Page.update_all("ocr=1") ##set defual to OCR for all existing pages
  end
end
