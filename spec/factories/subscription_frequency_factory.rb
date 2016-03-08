FactoryGirl.define do
  factory :monthly_subscription_frequency, class: Spree::SubscriptionFrequency do
    title "monthly"
    months_count 1
  end

  factory :quarterly_subscription_frequency, class: Spree::SubscriptionFrequency do
    title "quarterly"
    months_count 1
  end
end
