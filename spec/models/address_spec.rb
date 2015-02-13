require 'rails_helper'

RSpec.describe Address, :type => :model do
  let(:address) { FactoryGirl.create :address }

  it 'has a street address' do
    expect(address).to validate_presence_of(:address)
  end

  it 'has a zip code' do
    expect(address).to validate_presence_of(:zip_code)
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
    xit 'returns true if used'
    xit 'returns false if not used'
  end

end
