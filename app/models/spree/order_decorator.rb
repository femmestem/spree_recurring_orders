Spree::Order.class_eval do

  has_one :subscription, through: :order_subscriptions
  has_one :order_subscription, class_name: "Spree::OrdersSubscription", dependent: :destroy

  def available_payment_methods
    payment_methods = Spree::PaymentMethod.where(active: true)
    if subscriptions.count > 0
      @available_payment_methods = payment_methods.where(name: "Credit Card")
    else
      @available_payment_methods ||= payment_methods
    end
  end

end
