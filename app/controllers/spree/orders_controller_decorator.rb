Spree::OrdersController.class_eval do

    rescue_from ActiveRecord::RecordNotSaved, with: :show_error_message

    before_action :add_subscription_fields, only: :populate, if: -> { params[:subscribe].present? }

    private

    def add_subscription_fields
      params[:options] ||= {}
      params[:options].merge! params[:subscription]
    end

    def show_error_message
      flash[:error] = current_order.line_items.last.subscription.errors.full_messages.join(', ')
      redirect_to :back
    end

end
