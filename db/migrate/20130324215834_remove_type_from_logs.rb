class RemoveTypeFromLogs < ActiveRecord::Migration
  def change
    remove_column :logs, :type
    end
end
