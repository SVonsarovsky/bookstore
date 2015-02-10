FactoryGirl.define do
  factory :book do
    title { Faker::Lorem.sentence(3) }
    price { Faker::Commerce.price }
    short_description { Faker::Lorem.paragraph }
    full_description { Faker::Lorem.paragraphs.join(' ') }
    categories {create_list(:category, 2)}
    authors {create_list(:author, 2)}
  end
end
