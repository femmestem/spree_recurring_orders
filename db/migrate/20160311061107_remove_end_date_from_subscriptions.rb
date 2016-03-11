class RemoveEndDateFromSubscriptions < ActiveRecord::Migration
  def change
    remove_column :spree_subscriptions, :end_date, :datetime
  end
end
