class AddFileTypeToPages < ActiveRecord::Migration
  def change
    add_column :pages, :file_type, :string
  end
end
