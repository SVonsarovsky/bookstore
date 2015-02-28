require 'features/features_spec_helper'

feature 'Shopping cart', :type => :feature do
  context 'when user is not logged in' do
    scenario 'he adds a book to the shopping cart' do
      book = FactoryGirl.create(:book)
      user = FactoryGirl.create(:user)

      visit book_path book
      click_button 'Add To Cart'

      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => user.password
      check 'user_remember_me'
      click_button 'Log in'

      click_button 'Add To Cart'

      expect(page).to have_content book.title
      expect(page).not_to have_content 'CART: (EMPTY)'
      expect(page).to have_content 'Book was successfully added to cart.'
    end
  end

  context 'when user is logged in' do
    scenario 'he adds a book to the shopping cart' do
      login_as(FactoryGirl.create(:user), :scope => :user)
      book = FactoryGirl.create(:book)

      visit book_path book
      click_button 'Add To Cart'

      expect(page).not_to have_content 'CART: (EMPTY)'
      expect(page).to have_content book.title
      expect(page).to have_content 'Book was successfully added to cart.'
    end
  end

  context 'when user already has book in cart' do
    before(:each) do
      @user = FactoryGirl.create(:user_with_book)
      login_as(@user, :scope => :user)
    end

    scenario 'he empties shopping cart' do
      visit cart_path
      click_link 'EMPTY CART'
      expect(page).to have_content 'Shopping cart is empty'
    end

    scenario 'he continues shopping' do
      visit cart_path
      click_link 'CONTINUE SHOPPING'
      expect(page).to have_selector 'h1', text: 'Shop'
    end

    scenario "he updates book's quantity" do
      visit cart_path
      order_item = @user.order_in_progress.order_items.first
      fill_in "quantity_#{order_item.id}", :with => 2
      click_button 'UPDATE'
      expect(page).to have_content 'Cart was successfully updated.'
    end

    scenario 'he deletes book from cart' do
      visit cart_path
      order_item = @user.order_in_progress.order_items.first
      find("a[href='#{item_cart_path(order_item.id)}']").click
      expect(page).not_to have_selector "a[href='#{item_cart_path(order_item.id)}']"
    end
  end
end
