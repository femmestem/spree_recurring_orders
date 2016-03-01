Spree::Order.class_eval do

  has_one :order_subscriptions, class_name: "Spree::OrderSubscription", dependent: :destroy
  has_one :subscription, through: :order_subscriptions

  def available_payment_methods
    payment_methods = Spree::PaymentMethod.where(active: true)
    if subscriptions.count > 0
      @available_payment_methods = payment_methods.where(name: "Credit Card")
    else
      @available_payment_methods ||= payment_methods
    end
  end

end
