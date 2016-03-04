namespace :subscription do
  desc "process all subscriptions whom orders are to be created"
  task process: :environment do |t, args|
    Spree::Subscription.all.map(&:process)
  end
end
