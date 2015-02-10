FactoryGirl.define do
  factory :review do
    user { FactoryGirl.create(:user) }
    book { FactoryGirl.create(:book) }
    text { Faker::Lorem.paragraph }
    rating { rand(Review::MIN_RATING..Review::MAX_RATING) }
  end
end
