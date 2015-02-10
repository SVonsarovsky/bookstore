require 'rails_helper'

RSpec.describe Country, :type => :model do

  let(:country) { FactoryGirl.create :country }

  it 'has a name' do
    expect(country).to validate_presence_of(:name)
  end

  it 'has a unique name' do
    expect(country).to validate_uniqueness_of(:name)
  end

  it 'has many addresses' do
    expect(country).to have_many(:addresses)
  end

end