Spree::PaymentMethod.class_eval do

  scope :active, -> { where(active: true) }
  scope :credit_card_only, -> { where(type: "Spree::Gateway") }

end
