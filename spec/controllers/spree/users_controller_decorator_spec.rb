require "spec_helper"

describe Spree::UsersController, type: :controller do

  stub_authorization!

  describe "Callbacks" do
    describe "#load_subscriptions" do
      def do_show
        spree_get :show
      end

      let(:orders) { double(ActiveRecord::Relation) }
      let(:subscriptions) { double(ActiveRecord::Relation) }
      let(:user) { create(:admin_user) }

      before do
        allow(controller).to receive(:spree_current_user).and_return(user)
        allow(user).to receive(:orders).and_return(orders)
        allow(orders).to receive(:complete).and_return(orders)
        allow(orders).to receive(:order).and_return(orders)
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:with_parent_orders).and_return(subscriptions)
        do_show
      end
      it { expect(assigns(:orders)).to eq orders }
      it { expect(assigns(:subscriptions)).to eq subscriptions }
    end
  end

end
