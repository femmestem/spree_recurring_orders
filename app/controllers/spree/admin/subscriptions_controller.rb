module Spree
  module Admin
    class SubscriptionsController < Spree::Admin::ResourceController

      def cancellation
      end

      def cancel
        @subscription.cancel = true
        if @subscription.update(permitted_cancel_subscription_attributes)
          redirect_to collection_url, success: "Subscription is deleted"
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
          @search = @collection.ransack(params[:q])
          @collection = @search.result.active
        end

    end
  end
end
