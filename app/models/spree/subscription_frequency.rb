module Spree
  class SubscriptionFrequency < Spree::Base

    self.table_name = "spree_subscription_frequencies"

    has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency"

    validates :title, presence: true

  end
end
