class AddArchivedToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :archived, :boolean, default: false, null: false, index: true
  end
end
