FactoryGirl.define do
  factory :review do
    user { FactoryGirl.create(:user) }
    book { FactoryGirl.create(:book) }
    text { Faker::Lorem.paragraph }
    rating { rand(1..5) }
  end
end
