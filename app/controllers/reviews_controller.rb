class ReviewsController < ApplicationController

  def new
    session[:last_open_page] = request.original_fullpath
    require_login
    @book = Book.find(params[:book_id].to_i)
    @review = Review.new(book: @book, user: current_user)
  end

  def create
    require_login
    @book = Book.find(params[:book_id].to_i)
    @review = Review.new(:book => @book,
                         :user => current_user,
                         :text => params[:text],
                         :rating => params[:rating].to_i)
    if @review.save
      redirect_to @book, notice: 'Review was successfully added.'
    else
      render action: 'new'
    end
  end

  private
  def require_login
    unless user_signed_in? && current_user.instance_of?(User)
      flash[:notice] = 'You must be signed in to add review'
      redirect_to sign_in_path
    end
  end
end