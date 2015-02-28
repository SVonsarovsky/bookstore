require 'features/features_spec_helper'

feature 'Book Shop', :type => :feature do
  scenario 'user is able to visit home page' do
    book = FactoryGirl.create(:book)
    visit root_path
    expect(page).to have_content(I18n.t('welcome'))
    expect(page).to have_selector('.carousel-inner .carousel-caption h3', :text => book.title)
  end

  scenario 'user is able to view books' do
    book = FactoryGirl.create(:book)
    visit root_path
    within('header div.row') do
      click_link 'SHOP'
    end
    expect(page).to have_content(book.title)
    expect(page).to have_selector('h1', :text => 'Shop')
  end

  scenario 'user is able to view books of the category' do
    book1 = FactoryGirl.create(:book)
    book2 = FactoryGirl.create(:book)
    visit shop_path
    within('.category-list') do
      click_link book1.categories.first.name
    end
    expect(page).to have_content book1.title
    expect(page).not_to have_content book2.title
  end

  scenario 'user is able to view a single book' do
    book = FactoryGirl.create(:book)
    visit shop_path
    within('.shop-list h5') do
      click_link book.title
    end
    expect(page).to have_content book.title
    expect(page).to have_selector("input[type=submit][value='Add To Cart']")
  end
end
