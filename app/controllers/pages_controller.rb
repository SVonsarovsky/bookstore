class PagesController < ApplicationController

  def home
    @books = Book.bestsellers
  end

end