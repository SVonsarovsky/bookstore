require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { FactoryGirl.create :user }

  it 'has an email' do
    expect(user).to validate_presence_of(:email)
  end

  it 'has a unique email' do
    expect(user).to validate_uniqueness_of(:email)
  end

  it 'has a name' do
    expect(user).to respond_to (:name)
  end

  it 'has a password' do
    expect(user).to respond_to (:password)
  end

  it 'has many reviews' do
    expect(user).to have_many(:reviews)
  end

  it 'has many orders' do
    expect(user).to have_many(:orders)
  end

  it 'has many credit_cards' do
    expect(user).to have_many(:credit_cards)
  end

  it 'has many addresses' do
    expect(user).to have_many(:addresses)
  end

  it 'has a billing address' do
    expect(user).to respond_to (:billing_address)
  end

  it 'belongs to billing address' do
    expect(user).to belong_to(:billing_address)
  end

  it 'has a shipping address' do
    expect(user).to respond_to (:shipping_address)
  end

  it 'belongs to shipping address' do
    expect(user).to belong_to(:shipping_address)
  end

  context '#save_address (there are more cases than 3 ones mentioned below)' do
    xit 'update current address data'
    xit 'creates new address and save it for user'
    xit 'find existing address and save it for user'
  end

  context '#get_order_in_progress' do
    xit 'returns order'
    xit 'returns order in progress'
  end

  context '#get_placed_orders' do
    xit 'returns orders'
    xit 'returns orders with status different from "in_progress"'
  end

  context '#get_last_placed_order' do
    xit 'returns order'
    xit 'returns order with status different from "in_progress"'
  end

end
