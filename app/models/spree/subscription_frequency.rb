module Spree
  class SubscriptionFrequency < Spree::Base

    has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency",
                                                dependent: :destroy

    validates :title, presence: true
    validates :title, uniqueness: { case_sensitive: false }, allow_blank: true

    def time_in_months
      case title
      when "monthly"
        1
      when "quarterly"
        3
      when "half yearly"
        6
      when "yearly"
        12
      end
    end

  end
end
