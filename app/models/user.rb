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
    type_address_index = (type+'_address').to_sym
    type_address_value = self.send(type_address_index)
    if type_address_value.nil? || self.billing_address_id == self.shipping_address_id || self.orders.
          where('billing_address_id = :addr_id OR shipping_address_id = :addr_id', addr_id: type_address_value.id).any?
      type_address_value = Address.find_or_create_by(type_address_params)
      if type_address_value.invalid?
        type_address_value.errors.full_messages.each {|error| self.errors[:base] << error }
        return false
      end
      self.update(type_address_index => type_address_value)
    else
      result = type_address_value.update(type_address_params)
      type_address_value.errors.full_messages.each {|error| self.errors[:base] << error } unless result
      return result
    end
  end
end
