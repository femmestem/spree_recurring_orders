Spree::Order.class_eval do

  has_one :order_subscriptions, class_name: "Spree::OrderSubscription"
  has_one :subscription, through: :order_subscriptions, source: :subscription
  has_one :parent_subscription, class_name: "Spree::Subscription", foreign_key: :parent_order_id

end
