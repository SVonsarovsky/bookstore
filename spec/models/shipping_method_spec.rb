require 'rails_helper'

RSpec.describe ShippingMethod, :type => :model do

  let(:shipping_method) { FactoryGirl.create :shipping_method }

  it 'has a name' do
    expect(shipping_method).to validate_presence_of(:name)
  end

  it 'has a unique name' do
    expect(shipping_method).to validate_uniqueness_of(:name)
  end

  it 'has a cost' do
    expect(shipping_method).to validate_presence_of(:cost)
  end

  it 'has a state' do
    expect(shipping_method).to validate_presence_of(:state)
  end

  it 'has a default state "active"' do
    expect(shipping_method.state).to eq 'active'
  end

  it 'active scope should return only active methods' do
    expect(ShippingMethod.active.where_values_hash).to eq 'state' => 1
  end

end
