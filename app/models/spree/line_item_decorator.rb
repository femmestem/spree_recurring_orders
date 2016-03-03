Spree::LineItem.class_eval do

  attr_accessor :subscription_frequency_id, :end_date, :subscribe

  after_update :update_subscription_quantity, if: [:quantity_changed?, :subscription?, :order_completed?]
  # after_create :save_subscription

  delegate :completed?, to: :order, prefix: true, allow_nil: true

  private

    def save_subscription
      subscribe.present?
    end

    def update_subscription_quantity
      subscription.update(quantity: quantity)
    end

    def subscribable?
      subscription_frequency_id.present? && end_date.present?
    end

    def subscription?
      !!subscription
    end

    def subscription
      order.subscriptions.find_by(variant_id: variant_id)
    end

end
