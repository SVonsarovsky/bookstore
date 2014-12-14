require 'rails_helper'

describe UsersController do
  describe 'GET new' do
    let(:user) { mock_model('User').as_new_record }

    before do
      allow(User).to receive(:new).and_return(user)
      get :new
    end

    it 'assigns @user variable' do
      expect(assigns(:user)).to eq(user)
    end

    it 'renders new template' do
      expect(response).to render_template :new
    end
  end

  describe 'POST create' do
    let(:user) { mock_model(User, params) }
    let(:params) { {email: Faker::Internet.email, password: '12345678'} }

    before do
      allow(User).to receive(:new).and_return(user)
    end

    it 'sends save message to user model' do
      expect(user).to receive(:save)
      post :create, user: params
    end

    context 'when save message returns true' do
      before do
        allow(user).to receive(:save).and_return(true)
        post :create, user: params
      end

      it 'redirects to root url' do
        expect(response).to redirect_to root_url
      end

      it 'assings a success flash message' do
        expect(flash[:notice]).not_to be_nil
      end

      it 'logs in user' do
        expect(session[:user_id]).to eq(user.id)
      end
    end
  end
end