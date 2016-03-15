module Spree
  class SubscriptionFrequency < Spree::Base

    has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency",
                                                dependent: :destroy

    validates :title, :months_count, presence: true
    with_options allow_blank: true do
      validates :months_count, numericality: { greater_than: 0, only_integer: true }
      validates :title, uniqueness: { case_sensitive: false }
    end

  end
end