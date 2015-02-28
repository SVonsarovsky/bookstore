require 'features/features_spec_helper'

feature 'Book Reviews', :type => :feature do
  before(:each) do
    @book = FactoryGirl.create(:book)
    @user = FactoryGirl.create(:user)
  end

  context 'when user is not logged in' do
    scenario 'he adds a review to the book' do
      visit book_path @book
      click_link 'Add review for this book'

      fill_in 'Email', :with => @user.email
      fill_in 'Password', :with => @user.password
      click_button 'Log in'

      text = Faker::Lorem.paragraph
      choose '_review_rating_5'
      fill_in '_review_text', :with => text
      click_button 'Add review'

      expect(page).to have_content @user.name
      expect(page).to have_content text
      expect(page).to have_content 'Review was successfully added.'
    end
  end

  context 'when user is logged in' do
    scenario 'he adds a review to the book' do
      login_as(@user, :scope => :user)
      visit book_path @book
      click_link 'Add review for this book'

      text = Faker::Lorem.paragraph
      choose '_review_rating_5'
      fill_in '_review_text', :with => text
      click_button 'Add review'

      expect(page).to have_content @user.name
      expect(page).to have_content text
      expect(page).to have_content 'Review was successfully added.'
    end
  end
end
