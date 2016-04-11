Spree::UsersController.class_eval do

  before_action :load_subscriptions, only: :show

  private

    def load_subscriptions
      @orders = @user.orders.complete.order(completed_at: :desc)
      @subscriptions = Spree::Subscription.with_deleted.active.with_parent_orders(@orders)
    end

end
