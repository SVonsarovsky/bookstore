class BooksController < ApplicationController
  after_action :last_open_page

  def index
    if params.has_key?(:category_id)
      @category = categories.select{|category| category.id == params[:category_id].to_i}.first
      @books = @category.get_books(params[:page])
    else
      @category = Category.new
      @books = Book.order(:title).page(params[:page])
    end
  end

  def show
    @book = Book.find(params[:id].to_i)
  end

  def home
    @books = Book.bestsellers
  end

end