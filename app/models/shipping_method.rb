class ShippingMethod < ActiveRecord::Base
  scope :active, -> { where state: 'active' }
  validates :name, :cost, :state, presence: true
  validates :name, uniqueness: true
  enum state: %w(inactive, active)
  def state_enum
    %w(inactive, active)
  end
end
