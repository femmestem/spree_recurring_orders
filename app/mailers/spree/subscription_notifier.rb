class Spree::SubscriptionNotifier < ApplicationMailer

  def notify_user(subscription)
    @subscription = subscription

    mail to: subscription.parent_order.email, from: "spree-commerce@example.com", subject: t('.subject',
     number: subscription.number, frequency: subscription.frequency.title)
  end
end
