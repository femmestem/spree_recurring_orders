class RemoveEndDateFromSubscriptions < ActiveRecord::Migration
  def change
    remove_cloumn :spree_subscriptions, :end_date, :datetime
  end
end
