# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
class SubscriptionMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/subscription_mailer/notify_user
  def notify_user
    SubscriptionMailer.notify_user
  end

end
