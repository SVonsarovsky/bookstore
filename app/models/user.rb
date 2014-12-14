class User < ActiveRecord::Base
  validates :email, :password, presence: true
  validates :email, uniqueness: true
end
