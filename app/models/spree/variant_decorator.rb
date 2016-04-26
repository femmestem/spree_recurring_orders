Spree::Variant.class_eval do

  has_many :subscriptions, class_name: "Spree::Subscription", dependent: :restrict_with_error
  delegate :variants_including_master, to: :product, prefix: true
  alias_method :product_variants, :product_variants_including_master

end
