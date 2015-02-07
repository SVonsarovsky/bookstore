FactoryGirl.define do
  factory :book do
    title { Faker::Lorem.sentence(3) }
    price { Faker::Commerce.price }
    short_description { Faker::Lorem.paragraph }
    full_description { Faker::Lorem.paragraphs }
  end
end
