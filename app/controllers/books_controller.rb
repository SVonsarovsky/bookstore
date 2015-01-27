class BooksController < ApplicationController
  after_action :last_open_page

  def index
    if params.has_key?(:category_id)
      @category_id = params[:category_id].to_i

      categories.each do |category|
        @category = category if category.id == @category_id
      end
      @books = Book.
          includes(:books_categories).
          references(:books_categories).
          where('books_categories.category_id = ' + @category_id.to_s).
          order(:title).page params[:page]
    else
      @category_id = 0
      @books = Book.order(:title).page params[:page]
    end
  end

  def show
    @book = Book.find(params[:id].to_i)
    @reviews = @book.reviews
  end

  private
  def last_open_page
    unless user_signed_in? && current_user.instance_of?(User)
      session[:last_open_page] = request.original_fullpath
    end
  end

end