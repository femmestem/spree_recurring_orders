Spree::PaymentMethod.class_eval do

  scope :active, -> { where(active: true) }

end
