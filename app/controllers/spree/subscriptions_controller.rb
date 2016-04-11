module Spree
  class SubscriptionsController < Spree::BaseController

    before_action :set_subscription, :ensure_subscription
    before_action :ensure_not_cancelled, only: [:update, :destroy, :pause, :unpause]

    def edit
    end

    def update
      if @subscription.update(subscription_attributes)
        redirect_to edit_subscription_path(@subscription), notice: t(".success")
      else
        render :edit
      end
    end

    def destroy
      respond_to do |format|
        debugger
        if @subscription.archive
          format.js { flash.now[:success] = t('.success') }
          format.html { redirect_to account_path, success: t('.success') }
        else
          format.js { flash.now[:error] = t('.error') }
          format.html { redirect_to :back, error: t('.error') }
        end
      end
    end

    def pause
      if @subscription.pause
        flash.now[:success] = t('.success')
      else
        flash.now[:error] = t('.error')
      end
    end

    def unpause
      if @subscription.unpause
        flash.now[:success] = t('.success')
      else
        flash.now[:error] = t('.error')
      end
    end

    private

      def subscription_attributes
        params.require(:subscription).permit(:quantity, :next_occurrence_at, :delivery_number,
         :subscription_frequency_id, :ship_address_attributes, :bill_address_attributes)
      end

      def set_subscription
        @subscription = Spree::Subscription.active.find_by(id: params[:id])
      end

      def ensure_subscription
        unless @subscription
          flash[:error] = t('spree.subscriptions.alert.missing')
          redirect_to account_path
        end
      end

      def ensure_not_cancelled
        if @subscription.not_changeable?
          respond_to do |format|
            format.html { redirect_to :back, error: t("spree.subscriptions.error.not_changeable") }
            format.js { flash.now[:error] = t("spree.subscriptions.error.not_changeable") ; render partial: "spree/admin/shared/flash_messages" }
          end
        end
      end

  end
end
