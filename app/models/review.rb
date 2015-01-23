class Review < ActiveRecord::Base
  MIN_RATING = 1;
  MAX_RATING = 5;
  belongs_to :user
  belongs_to :book
  validates :user, :book, :text, :rating, presence: true
  validates :rating, numericality: {only_integer: true, greater_than_or_equal_to: MIN_RATING, less_than_or_equal_to: MAX_RATING}

  def review
    text.length > 97 ? text.slice(0, 97).concat('...') : text;
  end
end
