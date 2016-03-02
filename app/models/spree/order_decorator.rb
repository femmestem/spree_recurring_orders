Spree::Order.class_eval do

  has_one :order_subscriptions, class_name: "Spree::OrderSubscription", dependent: :destroy
  has_one :subscription, through: :order_subscriptions

end
