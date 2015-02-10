FactoryGirl.define do
  sequence :shipping do |n|
    "Shipping method ##{n}"
  end

  factory :shipping_method do
    name { FactoryGirl.generate(:shipping) }
    cost { Faker::Commerce.price }
  end
end
