require 'rails_helper'

class FakesController < ApplicationController
  include CheckoutWizard
end

describe FakesController do
  let(:controller) {FakesController.new}
  describe '#before_show' do
    %w(address shipping payment confirm complete).each do |step|
      it "calls :before_#{step}_show" do
        allow(controller).to receive("before_#{step}_show".to_sym)
        expect(controller).to receive("before_#{step}_show".to_sym)
        controller.before_show(step)
      end

    end
  end

  describe '#save' do
    %w(address shipping payment confirm complete).each do |step|
      it "calls :process_#{step}" do
        allow(controller).to receive("process_#{step}".to_sym)
        expect(controller).to receive("process_#{step}".to_sym)
        controller.save(step)
      end
    end
  end

  describe '#before_address_show' do
    it 'calls :init_address with billing & shipping types' do
      allow(controller).to receive(:init_address).with('billing')
      allow(controller).to receive(:init_address).with('shipping')
      expect(controller).to receive(:init_address).with('billing')
      expect(controller).to receive(:init_address).with('shipping')
      controller.before_address_show
    end
  end

  describe '#before_shipping_show' do

  end

  describe '#before_payment_show' do

  end

  describe '#before_confirm_show' do

  end

  describe '#before_complete_show' do

  end

  describe '#process_address' do

  end

  describe '#process_shipping' do

  end

  describe '#process_payment' do

  end

  describe '#process_confirm' do

  end

  describe '#process_complete' do

  end

end