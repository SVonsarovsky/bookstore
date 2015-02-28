class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :photo, PhotoUploader
  has_many :orders, dependent: :nullify
  has_many :reviews, dependent: :destroy
  has_many :credit_cards, dependent: :destroy
  has_many :addresses, dependent: :nullify
  validates :email, presence: true, uniqueness: true
  #accepts_nested_attributes_for :credit_cards

  belongs_to :billing_address, class_name: 'Address'
  belongs_to :shipping_address, class_name: 'Address'

  def name
    email.split('@').first
  end

  def save_address(address_params = {})
    address_index = (address_params[:type]+'_address').to_sym
    address_params.delete(:type)
    address = self.send(address_index)
    if (address.nil? || self.billing_address_id == self.shipping_address_id || address.used_in_placed_orders?)
      address = Address.find_or_create_by(address_params)
      address.valid? && self.update(address_index => address)
    else
      address.update(address_params)
    end
  end

  def order_in_progress
    self.orders.find_or_create_by(:state => Order::STATE_IN_PROGRESS)
  end

  def placed_orders
    self.orders.not_in_progress.order(state: :asc, completed_at: :desc)
  end

  def last_placed_order
    self.orders.not_in_progress.order(completed_at: :desc, id: :desc).first
  end

  def last_credit_card
    self.credit_cards.order('id DESC').first
  end

end
