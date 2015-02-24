require 'rails_helper'

RSpec.describe Book, :type => :model do
  let(:book) { FactoryGirl.create(:book) }

  it 'has a title' do
    expect(book).to validate_presence_of(:title)
  end

  it 'has a price' do
    expect(book).to validate_presence_of(:price)
  end

  it 'has a short description' do
    expect(book).to validate_presence_of(:short_description)
  end

  it 'has a full description' do
    expect(book).to validate_presence_of(:full_description)
  end

  it 'has categories' do
    expect(book).to validate_presence_of(:categories)
  end

  it 'has and belongs to many categories' do
    expect(book).to have_and_belong_to_many(:categories)
  end

  it 'has authors' do
    expect(book).to validate_presence_of(:authors)
  end

  it 'has and belongs to many authors' do
    expect(book).to have_and_belong_to_many(:authors)
  end

  it 'has many reviews' do
    expect(book).to have_many(:reviews)
  end

  it 'has many order items' do
    expect(book).to have_many(:order_items)
  end

  describe '.bestsellers' do
    it 'returns books in order by sold_count DESC' do
      book1 = FactoryGirl.create(:book, sold_count: 1)
              FactoryGirl.create(:book, sold_count: 2)
      book3 = FactoryGirl.create(:book, sold_count: 3)
      expect(Book.bestsellers.first.id).to eq book3.id
      expect(Book.bestsellers.last.id).to eq book1.id
    end

    context "when there are more than #{Book::BESTSELLERS_COUNT} books" do
      it "returns #{Book::BESTSELLERS_COUNT} books" do
        (1..(Book::BESTSELLERS_COUNT+1)).each do
          FactoryGirl.create(:book)
        end
        expect(Book.bestsellers.length).to eq Book::BESTSELLERS_COUNT
      end
    end

    context "when there are less or equal than #{Book::BESTSELLERS_COUNT} books" do
      it 'returns amount of all books' do
        (1..rand(2..Book::BESTSELLERS_COUNT)).each do
          FactoryGirl.create(:book)
        end
        expect(Book.bestsellers.length).to eq Book.all.length
      end
    end
  end

end