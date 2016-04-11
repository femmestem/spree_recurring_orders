module Spree
  module Admin
    class SubscriptionsController < Spree::Admin::ResourceController

      before_action :ensure_not_cancelled, only: [:update, :cancel, :cancellation]

      def cancellation
      end

      def cancel
        if @subscription.cancel_with_reason(permitted_cancel_subscription_attributes)
          flash[:success] = t('.success')
          redirect_to collection_url
        else
          render :cancellation
        end
      end

      def unpause
        if @subscription.unpause
          flash.now[:success] = t('.success')
        else
          flash.now[:error] = t('.success')
        end
      end

      def pause
        if @subscription.pause
          flash.now[:success] = t('.success')
        else
          flash.now[:error] = t('.failure')
        end
      end

      private

        def permitted_cancel_subscription_attributes
          params.require(:subscription).permit(:cancellation_reasons)
        end

        def collection
          @search = super.active.ransack(params[:q])
          @collection = @search.result.includes(:frequency, :complete_orders, variant: :product)
                                      .references(:complete_orders)
                                      .order(created_at: :desc)
                                      .page(params[:page])
        end

        def ensure_not_cancelled
          if @subscription.cancelled?
            flash[:error] = t("spree.admin.subscriptions.error_on_already_cancelled")
            redirect_to collection_url
          end
        end

    end
  end
end
