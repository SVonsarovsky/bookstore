class Book < ActiveRecord::Base
  BESTSELLERS_COUNT = 5

  has_and_belongs_to_many :categories
  has_and_belongs_to_many :authors
  has_many :reviews, dependent: :destroy
  has_many :order_items
  validates :categories, :authors, presence: true
  validates :title, :price, :short_description, :full_description, presence: true

  mount_uploader :image, ImageUploader
  paginates_per 9

  def self.bestsellers
    Book.order('sold_count DESC').limit(self::BESTSELLERS_COUNT)
  end
end
