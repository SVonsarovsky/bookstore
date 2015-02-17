require 'rails_helper'

RSpec.describe Address, :type => :model do
  let(:address) { FactoryGirl.create :address }

  it 'has a street address' do
    expect(address).to validate_presence_of(:address)
  end

  it 'has a zip code' do
    expect(address).to validate_presence_of(:zip_code)
  end

  it 'has a zip code in correct format' do
    expect(address.zip_code).to match(/[0-9]{5}/)
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

  context '#used_in_placed_orders?' do
    let(:states_not_in_progress) { %w(in_queue in_delivery delivered canceled) }
    it 'returns true if used as billing address' do
      FactoryGirl.create(:order, state: states_not_in_progress.sample, billing_address: address, user: address.user)
      expect(address.used_in_placed_orders?).to eq true
    end
    it 'returns true if used as shipping address' do
      FactoryGirl.create(:order, state: states_not_in_progress.sample, shipping_address: address, user: address.user)
      expect(address.used_in_placed_orders?).to eq true
    end
    it 'returns false if not used' do
      FactoryGirl.create(:order, state: states_not_in_progress.sample, user: address.user)
      expect(address.used_in_placed_orders?).to eq false
    end
    it 'returns false if there are no placed orders' do
      FactoryGirl.create(:order)
      expect(address.used_in_placed_orders?).to eq false
    end
  end

end
