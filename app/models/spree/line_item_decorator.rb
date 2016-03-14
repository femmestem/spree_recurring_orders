Spree::LineItem.class_eval do

  attr_accessor :subscription_frequency_id, :delivery_number, :subscribe

  after_create :create_subscription!, if: :subscribable?
  after_update :update_subscription_quantity, if: [:quantity_changed?, :subscription?]
  after_update :update_subscription_attributes, if: [:subscription_attributes_present?, :subscription?]
  after_destroy :destroy_associated_subscription!, if: :subscription?

  def subscription_attributes_present?
    subscription_frequency_id.present? || delivery_number.present?
  end

  def updatable_subscription_attributes
    { subscription_frequency_id: subscription_frequency_id || subscription.subscription_frequency_id,
      delivery_number: delivery_number || subscription.delivery_number }
  end

  private

    def create_subscription!
      Spree::Subscription.create! subscription_attributes
    end

    def subscription_attributes
      { subscription_frequency_id: subscription_frequency_id, price: variant.price,
        delivery_number: delivery_number , variant: variant, parent_order: order, quantity: quantity }
    end

    def update_subscription_quantity
      subscription.update(quantity: quantity)
    end

    def update_subscription_attributes
      subscription.update(updatable_subscription_attributes)
    end

    def subscribable?
      subscribe.present?
    end

    def subscription?
      !!subscription
    end

    def subscription
      order.subscriptions.find_by(variant: variant)
    end

    def destroy_associated_subscription!
      subscription.destroy!
    end

end
