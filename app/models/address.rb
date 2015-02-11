class Address < ActiveRecord::Base
  belongs_to :country
  belongs_to :user
  validates :first_name, :last_name, :address, :zip_code, :city, :phone, :country, :user, presence: true

  def used_in_placed_orders?
    self.user.orders.not_in_progress.where('billing_address_id = :id OR shipping_address_id = :id', id: self.id).any?
  end
end
