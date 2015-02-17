class Order < ActiveRecord::Base
  include AASM

  has_many :order_items, dependent: :destroy
  belongs_to :user
  belongs_to :credit_card
  belongs_to :shipping_method
  belongs_to :billing_address, class_name: 'Address'
  belongs_to :shipping_address, class_name: 'Address'

  validates :number, uniqueness: true
  validates :shipping_cost, numericality: {:greater_than_or_equal_to => 0}, allow_blank: true
  validates :state, :user, presence: true

  scope :not_in_progress, -> { where.not(state: 'in_progress') }

  enum state: %w(in_progress in_queue in_delivery delivered canceled)
  aasm :column => :state, :enum => true, :whiny_transitions => false do
    state :in_progress, :initial => true
    state :in_queue
    state :in_delivery
    state :delivered
    state :canceled

    event :checkout, :after => :update_sold_count do
      transitions :from => :in_progress, :to => :in_queue
    end
    event :confirm do
      transitions :from => :in_queue, :to => :in_delivery
    end
    event :cancel do
      transitions :from => :in_queue, :to => :canceled
    end
    event :deliver do
      transitions :from => :in_delivery, :to => :delivered
    end
  end

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

  def save_credit_card(credit_card_params = {})
    credit_card = self.credit_card
    if (credit_card.nil? || credit_card.used_in_placed_orders?)
      credit_card = CreditCard.find_or_create_by(credit_card_params)
      credit_card.valid? && self.update(:credit_card => credit_card)
    else
      credit_card.update(credit_card_params)
    end
  end

  def status
    self.state == 'in_queue' ? 'waiting for processing' : self.state.tr('_', ' ')
  end

  def display_number
    'R'+self.number.to_s
  end

  def total_price
    set_totals if @total_price.nil?
    @total_price
  end

  def total_items
    set_totals if @total_items.nil?
    @total_items
  end

  def books
    self.order_items.includes(:book).references(:book)
  end

  protected
  def update_sold_count
    self.order_items.each do |item|
      Book.update(item.book_id, :sold_count => OrderItem.where(book_id: item.book_id).sum(:quantity))
    end
  end

  def set_totals
    totals = self.order_items.select('SUM(quantity) as quantity, SUM(quantity*price) as price').first
    @total_price = totals.price.nil? ? 0 : totals.price
    @total_items = totals.quantity.nil? ? 0 : totals.quantity
  end

end
