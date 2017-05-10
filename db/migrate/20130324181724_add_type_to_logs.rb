class AddTypeToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :type, :integer
  end
end
