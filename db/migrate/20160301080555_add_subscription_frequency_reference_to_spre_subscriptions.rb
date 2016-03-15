class AddSubscriptionFrequencyReferenceToSpreSubscriptions < ActiveRecord::Migration
  def change
    add_reference :spree_subscriptions, :subscription_frequency, index: true
  end
end
