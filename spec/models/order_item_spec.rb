require 'rails_helper'

RSpec.describe OrderItem, :type => :model do

  let(:order_item) { FactoryGirl.create(:order_item) }

  it 'has a book' do
    expect(order_item).to validate_presence_of(:book)
  end

  it 'belongs to book' do
    expect(order_item).to belong_to(:book)
  end

  it 'has an order' do
    expect(order_item).to validate_presence_of(:order)
  end

  it 'belongs to order' do
    expect(order_item).to belong_to(:order)
  end

  it 'has a name' do
    expect(order_item).to respond_to(:name)
  end

  it 'has a price' do
    expect(order_item).to validate_presence_of(:price)
  end

  it 'has a quantity' do
    expect(order_item).to validate_presence_of(:quantity)
  end

  it 'has a numeric quantity greater than 0' do
    expect(order_item).to validate_numericality_of(:quantity).only_integer.is_greater_than(0)
  end

end