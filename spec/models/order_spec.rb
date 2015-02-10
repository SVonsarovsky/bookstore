require 'rails_helper'

RSpec.describe Order, :type => :model do

  let(:order) { FactoryGirl.create :order }

  it 'is able to return a total price of the order' do
    expect(order).to respond_to :total_price
  end

  it 'is able to return an amount of items in the order' do
    expect(order).to respond_to :total_items
  end

  it 'is able to return books' do
    expect(order).to respond_to :books
  end

  it 'is able to return display number' do
    expect(order).to respond_to :display_number
  end

  it 'has a completed date' do
    expect(order).to respond_to(:completed_at)
  end

  it 'has a unique number' do
    expect(order).to validate_uniqueness_of(:number)
  end

  it 'has a state' do
    expect(order).to validate_presence_of(:state)
  end

  it 'has a default state "in_progress"' do
    expect(order.state).to eq 'in_progress'
  end

  it 'has a status' do
    expect(order).to respond_to(:status)
  end

  it 'has a user' do
    expect(order).to validate_presence_of(:user)
  end

  it 'belongs to user' do
    expect(order).to belong_to(:user)
  end

  it 'belongs to credit card' do
    expect(order).to belong_to(:credit_card)
  end

  it 'has many order items' do
    expect(order).to have_many(:order_items)
  end

  it 'has a billing address' do
    expect(order).to respond_to :billing_address
  end

  it 'belongs to billing address' do
    expect(order).to belong_to(:billing_address)
  end

  it 'has a shipping address' do
    expect(order).to respond_to :shipping_address
  end

  it 'belongs to shipping address' do
    expect(order).to belong_to(:shipping_address)
  end

  it 'has a numeric shipping cost greater or equal to 0' do
    expect(order).to validate_numericality_of(:shipping_cost).is_greater_than_or_equal_to(0)
  end

  context '#add_book' do
    it 'is able to add a book to the order' do
      book = FactoryGirl.create(:book)
      order.add_book(book, 1)
      expect(order.order_items.where(book: book).count).to eq 1
    end

    it 'is able to add the same book only once' do
      book = FactoryGirl.create(:book)
      order.add_book(book, 1)
      order.add_book(book, 1)
      expect(order.order_items.where(book: book).count).to eq 1
    end
    it 'is able to add the same book by increasing its quantity in order item' do
      book = FactoryGirl.create(:book)
      order.add_book(book, 1)
      order.add_book(book, 2)
      expect(order.order_items.where(book: book).sum(:quantity)).to eq 3
    end
  end

  context '#save_credit_card (there are more cases than 3 ones mentioned below)' do
    xit 'update current credit card data'
    xit 'creates new credit card and save it in order'
    xit 'find existing credit card and save it in order'
  end

  context '.get_in_progress_one' do
    xit 'returns order'
    xit 'returns order in progress'
  end

  context '.get_submitted_ones' do
    xit 'returns orders'
    xit 'returns orders with status different from "in_progress"'
  end

  context '.get_last_submitted_one' do
    xit 'returns order'
    xit 'returns order with status different from "in_progress"'
  end


end