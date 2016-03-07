module Spree
  class Subscription < Spree::Base

    attr_accessor :cancel

    include Spree::NumberGenerator

    belongs_to :ship_address, class_name: "Spree::Address"
    belongs_to :bill_address, class_name: "Spree::Address"
    belongs_to :parent_order, class_name: "Spree::Order"
    belongs_to :variant, inverse_of: :subscriptions
    belongs_to :frequency, foreign_key: :subscription_frequency_id, class_name: "Spree::SubscriptionFrequency"
    belongs_to :source, polymorphic: true

    accepts_nested_attributes_for :ship_address, :bill_address

    has_many :orders_subscriptions, class_name: "Spree::OrdersSubscription", dependent: :destroy
    has_many :orders, through: :orders_subscriptions

    self.whitelisted_ransackable_associations = %w( parent_order )

    scope :disabled, -> { where(enabled: false) }
    scope :active, -> { where(enabled: true) }
    scope :not_cancelled, -> { where(cancelled_at: nil) }
    scope :end_date_not_exceeded, -> { where("end_date >= ?", Date.today) }
    scope :eligible_for_subscription, -> { active.not_cancelled.end_date_not_exceeded }

    with_options allow_blank: true do
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :quantity, numericality: { greater_than: 0, only_integer: true }
      validates :parent_order, uniqueness: { scope: :variant }
    end
    with_options presence: true do
      validates :quantity, :end_date, :price, :number
      validates :variant, :parent_order, :frequency
      validates :cancellation_reasons, :cancelled_at, if: -> { cancel.present? }
      validates :ship_address, :bill_address, :last_occurrence_at, :source, if: :enabled?
    end

    before_validation :set_last_occurrence_at, if: :last_occurence_at_settable?
    before_validation :set_cancelled_at, if: :cancelled_at_settable?

    before_update :not_cancelled?
    after_update :notify_user, if: -> { enabled? && enabled_changed? }

    def generate_number(options = {})
      options[:prefix] ||= 'S'
      super(options)
    end

    def process
      update(last_occurrence_at: Time.current) if recreation_successful?
    end

    def cancel_with_reason(attributes)
      self.cancel = true
      update(attributes)
    end

    def cancelled?
      !!cancelled_at_was
    end

    private

      def recreation_successful?
        recreate_order if time_for_subscription?
      end

      def set_cancelled_at
        self.cancelled_at = Time.current
      end

      def set_last_occurrence_at
        self.last_occurrence_at = Time.current
      end

      def last_occurence_at_settable?
        enabled? && last_occurrence_at.nil?
      end

      def recreate_order
        make_new_order
        add_variant_to_order
        add_shipping_address
        add_delivery_method_to_order
        add_payment_method_to_order
        confirm_order
      end

      def make_new_order
        @new_order = orders.create(order_params)
      end

      def add_variant_to_order
        @new_order.contents.add(variant, quantity)
        @new_order.next
      end

      def add_shipping_address
        @new_order.ship_address = ship_address.clone
        @new_order.bill_address = bill_address.clone
        @new_order.next
      end

      def add_delivery_method_to_order
        @new_order.next
      end

      def add_payment_method_to_order
        @new_order.payments.first.update(source: source)
        @new_order.next
      end

      def confirm_order
        @new_order.next
      end

      def order_params
        { currency: parent_order.currency, guest_token: parent_order.guest_token, store: parent_order.store,
          user: parent_order.user, created_by: parent_order.user, last_ip_address: parent_order.last_ip_address }
      end

      def time_for_subscription?
        (last_occurrence_at + frequency.months_count.months) >= Time.current
      end

      def notify_user
        SubscriptionNotifier.notify_user(self).deliver
      end

      def not_cancelled?
        !cancelled?
      end

      def cancelled_at_settable?
        cancel.present? && cancellation_reasons.present?
      end

  end
end
