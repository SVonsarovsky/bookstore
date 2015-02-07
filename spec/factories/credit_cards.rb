FactoryGirl.define do
  factory :credit_card do
    user { FactoryGirl.create(:user) }
    number { Faker::Business.credit_card_number }
    code { Faker::Number.number(3) }
    expiration_year { Faker::Business.credit_card_expiry_date.year }
    expiration_month { Faker::Business.credit_card_expiry_date.month }
  end
end