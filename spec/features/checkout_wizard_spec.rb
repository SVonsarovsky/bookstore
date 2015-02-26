require 'features/features_spec_helper'

feature 'Checkout Wizard', :type => :feature do
  background(:all) do
    FactoryGirl.create(:shipping_method)
  end

  context 'user with book' do
    background(:each) do
      FactoryGirl.create(:country)
      login_as(FactoryGirl.create(:user_with_book), :scope => :user)
    end

    scenario 'starts from shopping cart' do
      visit cart_path
      click_link 'CHECKOUT'
      expect(page).to have_selector('h2', :text => 'BILLING ADDRESS')
      expect(page).to have_selector('h2', :text => 'SHIPPING ADDRESS')
    end

    scenario 'fills in billing address & use it for shipping address and goes to the next step' do
      address = FactoryGirl.build(:address, country: Country.first)
      visit checkout_path 'address'

      fill_in 'billing_address_first_name', :with => address.first_name
      fill_in 'billing_address_last_name', :with => address.last_name
      fill_in 'billing_address_address', :with => address.address
      fill_in 'billing_address_city', :with => address.city
      select address.country.name, :from => 'billing_address_country_id'
      fill_in 'billing_address_zip_code', :with => address.zip_code
      fill_in 'billing_address_phone', :with => address.phone

      check 'use_billing_address'
      click_button 'SAVE AND CONTINUE'
      expect(page).to have_selector('h2', :text => 'SHIPPING METHOD')
    end

    scenario 'fills in billing & shipping addresses and goes to the next step' do
      address = FactoryGirl.build(:address, country: Country.first)
      address2 = FactoryGirl.build(:address, country: Country.first)
      visit checkout_path 'address'

      fill_in 'billing_address_first_name', :with => address.first_name
      fill_in 'billing_address_last_name', :with => address.last_name
      fill_in 'billing_address_address', :with => address.address
      fill_in 'billing_address_city', :with => address.city
      select address.country.name, :from => 'billing_address_country_id'
      fill_in 'billing_address_zip_code', :with => address.zip_code
      fill_in 'billing_address_phone', :with => address.phone

      fill_in 'shipping_address_first_name', :with => address2.first_name
      fill_in 'shipping_address_last_name', :with => address2.last_name
      fill_in 'shipping_address_address', :with => address2.address
      fill_in 'shipping_address_city', :with => address2.city
      select address2.country.name, :from => 'shipping_address_country_id'
      fill_in 'shipping_address_zip_code', :with => address2.zip_code
      fill_in 'shipping_address_phone', :with => address2.phone

      click_button 'SAVE AND CONTINUE'
      expect(page).to have_selector('h2', :text => 'SHIPPING METHOD')
    end
  end

  context 'user with book and addresses' do
    scenario 'chooses a shipping method and goes to the next step' do
      login_as(FactoryGirl.create(:user_with_book_and_addresses), :scope => :user)
      visit checkout_path 'shipping'
      choose ShippingMethod.first.name
      click_button 'SAVE AND CONTINUE'
      expect(page).to have_selector('h2', :text => 'CARD DETAILS')
    end
  end

  context 'user with book, addresses and shipping method' do
    scenario 'fills in credit card data and goes to the next step' do
      login_as(FactoryGirl.create(:user_with_book_addresses_and_shipping_method), :scope => :user)
      credit_card = FactoryGirl.build(:credit_card)
      visit checkout_path 'payment'

      fill_in 'credit_card_number', :with => credit_card.number
      select credit_card.expiration_year, :from => 'credit_card_expiration_year'
      select credit_card.expiration_month, :from => 'credit_card_expiration_month'
      fill_in 'credit_card_code', :with => credit_card.code

      click_button 'SAVE AND CONTINUE'
      expect(page).to have_selector('button', :text => 'PLACE ORDER')
    end
  end

  context 'user with book, addresses shipping method and credit card' do
    scenario 'places order and goes to the complete page' do
      user = FactoryGirl.create(:user_with_book_addresses_shipping_method_and_credit_card)
      login_as(user, :scope => :user)
      visit checkout_path 'confirm'
      click_button 'PLACE ORDER'
      expect(page).to have_selector('h1', :text => user.last_placed_order.display_number)
    end
  end


end
