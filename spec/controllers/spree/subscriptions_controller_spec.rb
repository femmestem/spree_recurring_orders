require "spec_helper"

describe Spree::SubscriptionsController, type: :controller do

  stub_authorization!

  let(:active_subscription) { mock_model(Spree::Subscription, id: 1, enabled: true, next_occurrence_at: Time.current) }
  let(:cancelled_subscription) { mock_model(Spree::Subscription, id: 2, cancelled_at: Time.current, cancellation_reasons: "Test") }
  let(:subscriptions) { double(ActiveRecord::Relation) }

  describe "Callbacks" do

  end

  describe "edit" do
    def do_edit params
      spree_get :edit, params
    end

    describe "when subscription is found" do
      before do
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:find_by).and_return(active_subscription)
      end

      describe "expects to receive" do
        after { do_edit({ id: active_subscription.id }) }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
      end

      describe "response" do
        before { do_edit({ id: active_subscription.id }) }
        it { expect(response).to have_http_status 200 }
        it { expect(response).to render_template :edit }
      end
    end

    describe "when subscription is not found" do
      before do
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:find_by).and_return(nil)
      end

      describe "expects to receive" do
        after { do_edit({ id: "" }) }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:find_by).and_return(nil) }
      end

      describe "response" do
        before { do_edit({ id: "" }) }
        it { expect(response).to have_http_status 302 }
        it { expect(response).to redirect_to account_path }
        it { expect(flash[:error]).to eq Spree.t("subscriptions.alert.missing") }
      end
    end
  end

  describe "update" do
    def do_update params
      spree_put :update, params
    end

    describe "when subscription is found" do

      let(:params) { { id: active_subscription.id, subscription: { quantity: 2 } } }

      describe "when subscription is successfully updated" do
        before do
          allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
          allow(subscriptions).to receive(:find_by).and_return(active_subscription)
          allow(active_subscription).to receive(:not_changeable?).and_return(false)
          allow(controller).to receive(:subscription_attributes).and_return(params[:subscription])
          allow(active_subscription).to receive(:update).and_return(true)
        end

        describe "expects to receive" do
          after { do_update(params) }
          it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
          it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
          it { expect(controller).to receive(:subscription_attributes).and_call_original }
          it { expect(active_subscription).to receive(:update).with(controller.send :subscription_attributes).and_return(true) }
        end

        describe "response" do
          before { do_update(params) }
          it { expect(response).to have_http_status 302 }
          it { expect(response).to redirect_to edit_subscription_path(active_subscription) }
          it { expect(flash[:success]).to eq Spree.t("subscriptions.update.success") }
        end
      end

      describe "when subscription is not successfully updated" do
        before do
          allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
          allow(subscriptions).to receive(:find_by).and_return(active_subscription)
          allow(active_subscription).to receive(:not_changeable?).and_return(false)
          allow(controller).to receive(:subscription_attributes).and_return(params[:subscription])
          allow(active_subscription).to receive(:update).and_return(false)
        end

        describe "expects to receive" do
          after { do_update(params) }
          it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
          it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
          it { expect(controller).to receive(:subscription_attributes).and_call_original }
          it { expect(active_subscription).to receive(:update).with(controller.send :subscription_attributes).and_return(false) }
        end

        describe "response" do
          before { do_update(params) }
          it { expect(response).to have_http_status 200 }
          it { expect(response).to render_template :edit }
        end
      end
    end

    describe "when subscription is not found" do
      before do
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:find_by).and_return(nil)
      end

      describe "expects to receive" do
        after { do_update({ id: "" }) }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:find_by).and_return(nil) }
      end

      describe "response" do
        before { do_update({ id: "" }) }
        it { expect(response).to have_http_status 302 }
        it { expect(response).to redirect_to account_path }
        it { expect(flash[:error]).to eq Spree.t("subscriptions.alert.missing") }
      end
    end
  end

  describe "pause" do
    def do_pause
      spree_post :pause, format: :json, id: active_subscription.id
    end

    before do
      allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
      allow(subscriptions).to receive(:find_by).and_return(active_subscription)
      allow(active_subscription).to receive(:not_changeable?).and_return(false)
    end

    describe "when pause returns success" do
      before do
        allow(active_subscription).to receive(:pause).and_return(true)
      end

      describe "expects to receive" do
        after { do_pause }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
        it { expect(active_subscription).to receive(:pause).and_return(true) }
      end

      describe "response" do
        before { do_pause }
        it { expect(response).to have_http_status 200 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("subscriptions.pause.success") }
      end
    end

    describe "when pause is not successful" do
      before do
        allow(active_subscription).to receive(:pause).and_return(false)
      end

      describe "expects to receive" do
        after { do_pause }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
        it { expect(active_subscription).to receive(:pause).and_return(false) }
      end

      describe "response" do
        before { do_pause }
        it { expect(response).to have_http_status 422 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("subscriptions.pause.error") }
      end
    end
  end

  describe "unpause" do
    def do_unpause
      spree_post :unpause, format: :json, id: active_subscription.id
    end

    before do
      allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
      allow(subscriptions).to receive(:find_by).and_return(active_subscription)
      allow(active_subscription).to receive(:not_changeable?).and_return(false)
    end

    describe "when unpause returns success" do
      before do
        allow(active_subscription).to receive(:unpause).and_return(true)
      end

      describe "expects to receive" do
        after { do_unpause }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
        it { expect(active_subscription).to receive(:unpause).and_return(true) }
      end

      describe "response" do
        before { do_unpause }
        it { expect(response).to have_http_status 200 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("subscriptions.unpause.success", next_occurrence_at: active_subscription.next_occurrence_at.to_date.to_formatted_s(:rfc822)) }
      end
    end

    describe "when unpause is not successful" do
      before do
        allow(active_subscription).to receive(:unpause).and_return(false)
      end

      describe "expects to receive" do
        after { do_unpause }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
        it { expect(active_subscription).to receive(:unpause).and_return(false) }
      end

      describe "response" do
        before { do_unpause }
        it { expect(response).to have_http_status 422 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("subscriptions.unpause.error") }
      end
    end
  end

  describe "cancel" do
    describe "html response" do
      def do_cancel params
        spree_post :cancel, params
      end

      before do
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:find_by).and_return(active_subscription)
        allow(active_subscription).to receive(:not_changeable?).and_return(false)
      end

      describe "when subscription cancel is successful" do
        before do
          allow(active_subscription).to receive(:cancel).and_return(true)
        end

        describe "expects to receive" do
          after { do_cancel({ id: active_subscription.id }) }
          it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
          it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
          it { expect(active_subscription).to receive(:cancel).and_return(true) }
        end

        describe "response" do
          before { do_cancel({ id: active_subscription.id }) }
          it { expect(response).to have_http_status 302 }
          it { expect(response).to redirect_to edit_subscription_path(active_subscription) }
          it { expect(flash[:success]).to eq Spree.t("subscriptions.cancel.success") }
        end
      end

      describe "when subscription cancel is not successful" do
        before do
          allow(active_subscription).to receive(:cancel).and_return(false)
        end

        describe "expects to receive" do
          after { do_cancel({ id: active_subscription.id }) }
          it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
          it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
          it { expect(active_subscription).to receive(:cancel).and_return(false) }
        end

        describe "response" do
          before { do_cancel({ id: active_subscription.id }) }
          it { expect(response).to have_http_status 302 }
          it { expect(response).to redirect_to edit_subscription_path(active_subscription) }
          it { expect(flash[:error]).to eq Spree.t("subscriptions.cancel.error") }
        end
      end
    end

    describe "json response" do
      def do_cancel
        spree_post :cancel, format: :json, id: active_subscription.id
      end

      before do
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:find_by).and_return(active_subscription)
        allow(active_subscription).to receive(:not_changeable?).and_return(false)
      end

      describe "when cancel returns success" do
        before do
          allow(active_subscription).to receive(:cancel).and_return(true)
        end

        describe "expects to receive" do
          after { do_cancel }
          it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
          it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
          it { expect(active_subscription).to receive(:cancel).and_return(true) }
        end

        describe "response" do
          before { do_cancel }
          it { expect(response).to have_http_status 200 }
          it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("subscriptions.cancel.success") }
        end
      end

      describe "when cancel is not successful" do
        before do
          allow(active_subscription).to receive(:cancel).and_return(false)
        end

        describe "expects to receive" do
          after { do_cancel }
          it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:find_by).and_return(active_subscription) }
          it { expect(active_subscription).to receive(:not_changeable?).and_return(false) }
          it { expect(active_subscription).to receive(:cancel).and_return(false) }
        end

        describe "response" do
          before { do_cancel }
          it { expect(response).to have_http_status 422 }
          it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("subscriptions.cancel.error") }
        end
      end
    end
  end

end
