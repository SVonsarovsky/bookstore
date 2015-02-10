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

  belongs_to :billing_address, class_name: 'Address'
  belongs_to :shipping_address, class_name: 'Address'

  def name
    email.split('@').first
  end

  def save_address(type = 'billing', type_address_params = {})
    address_index = (type+'_address').to_sym
    address = self.send(address_index)
    if (address.nil? || self.billing_address_id == self.shipping_address_id || self.orders.not_in_progress.
          where('billing_address_id = :addr_id OR shipping_address_id = :addr_id', addr_id: address.id).any?)
      address = Address.find_or_create_by(type_address_params)
      self.update(address_index => address)
    else
      address.update(type_address_params)
    end
  end

  def get_order_in_progress
    self.orders.find_or_create_by(:state => 'in_progress')
  end

  def get_placed_orders
    self.orders.not_in_progress.order(state: :asc, completed_at: :desc)
  end

  def get_last_placed_order
    self.orders.not_in_progress.where.not(:completed_at => nil).order(completed_at: :desc).first
  end

end
