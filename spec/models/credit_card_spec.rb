require 'rails_helper'

RSpec.describe CreditCard, :type => :model do

  let(:credit_card) { FactoryGirl.create(:credit_card) }

  it 'has a user' do
    expect(credit_card).to validate_presence_of(:user)
  end

  it 'belongs to user' do
    expect(credit_card).to belong_to(:user)
  end

  it 'has many orders' do
    expect(credit_card).to have_many(:orders)
  end

  it 'has a number' do
    expect(credit_card).to validate_presence_of(:number)
  end

  it 'has a number in format 0000-0000-0000-0000' do
    expect(credit_card.number).to match(/[0-9]{4}\-[0-9]{4}\-[0-9]{4}\-[0-9]{4}/)
  end

  it 'has a code' do
    expect(credit_card).to validate_presence_of(:code)
  end

  it 'has a code in format 000' do
    expect(credit_card.code).to match(/[0-9]{3}/)
  end

  it 'has an expiration_month' do
    expect(credit_card).to validate_presence_of(:expiration_month)
  end

  it 'has an expiration_year' do
    expect(credit_card).to validate_presence_of(:expiration_year)
  end

  it 'gets a display number' do
    expect(credit_card).to respond_to(:display_number)
  end

  it 'gets a display month' do
    expect(credit_card).to respond_to(:display_month)
  end

  it "gets a months' list" do
    expect(credit_card).to respond_to(:month_list)
  end

  it "gets a years' list" do
    expect(credit_card).to respond_to(:year_list)
  end

  context '#used_in_placed_orders?' do
    xit 'returns true if used'
    xit 'returns false if not used'
  end

end
