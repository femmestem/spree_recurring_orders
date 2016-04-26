Spree::Variant.class_eval do

  has_many :subscriptions, class_name: "Spree::Subscription", dependent: :restrict_with_error
  delegate :variants_including_master, to: :product
  alias_method :product_variants, :variants_including_master

end
