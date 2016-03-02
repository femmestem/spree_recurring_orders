module Spree
  class Subscription < Spree::Base

    belongs_to :ship_address, class_name: "Spree::Address"
    belongs_to :bill_address, class_name: "Spree::Address"
    belongs_to :parent_order, class_name: "Spree::Order"
    belongs_to :variant, inverse_of: :subscriptions

    has_many :order_subscriptions, class_name: "Spree::OrderSubscription", dependent: :destroy
    has_many :orders, through: :order_subscriptions, dependent: :destroy

    with_options presence: true do
      validates :quantity, :end_date, :price, :last_occurrence_at
      validates :ship_address, :bill_address, :variant, :parent_order
    end
    with_options allow_blank: true do
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :quantity, numericality: { greater_than: 0, only_integer: true }
    end

    before_validation :set_last_occurrence_at

    private

      def set_last_occurrence_at
        self.last_occurrence_at = Time.current
      end

  end
end
