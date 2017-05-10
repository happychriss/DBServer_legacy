class DocumentChangedefaultvaluePageCount < ActiveRecord::Migration


  change_column :documents, :page_count,:integer ,:default => 1

end
