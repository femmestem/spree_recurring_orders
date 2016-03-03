module Spree
  class Subscription < Spree::Base

    attr_accessor :cancel

    belongs_to :ship_address, class_name: "Spree::Address"
    belongs_to :bill_address, class_name: "Spree::Address"
    belongs_to :parent_order, class_name: "Spree::Order"
    belongs_to :variant, inverse_of: :subscriptions
    belongs_to :frequency, foreign_key: :subscription_frequency_id, class_name: "Spree::SubscriptionFrequency"
    belongs_to :source, class_name: "Spree::CreditCard"

    has_many :orders_subscriptions, class_name: "Spree::OrdersSubscription", dependent: :destroy
    has_many :orders, through: :orders_subscriptions

    self.whitelisted_ransackable_associations = %w( parent_order )

    scope :disabled, -> { where(enabled: false) }
    scope :active, -> { where(enabled: true) }

    with_options allow_blank: true do
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :quantity, numericality: { greater_than: 0, only_integer: true }
      validates :number, uniqueness: { case_sensitive: false }
      validates :parent_order, uniqueness: { scope: :variant }
    end
    with_options presence: true do
      validates :quantity, :end_date, :price, :number
      validates :variant, :parent_order, :frequency
      validates :cancellation_reasons, :cancelled_at, if: -> { cancel.present? }
      validates :ship_address, :bill_address, :last_occurrence_at, :source, if: :enabled?
    end

    before_validation :set_last_occurrence_at, if: :last_occurence_at_settable?
    before_validation :set_number, on: :create
    before_validation :set_cancelled_at, if: -> { cancel.present? }

    after_update :notify_user, if: -> { enabled? && enabled_changed? }

    def process
      update(last_occurrence_at: Time.current) if recreation_successfull?
    end

    private

      def recreation_successfull?
        recreate_order if eligible_for_subscription?
      end

      def set_cancelled_at
        self.cancelled_at = Time.current
      end

      def set_last_occurrence_at
        self.last_occurrence_at = Time.current
      end

      def set_number
        self.number = parent_order.number + "SR"
      end

      def last_occurence_at_settable?
        enabled? && last_occurrence_at.nil?
      end

      def recreate_order
        new_order = orders.create(order_params)
        new_order.contents.add(variant, quantity)
        new_order.next
        new_order.ship_address = ship_address
        new_order.bill_address = bill_address
        new_order.next
        new_order.next
        new_order.payments.update(source: source)
        new_order.next
        new_order.next
      end

      def order_params
        { currency: parent_order.currency, guest_token: parent_order.guest_token, store: parent_order.store,
          user: parent_order.user, created_by: parent_order.user, last_ip_address: parent_order.last_ip_address }
      end

      def eligible_for_subscription?
        subscription_time? && end_date_not_exceeded?
      end

      def subscription_time?
        (last_occurrence_at + frequency.time_in_months.month).to_date == Date.today
      end

      def end_date_not_exceeded?
        end_date.to_date >= Date.today
      end

      def notify_user
        SubscriptionNotifier.notify_user(self).deliver
      end

  end
end
