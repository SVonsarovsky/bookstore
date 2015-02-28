require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { FactoryGirl.create :user }

  it 'has an email' do
    expect(user).to validate_presence_of(:email)
  end

  it 'has a unique email' do
    expect(user).to validate_uniqueness_of(:email)
  end

  it 'gets a name' do
    expect(user).to respond_to(:name)
  end

  it 'has a current password' do
    expect(user).to respond_to(:current_password)
  end

  it 'has a password' do
    expect(user).to respond_to(:password)
  end

  it 'has a password confirmation' do
    expect(user).to respond_to(:password_confirmation)
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

  it 'gets a billing address' do
    expect(user).to respond_to(:billing_address)
  end

  it 'belongs to billing address' do
    expect(user).to belong_to(:billing_address)
  end

  it 'gets a shipping address' do
    expect(user).to respond_to(:shipping_address)
  end

  it 'belongs to shipping address' do
    expect(user).to belong_to(:shipping_address)
  end

  describe '#save_address' do
    let(:address_params) { FactoryGirl.attributes_for(:address, user: user) }

    it 'updates data of address previously saved for the order' do
      address = FactoryGirl.create(:address, user: user)
      user.update(billing_address_id: address.id)
      expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
      expect(User.find(user.id).billing_address_id).to eq address.id
    end

    context 'when address is invalid' do
      it 'returns false ' do
        rand_123_number = [1, 2, 3].sample
        address_params[:address]  = '' if (rand_123_number&1 > 0)
        address_params[:zip_code] = '' if (rand_123_number&2 > 0)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq false
      end
    end

    context 'when address was not set previously' do
      it 'creates new address and set it to user' do
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(user.billing_address.id).to be > 0
      end

      it 'finds existing address and set it to user' do
        address = FactoryGirl.create(:address, address_params)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(User.find(user.id).billing_address_id).to eq address.id
      end
    end

    context 'when billing and shipping address ids are the same' do
      it 'creates new address and set it to user' do
        address = FactoryGirl.create(:address, user: user)
        user.update(billing_address_id: address.id, shipping_address_id: address.id)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(User.find(user.id).billing_address_id).not_to eq address.id
      end

      it 'finds existing address and set it to user' do
        address = FactoryGirl.create(:address, address_params)
        user.update(billing_address_id: address.id, shipping_address_id: address.id)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(User.find(user.id).billing_address_id).to eq address.id
      end
    end

    context 'when address was used in placed orders' do
      it 'creates new address and set it to user' do
        address = FactoryGirl.create(:address, user: user)
        user.update(billing_address_id: address.id)
        FactoryGirl.create(:order_not_in_progress, user: user, billing_address: address)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(User.find(user.id).billing_address_id).not_to eq address.id
      end

      it 'finds existing address and set it to user' do
        address = FactoryGirl.create(:address, address_params)
        FactoryGirl.create(:order_not_in_progress, user: user, billing_address: address)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(User.find(user.id).billing_address_id).to eq address.id
      end
    end
  end

  describe '#order_in_progress' do
    context 'when order in progress has not existed before' do
      it 'creates and returns order in progress' do
        order_in_progress = user.order_in_progress
        expect(order_in_progress).to be_a Order
        expect(order_in_progress.state).to eq Order::STATE_IN_PROGRESS
      end
    end
    context 'when order in progress was created before' do
      it 'returns order in progress' do
        order = FactoryGirl.create(:order, user: user)
        order_in_progress = user.order_in_progress
        expect(order.id).to eq order_in_progress.id
      end
    end
  end

  context '#placed_orders' do
    it 'returns orders with status different from "in_progress"' do
      order1 = FactoryGirl.create(:order_not_in_progress, user: user)
      order2 = FactoryGirl.create(:order_not_in_progress, user: user)
      expect(user.placed_orders).to include(order1)
      expect(user.placed_orders).to include(order2)
      expect(user.placed_orders.length).to eq 2
    end
    it 'does not return order with different state' do
      order = FactoryGirl.create(:order, user: user)
      expect(user.placed_orders).not_to include(order)
    end
  end

  context '#last_placed_order' do
    it 'returns last placed order' do
      order1 = FactoryGirl.create(:order_not_in_progress, user: user)
      order2 = FactoryGirl.create(:order_not_in_progress, user: user) if order1.persisted?
      expect(user.last_placed_order.id).to eq(order2.id)
    end
    it 'does not return just last order, only placed order' do
      order = FactoryGirl.create(:order_not_in_progress, user: user)
              FactoryGirl.create(:order,                 user: user)
      expect(user.last_placed_order.id).to eq(order.id)
    end
  end

  context '#last_credit_card' do
    it 'returns last credit card' do
                    FactoryGirl.create(:credit_card, user: user)
      credit_card = FactoryGirl.create(:credit_card, user: user)
      expect(user.last_credit_card.id).to eq(credit_card.id)
    end
  end

end
