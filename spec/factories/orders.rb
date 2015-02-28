FactoryGirl.define do
  factory :order do
    user { FactoryGirl.create(:user) }
    factory :order_not_in_progress do
      state do
        a = Array.new(Order::STATES)
        a.delete(Order::STATE_IN_PROGRESS)
        a.sample
      end
      completed_at { Time.zone.now }
    end
  end
end