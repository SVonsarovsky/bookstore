require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { FactoryGirl.create :user }
  let(:states_not_in_progress) { %w(in_queue in_delivery delivered canceled) }

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

  context '#save_address' do
    let(:address_params) { FactoryGirl.attributes_for(:address, user: user) }
    it 'returns false if address is invalid' do
      rand_123_number = [1, 2, 3].sample
      address_params[:address]  = '' if (rand_123_number&1 > 0)
      address_params[:zip_code] = '' if (rand_123_number&2 > 0)
      expect(user.save_address(address_params.merge(:type => 'billing'))).to eq false
    end

    it 'updates data of address previously saved for the order' do
      address = FactoryGirl.create(:address, user: user)
      user.update(billing_address_id: address.id)
      expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
      expect(User.find(user.id).billing_address_id).to eq address.id
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
        FactoryGirl.create(:order, user: user, billing_address: address,
                           completed_at: Time.zone.now, state: states_not_in_progress.sample)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(User.find(user.id).billing_address_id).not_to eq address.id
      end

      it 'finds existing address and set it to user' do
        address = FactoryGirl.create(:address, address_params)
        FactoryGirl.create(:order, user: user, billing_address: address,
                           completed_at: Time.zone.now, state: states_not_in_progress.sample)
        expect(user.save_address(address_params.merge(:type => 'billing'))).to eq true
        expect(User.find(user.id).billing_address_id).to eq address.id
      end
    end
  end

  context '#get_order_in_progress' do
    it 'creates and returns order in progress if it did not exist before' do
      order_in_progress = user.get_order_in_progress
      expect(order_in_progress).to be_a Order
      expect(order_in_progress.status).to eq 'in progress'
    end
    it 'returns order in progress if it was created before' do
      order = FactoryGirl.create(:order, state: 'in_progress', user: user)
      order_in_progress = user.get_order_in_progress
      expect(order.id).to eq order_in_progress.id
    end
  end

  context '#get_placed_orders' do
    it 'returns orders with status different from "in_progress" and completed time' do
      order1 = FactoryGirl.create(:order, user: user, state: states_not_in_progress.sample, completed_at: Time.zone.now)
      order2 = FactoryGirl.create(:order, user: user, state: states_not_in_progress.sample, completed_at: Time.zone.now)
      expect(user.get_placed_orders).to include(order1)
      expect(user.get_placed_orders).to include(order2)
      expect(user.get_placed_orders.length).to eq 2
    end
    it 'does not return order with different state' do
      order = FactoryGirl.create(:order, user: user)
      expect(user.get_placed_orders).not_to include(order)
    end
    it 'does not return order without completed time' do
      order = FactoryGirl.create(:order, user: user, state: states_not_in_progress.sample)
      expect(user.get_placed_orders).not_to include(order)
    end
  end

  context '#get_last_placed_order' do
    it 'returns last placed order' do
              FactoryGirl.create(:order, user: user, state: states_not_in_progress.sample, completed_at: Time.zone.now)
      order = FactoryGirl.create(:order, user: user, state: states_not_in_progress.sample, completed_at: Time.zone.now)
      expect(user.get_last_placed_order.id).to eq(order.id)
    end
    it 'does not return just last order, only placed order' do
      order = FactoryGirl.create(:order, user: user, state: states_not_in_progress.sample, completed_at: Time.zone.now)
              FactoryGirl.create(:order, user: user)
      expect(user.get_last_placed_order.id).to eq(order.id)
    end
  end

  context '#get_last_credit_card' do
    it 'returns last credit card' do
                    FactoryGirl.create(:credit_card, user: user)
      credit_card = FactoryGirl.create(:credit_card, user: user)
      expect(user.get_last_credit_card.id).to eq(credit_card.id)
    end
  end

end
