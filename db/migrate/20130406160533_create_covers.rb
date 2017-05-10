class CreateCovers < ActiveRecord::Migration
  def change
    create_table :covers do |t|
      t.integer :folder_id

      t.timestamps
    end
  end
end
