Spree::Address.class_eval do

  has_many :shipped_subscriptions, class_name: "Spree::Subscription", foreign_key: :ship_address_id
  has_many :billed_subscriptions, class_name: "Spree::Subscription", foreign_key: :bill_address_id

end
