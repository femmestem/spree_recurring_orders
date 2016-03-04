module Spree
  module Admin
    class SubscriptionsController < Spree::Admin::ResourceController

      before_action :ensure_not_cancelled, only: :update

      def cancellation
      end

      def cancel
        if @subscription.cancel_with_reason(permitted_cancel_subscription_attributes)
          flash[:success] = "Subscription is cancelled"
          redirect_to collection_url
        else
          render :cancellation
        end
      end

      private

        def permitted_cancel_subscription_attributes
          params.require(:subscription).permit(:cancellation_reasons)
        end

        def collection
          @collection = super
          @search = @collection.active.ransack(params[:q])
          @collection = @search.result.order(created_at: :desc).page(params[:page])
        end

        def ensure_not_cancelled
          if @subscription.cancelled?
            redirect_to collection_url, error: "Cancelled Subscription can not be updated."
          end
        end

    end
  end
end
