class AddCounterToCovers < ActiveRecord::Migration
  def change
    add_column :covers, :counter, :integer
  end
end
