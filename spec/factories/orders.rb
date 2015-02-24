FactoryGirl.define do
  factory :order do
    user { FactoryGirl.create(:user) }
    factory :order_not_in_progress do
      state { Array.new(Order::STATES).delete_if{|state| state == Order::STATE_IN_PROGRESS}.sample }
      completed_at { Time.zone.now }
    end
  end
end