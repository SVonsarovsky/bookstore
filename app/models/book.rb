class Book < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :authors
  has_many :reviews
  validates :categories, :authors, presence: true
  validates :title, :price, :short_description, presence: true

  #accepts_nested_attributes_for :authors, :allow_destroy => true
  mount_uploader :image, ImageUploader
  paginates_per 1

  def self.bestsellers
    Book.all
  end
end
