Spree::LineItem.class_eval do

  attr_accessor :subscription_frequency_id, :end_date

  after_update :update_subscription_quantity, if: [:quantity_changed?, :subscription?]
  before_create :build_subscription, if: :subscribable?
  before_create :subscription_valid?, if: :subscribable?
  after_create :save_subscription, if: :subscribable?

  delegate :completed?, to: :order, prefix: true, allow_nil: true

  def subscription
    @subscription || order.subscriptions.find_by(variant_id: variant_id)
  end

  private

    def build_subscription
      subscription_attributes = { subscription_frequency_id: subscription_frequency_id,
        end_date: end_date, variant: variant, parent_order: order, quantity: quantity,
        price: variant.price }
      @subscription = Spree::Subscription.new subscription_attributes
    end

    def save_subscription
      @subscription.save
    end

    def subscription_valid?
      @subscription.valid?
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

end
