class Spree::SubscriptionNotifier < ApplicationMailer
  def notify_user(subscription)
    @subscription = subscription

    mail to: subscription.parent_order.email, subject: "Order Confirmation #{ subscription.number } #{ subscription.frequency.title }"
  end
end
