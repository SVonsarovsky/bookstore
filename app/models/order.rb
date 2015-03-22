class Order < ActiveRecord::Base
  STATES = %w(in_progress in_queue in_delivery delivered canceled)
  STATE_IN_PROGRESS = 'in_progress'

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

  scope :not_in_progress, -> { where.not(state: STATE_IN_PROGRESS) }

  enum state: STATES
  aasm :column => :state, :enum => true, :whiny_transitions => false do
    state :in_progress, :initial => true
    state :in_queue
    state :in_delivery
    state :delivered
    state :canceled

    event :checkout, :before => :set_completed_at, :after => :update_sold_count do
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
    I18n.t("order.states.#{self.state}")
  end

  def display_number
    'R'+self.number.to_s
  end

  def total_price
    @total_price = self.order_items.sum('quantity*price') if @total_price.nil?
    @total_price
  end

  def total_items
    @total_items = self.order_items.sum(:quantity) if @total_items.nil?
    @total_items
  end

  def books
    self.order_items.includes(:book).references(:book)
  end

  protected
  def set_completed_at
    self.completed_at = Time.zone.now
  end

  def update_sold_count
    return false if self.state == STATE_IN_PROGRESS
    self.order_items.each do |item|
      Book.where(id: item.book_id).update_all("sold_count = sold_count + #{item.quantity}")
    end
    return true
  end
end
