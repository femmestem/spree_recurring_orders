Spree::OrdersController.class_eval do

    before_action :add_subscription_fields, only: :populate, if: -> { params[:subscribe].present? }

    private

    def add_subscription_fields
      params[:options] ||= {}
      params[:options].merge! params[:subscription]
    end

end
