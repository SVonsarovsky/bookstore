class BooksController < ApplicationController
  after_action :last_open_page

  def index
    if params.has_key?(:category_id)
      @category = Category.find(params[:category_id])
      @books = @category.books.order(:title).page(params[:page])
    else
      @category = Category.new
      @books = Book.order(:title).page(params[:page])
    end
  end

  def show
    @book = Book.find(params[:id])
  end

  def home
    @books = Book.bestsellers
  end

end