class ReviewsController < ApplicationController
  before_action :require_login

  def new
    @book = Book.find(params[:book_id].to_i)
    @review = Review.new(book: @book, user: current_user)
  end

  def create
    @book = Book.find(params[:book_id])
    if @book.reviews.create({:user => current_user}.merge(review_params))
      redirect_to @book, notice: 'Review was successfully added.'
    else
      render action: 'new'
    end
  end

  private
  def review_params
    params.require(:_review).permit(:rating, :text)
  end

end