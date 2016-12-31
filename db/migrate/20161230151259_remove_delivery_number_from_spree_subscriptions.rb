class RemoveDeliveryNumberFromSpreeSubscriptions < ActiveRecord::Migration
  def change
    remove_column :spree_subscriptions, :delivery_number
  end
end
