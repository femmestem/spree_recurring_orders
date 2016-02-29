Spree::Product.class_eval do

  has_many :subscriptions, through: :variants_including_master, source: :subscriptions
  has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency"
  has_many :subscription_frequencies, through: :product_subscription_frequencies

end
