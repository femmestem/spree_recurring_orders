class Spree::SubscriptionNotifier < ApplicationMailer

  default from: "spree-commerce@example.com"

  def notify_user(subscription)
    @subscription = subscription

    mail to: subscription.parent_order.email, subject: t('.subject',
     number: subscription.number, frequency: subscription.frequency.title)
  end
end
