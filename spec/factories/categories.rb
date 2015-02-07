FactoryGirl.define do
  sequence :name do |n|
    "Category ##{n}"
  end

  factory :category do
    name { FactoryGirl.generate(:name) }
  end
end
