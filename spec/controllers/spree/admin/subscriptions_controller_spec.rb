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

  def do_cancel params
    spree_post :cancel, params
  end

  describe "Patch#Cancel" do
    context "when cancel_with_reason returns true" do

      let(:params) { { id: active_subscription.id, subscription: { cancellation_reasons: "Test" } } }

      before do
        allow(controller).to receive(:permitted_cancel_subscription_attributes).and_return(params[:subscription])
        allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
      end

      context "expects to receive" do
        after { do_cancel params }
        it { expect(Spree::Subscription).to receive(:find).with(params[:id].to_s).and_return(active_subscription) }
        it { expect(controller).to receive(:permitted_cancel_subscription_attributes).and_call_original }
        it { expect(active_subscription).to receive(:cancel_with_reason).and_return(true) }
      end

      context "response" do
        before { do_cancel params }
        it { expect(response).to have_http_status 302 }
        it { expect(response).to redirect_to controller.send :collection_url }
        it { expect(flash[:success]).to eq I18n.t("spree.admin.subscriptions.cancel.success") }
      end
    end

    context "when cancel_with_reason returns false" do

      let(:params) { { id: active_subscription.id, subscription: { cancellation_reasons: nil } } }

      before do
        allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
        allow(controller).to receive(:permitted_cancel_subscription_attributes).and_return(params[:subscription])
      end

      context "expects to receive" do
        after { do_cancel params }
        it { expect(Spree::Subscription).to receive(:find).with(params[:id].to_s).and_return(active_subscription) }
        it { expect(controller).to receive(:permitted_cancel_subscription_attributes).and_call_original }
        it { expect(active_subscription).to receive(:cancel_with_reason).with(controller.send :permitted_cancel_subscription_attributes).and_return(false) }
      end

      context "response" do
        before { do_cancel params }
        it { expect(response).to have_http_status 200 }
        it { expect(response).to render_template :cancellation }
      end
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

    describe "#collection" do
      def do_index
        spree_get :index
      end

      let(:subscriptions) { double(ActiveRecord::Relation) }
      let(:search_subscriptions) { double(Ransack::Search) }
      let(:result_subscriptions) { double(ActiveRecord::Relation) }

      before do
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:ransack).and_return(search_subscriptions)
        allow(search_subscriptions).to receive(:result).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:includes).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:references).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:order).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:page).and_return(result_subscriptions)
      end

      context "expects to receive" do
        after { do_index }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:ransack).with(controller.params[:q]).and_return(search_subscriptions) }
        it { expect(search_subscriptions).to receive(:result).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:includes).with(:frequency, :complete_orders, variant: :product).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:references).with(:complete_orders).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:order).with(created_at: :desc).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:page).with(controller.params[:page]).and_return(result_subscriptions) }
      end

      context "assigns" do
        before { do_index }
        it { expect(assigns(:search)).to eq search_subscriptions }
        it { expect(assigns(:collection)).to eq result_subscriptions }
      end
    end
  end

end
