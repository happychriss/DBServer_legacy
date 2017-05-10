class AddMessagetypeToLogs < ActiveRecord::Migration
      def change
      add_column :logs, :messagetype, :integer
    end
  end
