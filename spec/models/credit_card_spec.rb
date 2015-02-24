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
    expect(credit_card).to allow_value('3120-0000-0000-0034').for(:number)
  end

  it 'has a code' do
    expect(credit_card).to validate_presence_of(:code)
  end

  it 'has a code in format 000' do
    expect(credit_card).to allow_value('312').for(:code)
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

  describe '#used_in_placed_orders?' do
    context 'when credit card was used in one of the previously placed orders' do
      it 'returns true' do
        FactoryGirl.create(:order_not_in_progress, credit_card: credit_card, user: credit_card.user)
        expect(credit_card).to be_used_in_placed_orders
      end
    end

    context 'when credit card was not used in the previously placed orders' do
      it 'returns false' do
        FactoryGirl.create(:order_not_in_progress, user: credit_card.user)
        expect(credit_card).not_to be_used_in_placed_orders
      end
    end

    context 'when there are no placed orders' do
      it 'returns false' do
        FactoryGirl.create(:order, user: credit_card.user)
        expect(credit_card).not_to be_used_in_placed_orders
      end
    end
  end

end
