class Category < ActiveRecord::Base
  has_and_belongs_to_many :books

  validates_associated :books
  validates :name, presence: true, uniqueness: true

  def get_books(page)
    Book.includes(:books_categories).references(:books_categories).
        where('books_categories.category_id = ?', self.id).order(:title).page(page)
  end

end
