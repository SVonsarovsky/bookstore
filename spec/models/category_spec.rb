require 'rails_helper'

RSpec.describe Category, :type => :model do

  let(:category) { FactoryGirl.create :category }

  it 'has a name' do
    expect(category).to validate_presence_of(:name)
  end

  it 'has a unique name' do
    expect(category).to validate_uniqueness_of(:name)
  end

  it 'has and belongs to many books' do
    expect(category).to have_and_belong_to_many(:books)
  end
end
