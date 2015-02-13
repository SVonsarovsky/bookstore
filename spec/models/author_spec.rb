require 'rails_helper'

RSpec.describe Author, :type => :model do

  let(:author) { FactoryGirl.create :author }

  it 'has a first name' do
    expect(author).to validate_presence_of(:first_name)
  end

  it 'has a last name' do
    expect(author).to validate_presence_of(:last_name)
  end

  it 'has a name' do
    expect(author).to respond_to(:name)
  end

  it 'has a description' do
    expect(author).to validate_presence_of(:description)
  end

  it 'has and belongs to many books' do
    expect(author).to have_and_belong_to_many(:books)
  end

end