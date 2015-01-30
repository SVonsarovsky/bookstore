class Order < ActiveRecord::Base
  has_many :order_items, dependent: :destroy
  belongs_to :user
  enum state: ['in progress', 'in queue', 'in delivery', 'delivered', 'canceled']
  validates :user, presence: true
  validates :number, uniqueness: true
  validates :total_price, numericality: {:greater_than_or_equal_to => 0}, allow_blank: true

  after_create do |order|
    begin
    end while !order.update(number: rand(100000000..999999999))
  end

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
    user.orders.find_or_create_by(:state => 'in progress')
  end

  def total_price
    #@total_price = self.order_items.sum('quantity*price') if @total_price.nil?
    set_totals if @total_price.nil?
    @total_price
  end

  def total_items
    #@total_items = self.order_items.sum(:quantity) if @total_items.nil?
    set_totals if @total_items.nil?
    @total_items
  end

  protected
  def set_totals
    totals = self.order_items.select('SUM(quantity) as quantity, SUM(quantity*price) as price').first
    @total_price = totals.price.nil? ? 0 : totals.price
    @total_items = totals.quantity.nil? ? 0 : totals.quantity
  end

end
