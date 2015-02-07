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

  scope :not_in_progress, -> { where.not(state: 'in_progress') }
  enum state: ['in_progress', 'in_queue', 'in_delivery', 'delivered', 'canceled']
  aasm :column => :state, :enum => true do
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
    if credit_card.nil? || self.user.orders.where(credit_card: credit_card).any?
      credit_card = CreditCard.find_or_create_by(credit_card_params)
      if credit_card.invalid?
        credit_card.errors.full_messages.each {|error| self.errors[:base] << error }
        return false
      end
      self.update(:credit_card => credit_card)
    else
      result = credit_card.update(credit_card_params)
      credit_card.errors.full_messages.each {|error| self.errors[:base] << error } unless result
      return result
    end
  end

  def self.get_in_progress_one(user)
    user.orders.find_or_create_by(:state => 'in_progress')
  end

  def self.get_submitted_ones(user)
    user.orders.where.not(:state => 'in_progress').order(state: :asc, completed_at: :desc)
  end

  def self.get_last_submitted_one(user)
    user.orders.where.not(:state => 'in_progress', :completed_at => nil).order(completed_at: :desc).first
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

  def totals
    set_totals if @total_price.nil?
    '$' +@total_price.to_s + ' (' + @total_items.to_s + ')'
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
