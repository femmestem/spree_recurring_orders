require 'spec_helper'

describe Spree::Admin::SubscriptionsController, type: :controller do

  stub_authorization!

  let(:active_subscription) { create(:valid_subscription, enabled: true) }
  let(:cancelled_subscription) { create(:valid_subscription, cancelled_at: Time.current, cancellation_reasons: "Test") }

  describe "Get#cancellation" do
    def do_cancellation
      spree_get :cancellation, id: active_subscription.id
    end

    context "response" do
      before { do_cancellation }
      it { expect(response).to have_http_status 200 }
      it { expect(response).to render_template :cancellation }
    end
  end

  describe "callbacks" do
    describe "#ensure_not_cancelled" do
      def do_update(params)
        spree_put :update, params
      end

      context "when subscription is cancelled" do
        before { do_update({ id: cancelled_subscription.id }) }
        it { expect(response).to have_http_status 302 }
        it { expect(response).to redirect_to controller.send :collection_url }
        it { expect(flash[:error]).to eq I18n.t("spree.admin.subscriptions.error_on_already_cancelled") }
      end

      context "when subscription is not cancelled" do
        before { do_update({ id: active_subscription.id }) }
        it { expect(response).to have_http_status 302 }
        it { expect(response).to redirect_to controller.send :collection_url }
      end
    end
  end

end
