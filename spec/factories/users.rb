FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    billing_address { FactoryGirl.create(:address) }
    shipping_address { FactoryGirl.create(:address) }
  end
end
