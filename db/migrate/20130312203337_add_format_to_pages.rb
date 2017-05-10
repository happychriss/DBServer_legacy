class AddFormatToPages < ActiveRecord::Migration
  def change
    add_column :pages, :format, :integer
  end
end
