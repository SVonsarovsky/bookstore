require 'rails_helper'

RSpec.describe CheckoutController, :type => :controller do
  before(:each) do
    allow(controller).to receive(:require_login)
    allow(controller).to receive(:set_data)
  end

  def self.steps
    %w(address shipping payment confirm complete)
  end

  describe 'GET #show' do
    describe 'rescue_from nonexistent step' do
      it 'rescues from Wicked::Wizard::InvalidStepError' do
        get :show, id: 'nonexistent_step'
        expect(response.status).to eq 404
      end
    end

    steps.each do |step|
      it "calls #before_show :#{step}" do
        expect(controller).to receive(:before_show).with(step.to_sym)
        get :show, id: step
      end
    end

    context 'when @notice is set' do
      steps.each do |step|
        it "redirects to previous_wizard_path from :#{step}" do
          allow(controller).to receive(:before_show).with(step.to_sym)
          controller.instance_variable_set(:@notice, Faker::Lorem.sentence(3))
          get :show, id: step
          expect(response).to redirect_to controller.previous_wizard_path
        end
      end
    end

    context 'when @notice is not set' do
      steps.each do |step|
        it "calls render_wizard for :#{step}" do
          allow(controller).to receive(:before_show).with(step.to_sym)
          expect(controller).to receive(:render_wizard).and_call_original
          get :show, id: step
        end
      end
    end
  end

  describe 'PUT #update' do
    describe 'rescue_from nonexistent step' do
      it 'rescues from Wicked::Wizard::InvalidStepError' do
        get :show, id: 'nonexistent_step'
        expect(response.status).to eq 404
      end
    end

    steps.each do |step|
      it "calls #save :#{step}" do
        controller.instance_variable_set(:@errors, {})
        expect(controller).to receive(:save).with(step.to_sym)
        put :update, id: step
      end
    end

    context 'when there are no errors while saving data' do
      steps.each do |step|
        it "redirects to next_wizard_path from :#{step}" do
          allow(controller).to receive(:save).with(step.to_sym)
          controller.instance_variable_set(:@errors, {})
          put :update, id: step
          expect(response).to redirect_to controller.next_wizard_path
        end
      end
    end

    context 'when there are errors while saving data' do
      steps.each do |step|
        it "calls before_show and render_wizard for :#{step}" do
          allow(controller).to receive(:save).with(step.to_sym)
          controller.instance_variable_set(:@errors, {step => ['Error 1', 'Error 2']})
          expect(controller).to receive(:before_show).with(step.to_sym)
          expect(controller).to receive(:render_wizard).and_call_original
          put :update, id: step
        end
      end

    end

  end
end
