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
        if @subscription.archive
          format.json { render json: {
              status: 200,
              subscription_id: @subscription.id,
              flash: t(".success")
            }
          }
          format.html { redirect_to account_path, success: t('.success') }
        else
          format.json { render json: {
              status: 422,
              flash: t(".success")
            }
          }
          format.html { redirect_to :back, error: t('.error') }
        end
      end
    end

    def pause
      if @subscription.pause
        render json: {
          status: 200,
          flash: t('.success'),
          url: unpause_subscription_path(@subscription),
          button_text: "Activate"
        }
      else
        render json: {
          status: 422,
          flash: t('.error')
        }
      end
    end

    def unpause
      if @subscription.unpause
        render json: {
          status: 200,
          flash: t('.success'),
          url: pause_subscription_path(@subscription),
          button_text: "Pause"
        }
      else
        render json: {
          status: 422,
          flash: t('.error')
        }
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
          redirect_to account_path, error: Spree.t('subscriptions.alert.missing')
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
