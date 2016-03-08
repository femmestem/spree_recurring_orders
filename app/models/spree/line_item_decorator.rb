Spree::LineItem.class_eval do

  attr_accessor :subscription_frequency_id, :end_date, :subscribe

  after_create :create_subscription!, if: :subscribable?
  after_update :update_subscription_quantity, if: [:quantity_changed?, :subscription?]

  private

    def create_subscription!
      @subscription = Spree::Subscription.create! subscription_attributes
    end

    def subscription_attributes
      { subscription_frequency_id: subscription_frequency_id, price: variant.price,
        end_date: end_date, variant: variant, parent_order: order, quantity: quantity }
    end

    def update_subscription_quantity
      subscription.update(quantity: quantity)
    end

    def subscribable?
      subscribe.present?
    end

    def subscription?
      !!subscription
    end

    def subscription
      order.subscriptions.find_by(variant_id: variant_id)
    end

end
