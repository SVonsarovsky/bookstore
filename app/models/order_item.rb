class OrderItem < ActiveRecord::Base
  belongs_to :book
  belongs_to :order
  validates :book, :order, :price, :quantity, presence: true
  validates :quantity, numericality: {greater_than: 0}

end
