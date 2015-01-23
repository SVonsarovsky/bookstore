class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.text :short_description
      t.text :full_description
      t.decimal :price, precision: 10, scale: 4

      t.timestamps
    end
  end
end
