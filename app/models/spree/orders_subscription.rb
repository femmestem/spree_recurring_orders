module Spree
  class OrderSubscription < Spree::Base

    self.tablename = "spree_orders_subscription"

    belongs_to :order, class_name: "Spree::Order"
    belongs_to :subscription, class_name: "Spree::Subscription"

    validates :order, :subscription, presence: true

  end
end
