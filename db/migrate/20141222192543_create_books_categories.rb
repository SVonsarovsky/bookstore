class CreateBooksCategories < ActiveRecord::Migration
  def change
    create_table :books_categories, id: false do |t|
      t.references :book, index: true
      t.references :category, index: true
    end
    add_index :books_categories, [:book_id, :category_id]
  end
end
