class AddDeletedAtToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :deleted_at, :datetime, index: true
  end
end
