class PagesController < ApplicationController
  after_action :last_open_page

  def home
    @books = Book.bestsellers
  end

end