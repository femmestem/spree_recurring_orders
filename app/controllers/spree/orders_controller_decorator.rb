Spree::OrdersController.class_eval do

  before_action :add_subscription_fields, only: :populate, if: -> { params[:subscribe].present? }
  before_action :restrict_guest_subscription, only: :update, unless: :spree_current_user

  private

    def restrict_guest_subscription
      redirect_to login_path, error: Spree.t(:required_authentication) if @order.subscriptions.present?
    end

    def add_subscription_fields
      params[:options] ||= {}
      params[:subscription][:subscribe] = params[:subscribe].present?
      params[:options].merge! params[:subscription]
    end

end
