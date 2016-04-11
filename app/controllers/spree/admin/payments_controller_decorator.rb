Spree::Admin::PaymentsController.class_eval do

  private

    def load_data
      @amount = params[:amount] || load_order.total
      @payment_methods = available_payment_methods
      if @payment and @payment.payment_method
        @payment_method = @payment.payment_method
      else
        @payment_method = @payment_methods.first
      end
    end

    def available_payment_methods
      @order.subscriptions.any? ? Spree::Gateway.active.available(:backend) : Spree::PaymentMethod.available(:backend)
    end

end
