class AddPauseAndDayColumnToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :pause, :boolean, default: false
    add_column :spree_subscriptions, :delivery_day, :integer
  end
end
