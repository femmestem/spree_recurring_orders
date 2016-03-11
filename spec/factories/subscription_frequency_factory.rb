FactoryGirl.define do
  factory :monthly_subscription_frequency, class: Spree::SubscriptionFrequency do
    title "monthly"
    months_count 1
  end
end
