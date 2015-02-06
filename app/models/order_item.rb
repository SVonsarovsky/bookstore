class OrderItem < ActiveRecord::Base
  belongs_to :book
  belongs_to :order
  validates :book, :order, :price, :quantity, presence: true
  validates :quantity, numericality: {greater_than: 0}

  def name
    book = self.book
    book.title + ' by ' + book.authors.map{|author| author.name }.join(', ') + ' ('+self.quantity.to_s+', $'+self.price.to_s+')'
  end
end
