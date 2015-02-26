require 'rails_helper'

RSpec.describe Address, :type => :model do
  let(:address) { FactoryGirl.create :address }

  it 'has a street address' do
    expect(address).to validate_presence_of(:address)
  end

  it 'has a zip code' do
    expect(address).to validate_presence_of(:zip_code)
  end

  it 'has a zip code only in correct format' do
    expect(address).to allow_value('12345').for(:zip_code)
  end

  it 'has a city' do
    expect(address).to validate_presence_of(:city)
  end

  it 'has a phone' do
    expect(address).to validate_presence_of(:phone)
  end

  it 'has a country' do
    expect(address).to validate_presence_of(:country)
  end

  it 'belongs to country' do
    expect(address).to belong_to(:country)
  end

  it 'has a user' do
    expect(address).to validate_presence_of(:user)
  end

  it 'belongs to user' do
    expect(address).to belong_to(:user)
  end

  describe '#used_in_placed_orders?' do
    context 'when address was used as both billing and shipping address' do
      it 'returns true' do
        FactoryGirl.create(:order_not_in_progress, billing_address: address, shipping_address: address, user: address.user)
        expect(address).to be_used_in_placed_orders
      end
    end

    context 'when address was used as billing address' do
      it 'returns true' do
        FactoryGirl.create(:order_not_in_progress, billing_address: address, user: address.user)
        expect(address).to be_used_in_placed_orders
      end
    end

    context 'when address was used as shipping address' do
      it 'returns true' do
        FactoryGirl.create(:order_not_in_progress, shipping_address: address, user: address.user)
        expect(address.used_in_placed_orders?).to eq true
      end
    end

    context 'when address was not used before' do
      it 'returns false' do
        FactoryGirl.create(:order_not_in_progress, user: address.user)
        expect(address).not_to be_used_in_placed_orders
      end
    end

    context 'when there are no placed orders' do
      it 'returns false' do
        FactoryGirl.create(:order, user: address.user)
        expect(address).not_to be_used_in_placed_orders
      end
    end
  end

end
