class CreditCard < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  validates :user, :number, :code, :expiration_month, :expiration_year, presence: true

  def display_number
    '**** **** **** '+number.to_s.slice(-4..-1)
  end
end
