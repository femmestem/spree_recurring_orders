Spree::Order.class_eval do

  has_one :order_subscription, class_name: "Spree::OrdersSubscription", dependent: :destroy
  has_one :subscription, through: :order_subscriptions
  has_many :subscriptions, class_name: "Spree::Subscription", foreign_key: :parent_order_id

  after_update :enable_subscriptions, if: :completed?

  def available_payment_methods
    payment_methods = Spree::PaymentMethod.where(active: true)
    if subscriptions.count > 0
      @available_payment_methods = payment_methods.where(name: "Credit Card")
    else
      @available_payment_methods ||= payment_methods
    end
  end

  private

    def enable_subscriptions
      subscriptions.each do |subscription|
        subscription.update(source: payments.from_credit_card.first.source,
          enabled: true, ship_address: ship_address, bill_address: bill_address)
      end
    end

end
