require "spec_helper"

describe Spree::OrdersController, type: :controller do

  stub_authorization!

  describe "Callbacks" do
    describe "#add_subscription_fields" do
      def do_populate params
        spree_post :populate, params
      end

      let (:with_subscribe_params) { { subscribe: true, subscription: { subscription_frequency_id: 1, delivery_number: 6 } }.with_indifferent_access }

      context "send populate request with params[:subscribe] present" do
        before { do_populate with_subscribe_params }
        it { expect(controller.send :add_subscription_fields).to_not be_nil }
      end
    end
  end

end
