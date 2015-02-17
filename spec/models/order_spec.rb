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

  it 'gets a status' do
    expect(order).to respond_to(:status)
  end

  it 'has a user' do
    expect(order).to validate_presence_of(:user)
  end

  it 'belongs to user' do
    expect(order).to belong_to(:user)
  end

  it 'has a credit card' do
    expect(order).to respond_to :credit_card
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

  context '.not_in_progress' do
    it 'does not include orders with state "in_progress"' do
      order_in_progress = FactoryGirl.create(:order, state: 'in_progress')
      expect(Order.not_in_progress).not_to include(order_in_progress)
    end

    it 'includes orders with state different from "in_progress"' do
      order_not_in_progress = FactoryGirl.create(:order, state: %w(in_queue in_delivery delivered canceled).sample)
      expect(Order.not_in_progress).to include(order_not_in_progress)
    end
  end

  context 'aasm events' do

    def successful_event(event, state_from, state_to)
      order = FactoryGirl.create(:order, state: state_from)
      state_before = order.state
      checkout_result = order.send("#{event}!")
      state_after = order.state
      expect(checkout_result).to eq true
      expect(state_before).to eq state_from
      expect(state_after).to eq state_to
    end

    def unsuccessful_event(event, initial_states)
      order = FactoryGirl.create(:order, state: initial_states.sample)
      state_before = order.state
      checkout_result = order.send("#{event}!")
      state_after = order.state
      expect(checkout_result).to eq false
      expect(state_before).to eq state_after
    end

    context '#checkout' do
      it 'changes state from "in_progress" to "in_queue"' do
        successful_event('checkout', 'in_progress', 'in_queue')
      end

      it 'does not change state when it is different from "in_progress"' do
        unsuccessful_event('checkout', %w(in_queue in_delivery delivered canceled))
      end

      it 'calls update_sold_count in case of checkout event' do
        expect(order).to receive(:update_sold_count)
        order.checkout
      end
    end

    context '#confirm' do
      it 'changes state from "in_queue" to "in_delivery"' do
        successful_event('confirm', 'in_queue', 'in_delivery')
      end

      it 'does not change state when it is different from "in_queue"' do
        unsuccessful_event('confirm', %w(in_progress in_delivery delivered canceled))
      end
    end

    context '#cancel' do
      it 'changes state from "in_queue" to "canceled"' do
        successful_event('cancel', 'in_queue', 'canceled')
      end

      it 'does not change state when it is different from "in_queue"' do
        unsuccessful_event('cancel', %w(in_progress in_delivery delivered canceled))
      end
    end

    context '#deliver' do
      it 'changes state from "in_delivery" to "delivered"' do
        successful_event('deliver', 'in_delivery', 'delivered')
      end

      it 'does not change state when it is different from "in_delivery"' do
        unsuccessful_event('deliver', %w(in_progress in_queue delivered canceled))
      end
    end
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

  context '#save_credit_card' do
    before(:all) do
      @user = FactoryGirl.create(:user)
    end
    let(:credit_card) {FactoryGirl.create(:credit_card, user: @user)}
    let(:credit_card_params) {FactoryGirl.attributes_for(:credit_card, user: @user)}

    context 'when credit card was not set previously' do
      let(:order) {FactoryGirl.create(:order, user: @user)}

      it 'creates new credit card and set it to order' do
        expect(order.save_credit_card(credit_card_params)).to eq true
        expect(order.credit_card.id).to be > 0
      end

      it 'finds existing credit card and set it to order' do
        credit_card_params = {
            :number => credit_card.number,
            :expiration_year => credit_card.expiration_year,
            :expiration_month => credit_card.expiration_month,
            :code => credit_card.code,
            :user => @user
        }
        expect(order.save_credit_card(credit_card_params)).to eq true
        expect(Order.find(order.id).credit_card_id).to eq credit_card.id
      end
    end

    context 'when credit card was used in placed orders' do
      before(:each) do
        FactoryGirl.create(:order, user: @user, credit_card: credit_card,
                           completed_at: Time.zone.now, state: %w(in_queue in_delivery delivered canceled).sample)
      end
      let(:order) {FactoryGirl.create(:order, user: @user, credit_card: credit_card)}

      it 'creates new credit card and set it to order' do
        expect(order.save_credit_card(credit_card_params)).to eq true
        expect(Order.find(order.id).credit_card_id).not_to eq credit_card.id
      end

      it 'finds existing credit card and set it to order' do
        credit_card_params = {
            :number => credit_card.number,
            :expiration_year => credit_card.expiration_year,
            :expiration_month => credit_card.expiration_month,
            :code => credit_card.code,
            :user => @user
        }
        expect(order.save_credit_card(credit_card_params)).to eq true
        expect(Order.find(order.id).credit_card_id).to eq credit_card.id
      end
    end

    it 'returns false if credit card is invalid' do
      order = FactoryGirl.create(:order, user: @user)
      rand_123_number = [1, 2, 3].sample
      credit_card_params[:number] = '' if (rand_123_number&1 > 0)
      credit_card_params[:code]   = '' if (rand_123_number&2 > 0)
      expect(order.save_credit_card(credit_card_params)).to eq false
    end

    it 'updates data of the credit card previously saved for the order' do
      order = FactoryGirl.create(:order, user: @user, credit_card: credit_card)
      expect(order.save_credit_card(credit_card_params)).to eq true
      expect(Order.find(order.id).credit_card_id).to eq credit_card.id
    end
  end

  context '#update_sold_count' do
    it 'updates sold_count param for each book in order' do
      book1 = FactoryGirl.create(:book)
      book2 = FactoryGirl.create(:book)
      order.add_book(book1, 1)
      order.add_book(book2, 3)
      order.send(:update_sold_count)
      expect(Book.find(book1.id).sold_count).to eq 1
      expect(Book.find(book2.id).sold_count).to eq 3
    end
  end

  context '#set_totals' do
    it 'sets order total price' do
      book1 = FactoryGirl.create(:book)
      book2 = FactoryGirl.create(:book)
      order.add_book(book1, 5)
      order.add_book(book2, 2)
      order.send(:set_totals)
      expect(order.total_items).to eq 7
    end

    it 'sets order total items quantity' do
      book1 = FactoryGirl.create(:book, price: 1.99)
      book2 = FactoryGirl.create(:book, price: 2.99)
      order.add_book(book1, 1)
      order.add_book(book2, 2)
      order.send(:set_totals)
      expect(order.total_price).to eq 7.97
    end
  end

end