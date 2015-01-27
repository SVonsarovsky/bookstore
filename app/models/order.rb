class Order < ActiveRecord::Base
  has_many :order_items, dependent: :destroy
  belongs_to :user
  enum state: ['in progress', 'in queue', 'in delivery', 'delivered', 'canceled']
  validates :user, presence: true
  validates :total_price, numericality: {:greater_than_or_equal_to => 0}, allow_blank: true

  def add_book(book, quantity)
    order = self
    order_item = order.order_items.find_by(:book => book)
    if order_item.nil?
      order_item = OrderItem.new({:book => book, :order => order, :price => book.price, :quantity => quantity})
    else
      order_item.quantity += quantity
    end
    order_item.save
  end

  def self.get_in_progress_one(user)
    order = Order.where(:user => user, :state => 'in progress').first
    order = Order.create(user: user, state: 'in progress') if order.nil?
    order
  end

  def update_total_price
    total_price = 0
    total_items = 0
    self.order_items.each do |order_item|
      total_items += order_item.quantity
      total_price += (order_item.price * order_item.quantity)
    end
    self.total_price = total_price
    self.total_items = total_items
    self.save
  end

end
