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

  context '#get_books' do
    it 'includes books with current category' do
      book = FactoryGirl.create(:book, categories: [category])
      expect(category.get_books(1)).to include(book)
    end

    it 'does not include books with other categories' do
      book = FactoryGirl.create(:book)
      expect(category.get_books(1)).not_to include(book)
    end

    it 'returns books within current category in order by title' do
      book1 = FactoryGirl.create(:book, title: 'Book 01', categories: [category])
      book2 = FactoryGirl.create(:book, title: 'Book 02', categories: [category])
      expect(category.get_books(1).first.id).to eq book1.id
      expect(category.get_books(1).last.id).to eq book2.id
    end

    it "returns not more than #{Book.default_per_page} books" do
      FactoryGirl.create_list(:book, Book.default_per_page+10, categories: [category])
      expect(category.get_books(1).length).to be <= Book.default_per_page
    end
  end
end
