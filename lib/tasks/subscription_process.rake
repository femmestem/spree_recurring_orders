namespace :subscription do
  desc "process all subscriptions whom orders are to be created"
  task process: :environment do |t, args|
    Spree::Subscription.eligible_for_subscription.find_in_batches do |batches|
      batches.map(&:process)
    end
  end
end
