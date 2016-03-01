Spree::Product.class_eval do

  has_many :subscriptions, through: :variants_including_master, source: :subscriptions
  has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency"
  has_many :subscription_frequencies, through: :product_subscription_frequencies

  self.whitelisted_ransackable_attributes += %w( subscribable )

  scope :subscribable, -> { where(subscribable: true) }
  scope :unsubscribable, -> { where(subscribable: false) }

  validate :ensure_atleast_one_frequency, if: :subscribable?

  private

    def ensure_atleast_one_frequency
      if subscription_frequencies.count == 0
        errors.add(:subscribable, "needs to be selected with atleast one frequency")
      end
    end

end
