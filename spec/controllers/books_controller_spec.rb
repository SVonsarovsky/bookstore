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
      expect(Book).to receive(:find).and_return(book)
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

      it 'receives Category.find and returns category' do
        expect(Category).to receive(:find).and_return(category)
        get :index, category_id: category.id
      end

      it 'receives @category.books.order.page and returns books' do
        allow(Category).to receive(:find).and_return(category)
        expect(category).to receive_message_chain(:books, :order => :title, :page => nil).and_return([book])
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

      it 'receives Category.new' do
        expect(Category).to receive(:new).and_return(category)
        get :index
      end

      it 'receives :order.page and returns @books' do
        expect(Book).to receive_message_chain(:order => :title, :page => nil).and_return([book])
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