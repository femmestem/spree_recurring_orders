Spree::Product.class_eval do

  has_many :subscriptions, through: :variants_including_master, source: :subscriptions
  has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency"
  has_many :subscription_frequencies, through: :product_subscription_frequencies

  self.whitelisted_ransackable_attributes += %w( subscribable )

  scope :subscribable, -> { where(subscribable: true) }
  scope :unsubscribable, -> { where(subscribable: false) }

end
