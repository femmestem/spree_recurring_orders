module Spree
  class Subscription < Spree::Base

    attr_accessor :cancelled

    include Spree::NumberGenerator

    belongs_to :ship_address, class_name: "Spree::Address"
    belongs_to :bill_address, class_name: "Spree::Address"
    belongs_to :parent_order, class_name: "Spree::Order"
    belongs_to :variant, inverse_of: :subscriptions
    belongs_to :frequency, foreign_key: :subscription_frequency_id, class_name: "Spree::SubscriptionFrequency"
    belongs_to :source, polymorphic: true

    accepts_nested_attributes_for :ship_address, :bill_address

    has_many :orders_subscriptions, class_name: "Spree::OrderSubscription", dependent: :destroy
    has_many :orders, -> { complete }, through: :orders_subscriptions

    self.whitelisted_ransackable_associations = %w( parent_order )

    scope :disabled, -> { where(enabled: false) }
    scope :active, -> { where(enabled: true) }
    scope :not_cancelled, -> { where(cancelled_at: nil) }
    scope :eligible_for_subscription, -> { active.not_cancelled }

    with_options allow_blank: true do
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :quantity, numericality: { greater_than: 0, only_integer: true }
      validates :delivery_number, numericality: { greater_than_or_equal_to: :recurring_orders_size, only_integer: true }
      validates :parent_order, uniqueness: { scope: :variant }
    end
    with_options presence: true do
      validates :quantity, :delivery_number, :price, :number, :variant, :parent_order, :frequency
      validates :cancellation_reasons, :cancelled_at, if: -> { cancelled.present? }
      validates :ship_address, :bill_address, :last_occurrence_at, :source, if: :enabled?
    end

    before_validation :set_last_occurrence_at, if: :can_set_last_occurence_at?
    before_validation :set_cancelled_at, if: :can_set_cancelled_at?

    before_update :not_cancelled?
    after_update :notify_user, if: [:enabled?, :enabled_changed?]
    after_update :notify_cancellation, if: :cancellation_notifiable?
    after_update :notify_reoccurrence, if: :reoccurrence_notifiable?

    def generate_number(options = {})
      options[:prefix] ||= 'S'
      super(options)
    end

    def process
      new_order = recreate_order if time_for_subscription? && deliveries_remaining?
      update(last_occurrence_at: Time.current) if new_order.completed?
    end

    def cancel_with_reason(attributes)
      self.cancelled = true
      update(attributes)
    end

    def cancelled?
      !!cancelled_at_was
    end

    def number_of_deliveries_left
      delivery_number - orders.size - 1
    end

    private

      def set_cancelled_at
        self.cancelled_at = Time.current
      end

      def set_last_occurrence_at
        self.last_occurrence_at = Time.current
      end

      def can_set_last_occurence_at?
        enabled? && last_occurrence_at.nil?
      end

      def recreate_order
        order = make_new_order
        add_variant_to_order(order)
        add_shipping_address(order)
        add_delivery_method_to_order(order)
        add_payment_method_to_order(order)
        confirm_order(order)
        order
      end

      def make_new_order
        orders.create(order_attributes)
      end

      def add_variant_to_order(order)
        order.contents.add(variant, quantity)
        order.next
      end

      def add_shipping_address(order)
        order.ship_address = ship_address.clone
        order.bill_address = bill_address.clone
        order.next
      end

      def add_delivery_method_to_order(order)
        order.next
      end

      def add_payment_method_to_order(order)
        order.payments.first.update(source: source)
        order.next
      end

      def confirm_order(order)
        order.next
      end

      def order_attributes
        {
          currency: parent_order.currency,
          guest_token: parent_order.guest_token,
          store: parent_order.store,
          user: parent_order.user,
          created_by: parent_order.user,
          last_ip_address: parent_order.last_ip_address
        }
      end

      def time_for_subscription?
        (last_occurrence_at + frequency.months_count.months) >= Time.current
      end

      def deliveries_remaining?
        number_of_deliveries_left > 0
      end

      def notify_user
        SubscriptionNotifier.notify_confirmation(self).deliver
      end

      def not_cancelled?
        !cancelled?
      end

      def can_set_cancelled_at?
        cancelled.present?
      end

      def notify_cancellation
        SubscriptionNotifier.notify_cancellation(self).deliver
      end

      def cancellation_notifiable?
        cancelled_at.present? && cancelled_at_changed?
      end

      def reoccurrence_notifiable?
        last_occurrence_at_changed? && last_occurrence_at_was
      end

      def notify_reoccurrence
        SubscriptionNotifier.notify_reoccurrence(self).deliver
      end

      def recurring_orders_size
        orders.size + 1
      end

  end
end
