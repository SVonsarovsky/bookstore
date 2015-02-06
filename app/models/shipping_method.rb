class ShippingMethod < ActiveRecord::Base
  scope :active, -> { where state: 'active' }
  validates :name, :cost, presence: true
  enum state: ['inactive', 'active']
  def state_enum
    ['inactive', 'active']
  end
end