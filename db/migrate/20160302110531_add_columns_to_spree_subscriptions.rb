class AddColumnsToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :number, :string
    add_column :spree_subscriptions, :cancellation_reasons, :text
  end
end
