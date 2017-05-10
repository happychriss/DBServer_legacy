class RenameConnectionsToConnectors < ActiveRecord::Migration
def change
  rename_table :connections ,:connector
end
end
