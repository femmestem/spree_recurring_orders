Spree::UsersController.class_eval do

  before_action :load_subscriptions, only: :show

  private

    def load_subscriptions
      @orders = @user.orders.complete.order(completed_at: :desc)
      @subscriptions = Spree::Subscription.active.with_parent_orders(@orders)
    end

end
