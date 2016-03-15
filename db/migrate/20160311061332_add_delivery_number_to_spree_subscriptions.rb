class AddDeliveryNumberToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :delivery_number, :integer
  end
end
