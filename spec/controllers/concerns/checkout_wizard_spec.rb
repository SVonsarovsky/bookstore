require 'rails_helper'

class FakesController < ApplicationController
  include CheckoutWizard
  include FormProcessing
end

describe FakesController do
  let(:controller) {FakesController.new}

  def self.steps
    %w(address shipping payment confirm complete)
  end

  describe '#before_show' do
    steps.each do |step|
      it "calls :before_#{step}_show" do
        expect(controller).to receive("before_#{step}_show".to_sym)
        controller.before_show(step)
      end

    end
  end

  describe '#save' do
    steps.each do |step|
      it "calls :process_#{step}" do
        expect(controller).to receive("process_#{step}".to_sym)
        controller.save(step)
      end
    end
  end

  describe '#before_address_show' do
    it 'calls :init_address with billing & shipping types' do
      expect(controller).to receive(:init_address).with('billing')
      expect(controller).to receive(:init_address).with('shipping')
      controller.before_address_show
    end
  end

  describe '#before_shipping_show' do
    context 'when both addresses are set' do
      before (:each) do
        order = FactoryGirl.build_stubbed(:order)
        order.billing_address = FactoryGirl.build_stubbed(:address, user: order.user)
        order.shipping_address = FactoryGirl.build_stubbed(:address, user: order.user)
        controller.instance_variable_set('@order', order)
        allow(controller).to receive(:params).and_return Hash.new
      end

      it 'does not assign @notice with any text' do
        controller.before_shipping_show
        expect(controller.instance_variable_get('@notice')).to be_nil
      end

      it 'calls :active for ShippingMethod' do
        expect(ShippingMethod).to receive(:active).and_call_original
        controller.before_shipping_show
      end

      it 'assigns @shipping_methods as ActiveRecord::Relation object' do
        controller.before_shipping_show
        expect(controller.instance_variable_get('@shipping_methods')).to be_an ActiveRecord::Relation
      end

      it 'assigns @shipping_method as ShippingMethod object' do
        FactoryGirl.create(:shipping_method)
        controller.before_shipping_show
        expect(controller.instance_variable_get('@shipping_method')).not_to be_nil
      end
    end

    context 'when both addresses are not set' do
      it 'assigns @notice with some text' do
        controller.instance_variable_set('@order', FactoryGirl.build_stubbed(:order))
        controller.before_shipping_show
        expect(controller.instance_variable_get('@notice')).not_to be_nil
      end
    end

    context 'when billing address is not set' do
      it 'assigns @notice with some text' do
        order = FactoryGirl.build_stubbed(:order)
        order.shipping_address = FactoryGirl.build_stubbed(:address, user: order.user)
        controller.instance_variable_set('@order', order)
        controller.before_shipping_show
        expect(controller.instance_variable_get('@notice')).not_to be_nil
      end
    end

    context 'when shipping address is not set' do
      it 'assigns @notice with some text' do
        order = FactoryGirl.build_stubbed(:order)
        order.billing_address = FactoryGirl.build_stubbed(:address, user: order.user)
        controller.instance_variable_set('@order', order)
        controller.before_shipping_show
        expect(controller.instance_variable_get('@notice')).not_to be_nil
      end
    end
  end

  describe '#before_payment_show' do
    context 'when @order.shipping_method is set' do
      let(:order) {FactoryGirl.build(:order, shipping_method: FactoryGirl.build_stubbed(:shipping_method))}
      before(:each) do
        controller.instance_variable_set('@order', order)
        controller.instance_variable_set('@user', order.user)
        allow(controller.instance_variable_get('@user')).to receive(:last_credit_card)
      end

      it 'does not assign @notice with any text' do
        controller.before_payment_show
        expect(controller.instance_variable_get('@notice')).to be_nil
      end

      it 'assigns @credit_card' do
        controller.before_payment_show
        expect(controller.instance_variable_get('@credit_card')).not_to be_nil
      end
    end

    context 'when @order.shipping_method is not set' do
      it 'assigns @notice with some text' do
        controller.instance_variable_set('@order', FactoryGirl.build_stubbed(:order))
        controller.before_payment_show
        expect(controller.instance_variable_get('@notice')).not_to be_nil
      end
    end
  end

  describe '#before_confirm_show' do
    context 'when @order.credit_card is set' do
      it 'does not assign @notice with any text' do
        controller.instance_variable_set('@order', FactoryGirl.build_stubbed(:order, credit_card: FactoryGirl.build_stubbed(:credit_card)))
        controller.before_confirm_show
        expect(controller.instance_variable_get('@notice')).to be_nil
      end
    end

    context 'when @order.credit_card is not set' do
      it 'assigns @notice with some text message' do
        controller.instance_variable_set('@order', FactoryGirl.build_stubbed(:order))
        controller.before_confirm_show
        expect(controller.instance_variable_get('@notice')).not_to be_nil
      end
    end

  end

  describe '#before_complete_show' do
    context 'when @order is set' do
      it 'does not assign @notice with any text' do
        controller.instance_variable_set('@order', FactoryGirl.build_stubbed(:order_not_in_progress))
        controller.before_complete_show
        expect(controller.instance_variable_get('@notice')).to be_nil
      end
    end

    context 'when @order is not set' do
      it 'assigns @notice with some text' do
        controller.before_complete_show
        expect(controller.instance_variable_get('@notice')).not_to be_nil
      end
    end
  end

  describe '#process_address' do

  end

  describe '#process_shipping' do

  end

  describe '#process_payment' do
    before(:each) do
      controller.instance_variable_set('@order', FactoryGirl.create(:order))
    end
    let(:credit_card_params) { FactoryGirl.attributes_for(:credit_card).stringify_keys }

    context 'with valid credit card attributes' do
      before(:each) do
        allow(controller).to receive(:credit_card_params).and_return credit_card_params
        allow(controller).to receive(:set_errors_for)
      end

      it 'receives save_credit_card for @order which returns true' do
        expect(controller.instance_variable_get('@order')).to receive(:save_credit_card).with(credit_card_params).and_return true
        controller.process_payment
      end

      it 'sets successful notice for @notice' do
        allow(controller.instance_variable_get('@order')).to receive(:save_credit_card).with(credit_card_params).and_return true
        controller.process_payment
        expect(controller.instance_variable_get('@notice')).not_to be_nil
      end
    end

    context 'with forbidden attributes' do
      it 'generates NoMethodError error without credit card params' do
        expect { controller.process_payment }.to raise_error(NoMethodError)
      end

      it 'filters forbidden params' do
        allow(controller).to receive(:credit_card_params).and_return credit_card_params
        credit_card_params.merge(user_id: 100)
        expect(controller.instance_variable_get('@order')).to receive(:save_credit_card).with(credit_card_params).and_return true
        controller.process_payment
      end
    end

    context 'with invalid attributes' do
      xit 'receives save_credit_card for @order which returns false' do
      end

      xit 'receives CreditCard.new with credit_card_params' do
      end

      xit 'assigns @credit_card as a CreditCard instance' do
      end

      xit 'receives set_errors_for' do
      end

      xit 'sets errors to @errors array' do
      end
    end
  end

  describe '#process_confirm' do
    it 'calls checkout! event for current order' do
      controller.instance_variable_set('@order', FactoryGirl.create(:order))
      expect(controller.instance_variable_get('@order')).to receive(:checkout!)
      controller.process_confirm
    end
  end

  describe '#process_complete' do
    it 'does nothing' do
      controller.process_complete
    end
  end

end