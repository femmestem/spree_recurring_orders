class AddMonthsCountColumnToSpreeSubscriptionFrequencies < ActiveRecord::Migration
  def change
    add_column :spree_subscription_frequencies, :months_count, :integer
  end
end
