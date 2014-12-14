require 'rails_helper'

describe 'users/new.html.erb' do
  let(:user) { mock_model('User').as_new_record }
  before do
    #user.stub(:email).stub(:password)
    #allow(user).to receive_messages(:email => '', :password => '')
    allow(user).to receive(:email)
    allow(user).to receive(:password)
    assign(:user, user)
    render
  end
  it 'has new_user form' do
    expect(rendered).to have_selector('form#new_user')
  end
  it 'has user_email field' do
    expect(rendered).to have_selector('#user_email')
  end

  it 'has user_password field' do
    expect(rendered).to have_selector('#user_password')
  end

  it 'has register button' do
    expect(rendered).to have_selector('input[type="submit"]')
  end
end