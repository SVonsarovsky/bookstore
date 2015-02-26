FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password(8) }

    factory :user_with_book do
      after(:create) do |user|
        user.order_in_progress.add_book(FactoryGirl.create(:book), 1)
      end
      factory :user_with_book_and_addresses do
        before (:create) do |user|
          user.billing_address  = FactoryGirl.create(:address, user: user)
          user.shipping_address = FactoryGirl.create(:address, user: user)
        end
        after(:create) do |user|
          user.order_in_progress.update(billing_address: user.billing_address, shipping_address: user.shipping_address)
        end
        factory :user_with_book_addresses_and_shipping_method do
          after(:create) do |user|
            user.order_in_progress.update(shipping_method: FactoryGirl.create(:shipping_method))
          end
          factory :user_with_book_addresses_shipping_method_and_credit_card do
            after(:create) do |user|
              user.order_in_progress.update(credit_card: FactoryGirl.create(:credit_card, user: user))
            end
          end
        end
      end
    end

  end
end
