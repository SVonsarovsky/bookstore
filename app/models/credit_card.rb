class CreditCard < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  validates :user, :number, :expiration_month, :expiration_year, presence: true
  validates :number, format: { with: /[0-9]{4}\-[0-9]{4}\-[0-9]{4}\-[0-9]{4}/ }, presence: true
  validates :code, format: { with: /[0-9]{3}/ }, presence: true

  def display_number
    '****-****-****-'+number.to_s.slice(-4..-1)
  end

  def display_month
    expiration_month.to_s.rjust(2, '0')
  end

  def month_list
    (1..12).map{|month| [month.to_s.rjust(2, '0'), month]}
  end

  def year_list
    first_year = Time.now.year
    last_year = first_year+7
    (first_year..last_year).map{|year| [year, year]}
  end

  def used_in_placed_order?
    self.user.orders.not_in_progress.where(credit_card: self).any?
  end
end
