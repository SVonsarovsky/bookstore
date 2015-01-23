class Author < ActiveRecord::Base
  has_and_belongs_to_many :books
  def name
    first_name + ' ' + last_name
  end

  validates_associated :books
  validates :first_name, :last_name, :description, presence: true
end
