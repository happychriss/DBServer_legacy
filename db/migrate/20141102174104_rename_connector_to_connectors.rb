class RenameConnectorToConnectors < ActiveRecord::Migration
rename_table :connector, :connectors
end
