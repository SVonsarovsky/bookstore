require 'rails_helper'

RSpec.describe Review, :type => :model do

  let(:review) { FactoryGirl.create(:review) }

  it 'has a user' do
    expect(review).to validate_presence_of(:user)
  end

  it 'belongs to user' do
    expect(review).to belong_to(:user)
  end

  it 'has a book' do
    expect(review).to validate_presence_of(:book)
  end

  it 'belongs to book' do
    expect(review).to belong_to(:book)
  end

  it 'has a text' do
    expect(review).to validate_presence_of(:text)
  end

  it 'gets a review' do
    expect(review).to respond_to(:review)
  end

  it 'has a rating' do
    expect(review).to validate_presence_of(:rating)
  end

  it 'has an integer rating' do
    expect(order).to validate_numericality_of(:rating).only_integer
  end

  it "has a rating which is between #{Review::MIN_RATING} and #{Review::MAX_RATING}" do
    expect(review.rating).to be_between(Review::MIN_RATING, Review::MAX_RATING)
  end

end