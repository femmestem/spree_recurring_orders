FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.

  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_items_subscriptions/factories'
  factory :monthly_subscription_frequency, class: Spree::SubscriptionFrequency do
    title "monthly"
    months_count 1
  end
end
