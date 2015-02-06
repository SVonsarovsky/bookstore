class Address < ActiveRecord::Base
  belongs_to :country
  belongs_to :user
  validates :first_name, :last_name, :address, :zip_code, :city, :phone, :country, :user, presence: true
end
