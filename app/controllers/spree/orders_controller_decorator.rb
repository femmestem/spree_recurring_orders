Spree::OrdersController.class_eval do

    prepend_before_action :save_subscription, only: :populate, if: -> { params[:subscribe].present? }
    # prepend_before_action :add_subscription_fields, only: :populate, if: -> { params[:subscribe].present? }

    private

    def add_subscription_fields
      params.fetch(:options, {}).merge params[:subscribe]
    end

    def save_subscription
      order    = current_order(create_order_if_necessary: true)
      variant  = Spree::Variant.find(params[:variant_id])

      # subscription = Spree::Subscription.find_by(parent_order: order, variant: variant)

      quantity = params[:quantity].to_i
      # subscription.update(quantity: subscription.quantity + quantity) if subscription

      attributes_hash = { parent_order: order, variant: variant, quantity: quantity, price: variant.price }
      subscription_attributes = params.require(:subscription).permit!.merge attributes_hash
      subscription ||= Spree::Subscription.create subscription_attributes
    end

end
