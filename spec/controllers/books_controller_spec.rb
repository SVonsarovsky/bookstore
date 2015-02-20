require 'rails_helper'

describe BooksController do
  let(:book) { FactoryGirl.build_stubbed(:book) }

  before(:each) do
    allow(controller).to receive(:last_open_page)
  end

  describe 'GET #home' do
    before (:each) do
      allow(Book).to receive(:bestsellers).and_return([book])
    end

    it 'receives bestsellers and returns books' do
      expect(Book).to receive(:bestsellers).and_return([book])
      get :home
    end

    it 'assigns @books' do
      get :home
      expect(assigns(:books)).not_to be_nil
    end

    it 'renders :home template' do
      get :home
      expect(response).to render_template :home
    end
  end

  describe 'GET #show' do
    before do
      allow(Book).to receive(:find).and_return(book)
    end

    it 'receives :find and return book' do
      expect(Book).to receive(:find).with(book.id).and_return(book)
      get :show, id: book.id
    end

    it 'assigns @book' do
      get :show, id: book.id
      expect(assigns(:book)).not_to be_nil
    end

    it 'renders :show template' do
      get :show, id: book.id
      expect(response).to render_template :show
    end
  end

  describe 'GET #index' do
    context 'with selected category' do
      let(:category) { FactoryGirl.create :category }

      it 'receives :categories.select.first and returns category' do
        allow(controller).to receive_message_chain(:categories, :select, :first).and_return(category)
        allow(category).to receive(:get_books)
        expect(controller).to receive_message_chain(:categories, :select, :first).and_return(category)
        get :index, category_id: category.id
      end

      it 'receives @category.get_books and returns @books' do
        allow(controller).to receive_message_chain(:categories, :select, :first).and_return(category)
        allow(category).to receive(:get_books).and_return([book])
        expect(category).to receive(:get_books).and_return([book])
        get :index, category_id: category.id
      end

      it 'assigns @category and @books' do
        get :index, category_id: category.id
        expect(assigns(:category)).not_to be_nil
        expect(assigns(:books)).not_to be_nil
      end

      it 'renders :index template' do
        get :index, category_id: category.id
        expect(response).to render_template :index
      end

    end

    context 'without selected category' do
      let(:category) { FactoryGirl.build_stubbed :category }

      it 'receives Category.new and returns @category' do
        allow(Category).to receive(:new).and_return(category)
        expect(Category).to receive(:new).and_return(category)
        get :index
      end

      it 'receives :order.page and returns @books' do
        allow(Book).to receive_message_chain(:order => :title, :page => 1).and_return([book])
        expect(Book).to receive_message_chain(:order => :title, :page => 1).and_return([book])
        get :index
      end

      it 'assigns @category and @books' do
        get :index
        expect(assigns(:category)).not_to be_nil
        expect(assigns(:books)).not_to be_nil
      end

      it 'renders :index template' do
        get :index
        expect(response).to render_template :index
      end

    end

  end
end