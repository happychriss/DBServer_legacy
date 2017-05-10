class RenameFileTypeFromPages < ActiveRecord::Migration
  def change
    rename_column :pages, :file_type, :mime_type
  end

end
