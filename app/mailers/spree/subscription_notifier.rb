class Spree::SubscriptionNotifier < ApplicationMailer

  default from: "spree-commerce@example.com"

  def notify_confirmation(subscription)
    @subscription = subscription

    mail to: subscription.parent_order.email,
         subject: t('.subject', number: subscription.number, frequency: subscription.frequency.title.capitalize)
  end

  def notify_cancellation(subscription)
    @subscription = subscription

    mail to: subscription.parent_order.email,
         subject: t('.subject', number: subscription.number, frequency: subscription.frequency.title.capitalize)
  end

  def notify_reoccurrence(subscription)
    @subscription = subscription

    mail to: subscription.parent_order.email,
         subject: t('.subject', number: subscription.number, frequency: subscription.frequency.title.capitalize)
  end

  def notify_for_next_delivery(subscription)
    @subscription = subscription

    mail to: subscription.parent_order.email,
         subject: t('.subject', number: subscription.number, frequency: subscription.frequency.title.capitalize)
  end
end
