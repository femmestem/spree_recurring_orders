module Spree
  class OrderSubscription < Spree::Base

    self.table_name = "spree_order_subscriptions"

    with_options required: true do
      belongs_to :order
      belongs_to :subscription
    end

    validates :order, :subscription, presence: true

  end
end
