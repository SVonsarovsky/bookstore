class AddSoldCountToBooks < ActiveRecord::Migration
  def change
    add_column :books, :sold_count, :integer, default: 0
  end
end
