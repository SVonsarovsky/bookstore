class ShippingMethod < ActiveRecord::Base
  STATES = %w(inactive, active)
  scope :active, -> { where state: 'active' }
  validates :name, :cost, :state, presence: true
  validates :name, uniqueness: true
  enum state: STATES
  def state_enum
    STATES
  end
end
