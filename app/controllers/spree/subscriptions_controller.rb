module Spree
  class SubscriptionsController < Spree::BaseController

    before_action :ensure_subscription
    before_action :ensure_not_cancelled, only: [:update, :destroy, :pause, :unpause]

    def edit
    end

    def update
      if @subscription.update(subscription_attributes)
        flash[:success] = t(".success")
        redirect_to edit_subscription_path(@subscription)
      else
        render :edit
      end
    end

    def destroy
      respond_to do |format|
        if @subscription.archive
          format.json { render json: {
              subscription_id: @subscription.id,
              flash: t(".success")
            }, status: 200
          }
          format.html { flash[:success] = "Subscription is successfully archived"; redirect_to account_path }
          debugger
        else
          format.json { render json: {
              flash: t(".error")
            }, status: 422
          }
          format.html { flash[:error] = t('.error'); redirect_to :back }
        end
      end
    end

    def pause
      if @subscription.pause
        render json: {
          flash: t('.success'),
          url: unpause_subscription_path(@subscription),
          button_text: "Activate"
        }, status: 200
      else
        render json: {
          flash: t('.error')
        }, status: 422
      end
    end

    def unpause
      if @subscription.unpause
        render json: {
          flash: t('.success'),
          url: pause_subscription_path(@subscription),
          button_text: "Pause"
        }, status: 200
      else
        render json: {
          flash: t('.error')
        }, status: 422
      end
    end

    private

      def subscription_attributes
        params.require(:subscription).permit(:quantity, :next_occurrence_at, :delivery_number,
         :subscription_frequency_id, :ship_address_attributes, :bill_address_attributes)
      end

      def ensure_subscription
        @subscription = Spree::Subscription.active.find_by(id: params[:id])
        unless @subscription
          flash[:error] = Spree.t('subscriptions.alert.missing')
          redirect_to account_path
        end
      end

      def ensure_not_cancelled
        if @subscription.not_changeable?
          respond_to do |format|
            format.html { flash[:error] = Spree.t("subscriptions.error.not_changeable"); redirect_to :back }
            format.js { flash.now[:error] = Spree.t("subscriptions.error.not_changeable"); render partial: "spree/admin/shared/flash_messages" }
          end
        end
      end

  end
end
