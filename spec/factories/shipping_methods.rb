FactoryGirl.define do
  factory :shipping_method do
    name { Faker::Company.name }
    cost { Faker::Commerce.price }
  end
end
