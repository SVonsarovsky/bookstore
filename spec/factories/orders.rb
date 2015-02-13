FactoryGirl.define do
  factory :order do
    user { FactoryGirl.create(:user) }
    #number { rand(100000000..999999999) }
    credit_card { FactoryGirl.create(:credit_card) }
    #billing_address { FactoryGirl.create(:address) }
    #shipping_address { FactoryGirl.create(:address) }
    #shipping_method { FactoryGirl.create(:shipping_method) }
    #shipping_cost { Faker::Commerce.price }
  end
end