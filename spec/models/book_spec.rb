require 'rails_helper'

RSpec.describe Book, :type => :model do

  let(:book) { FactoryGirl.create(:book) }

  it 'has a title' do
    expect(book).to validate_presence_of(:title)
  end

  it 'has a price' do
    expect(book).to validate_presence_of(:price)
  end

  it 'has a short description' do
    expect(book).to validate_presence_of(:short_description)
  end

  it 'has a full description' do
    expect(book).to validate_presence_of(:full_description)
  end

  it 'has categories' do
    expect(book).to validate_presence_of(:categories)
  end

  it 'has and belongs to many categories' do
    expect(book).to have_and_belong_to_many(:categories)
  end

  it 'has authors' do
    expect(book).to validate_presence_of(:authors)
  end

  it 'has and belongs to many authors' do
    expect(book).to have_and_belong_to_many(:authors)
  end

  it 'has many reviews' do
    expect(book).to have_many(:reviews)
  end

  it 'has many order items' do
    expect(book).to have_many(:order_items)
  end

  context '.bestsellers' do
    xit 'returns data in correct order'
    xit 'limits data in correct way'
  end

end