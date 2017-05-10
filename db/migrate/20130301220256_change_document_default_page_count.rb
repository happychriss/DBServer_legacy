class ChangeDocumentDefaultPageCount < ActiveRecord::Migration
  def change
    change_column_default(:documents, :page_count, 0)
  end

end
