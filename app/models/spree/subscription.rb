module Spree
  class Subscription < Spree::Base

    self.table_name = "spree_subscriptions"

    # with_options required: true do
      belongs_to :ship_address, class_name: "Spree::Address", inverse_of: :shipped_subscriptions
      belongs_to :bill_address, class_name: "Spree::Address", inverse_of: :billed_subscriptions
      belongs_to :parent_order, class_name: "Spree::Order", inverse_of: :parent_subscription
      belongs_to :variant, inverse_of: :subscriptions
    # end

    with_options presence: true do
      validates :quantity, :end_date, :price, :last_recurrence_at
      validates :ship_address, :bill_address, :variant, :parent_order
    end
    validates :price, numericality: { greater_than: 0 }
    validates :quantity, numericality: { greater_than: 0, only_integer: true }

    before_validation :set_last_recurrence_at

    private

      def set_last_recurrence_at
        self.last_recurrence_at = Time.now
      end

  end
end
