class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :uid
      t.string :service
      t.integer :prio
      t.string :uri
      t.timestamps
    end
  end
end
