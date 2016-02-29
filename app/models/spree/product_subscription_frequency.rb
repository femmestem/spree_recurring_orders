module Spree
  class ProductSubscriptionFrequency < Spree::Base

    self.table_name = "spree_product_subscription_frequencies"

    # with_options required: true do
      belongs_to :product, class_name: "Spree::Product"
      belongs_to :subscription_frequency, class_name: "Spree::SubscriptionFrequency"
    # end

    validates :product, :subscription_frequency, presence: true

  end
end
