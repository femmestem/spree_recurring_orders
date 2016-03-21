require "spec_helper"

describe Spree::Subscription, type: :model do

  let(:last_ip_address) { "127.0.0.1" }
  let(:order) { create(:completed_order_with_totals, last_ip_address: last_ip_address) }
  let(:orders) { [create(:completed_order_with_totals)] }
  let(:nil_attributes_subscription) { build(:nil_attributes_subscription) }
  let(:active_subscription) { create(:valid_subscription, enabled: true, parent_order: order) }
  let(:disabled_subscription) { create(:valid_subscription, enabled: false) }
  let(:cancelled_subscription) { create(:valid_subscription, cancelled_at: Time.current, cancellation_reasons: "Test") }
  let(:subscription_with_recreated_orders) { create(:valid_subscription, orders: orders, last_occurrence_at: Time.current) }

  describe "validations" do
    it { expect(subject).to validate_presence_of(:quantity) }
    it { expect(subject).to validate_presence_of(:delivery_number) }
    it { expect(subject).to validate_presence_of(:price) }
    context "validates presence of number" do
      context "when number is absent" do
        before { nil_attributes_subscription.save }
        it { expect(nil_attributes_subscription.number).to be_present }
      end

      context "when number is present" do
        before do
          nil_attributes_subscription.number = "S123456789"
          nil_attributes_subscription.save
        end
        it { expect(nil_attributes_subscription.number).to be_present }
      end
    end
    it { expect(subject).to validate_presence_of(:variant) }
    it { expect(subject).to validate_presence_of(:parent_order) }
    it { expect(subject).to validate_presence_of(:frequency) }
    context "if cancelled present" do
      before { subject.cancelled = true }
      it { expect(subject).to validate_presence_of(:cancellation_reasons) }
      context "validate_presence_of cancelled_at" do
        context "when cancelled at is present" do
          before do
            nil_attributes_subscription.cancelled = true
            nil_attributes_subscription.cancelled_at = Time.current
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.cancelled_at).to be_present }
        end

        context "when cancelled_at is absent" do
          before do
            nil_attributes_subscription.cancelled = true
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.cancelled_at).to be_present }
        end
      end
    end
    context "if enabled" do
      before { subject.enabled = true }
      it { expect(subject).to validate_presence_of(:ship_address) }
      it { expect(subject).to validate_presence_of(:bill_address) }
      context "validate_presence_of last_occurrence_at" do
        context "when last_occurrence_at is present" do
          before do
            nil_attributes_subscription.enabled = true
            nil_attributes_subscription.last_occurrence_at = Time.current
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.last_occurrence_at).to be_present }
        end

        context "when last_occurrence_at is absent" do
          before do
            nil_attributes_subscription.enabled = true
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.last_occurrence_at).to be_present }
        end
      end
      it { expect(subject).to validate_presence_of(:source) }
    end
    it { expect(subject).to validate_numericality_of(:price).is_greater_than_or_equal_to(0).allow_nil }
    it { expect(subject).to validate_numericality_of(:quantity).is_greater_than(0).only_integer.allow_nil }
    it { expect(subject).to validate_numericality_of(:delivery_number).is_greater_than_or_equal_to(subject.send :recurring_orders_size).only_integer.allow_nil }
  end

  describe "associations" do
    it { expect(subject).to belong_to(:ship_address).class_name("Spree::Address") }
    it { expect(subject).to belong_to(:bill_address).class_name("Spree::Address") }
    it { expect(subject).to belong_to(:parent_order).class_name("Spree::Order") }
    it { expect(subject).to belong_to(:variant).inverse_of(:subscriptions) }
    it { expect(subject).to belong_to(:frequency).class_name("Spree::SubscriptionFrequency").with_foreign_key(:subscription_frequency_id) }
    it { expect(subject).to belong_to(:source) }
    it { expect(subject).to have_many(:orders_subscriptions).class_name("Spree::OrderSubscription").dependent(:destroy) }
    it { expect(subject).to have_many(:orders).through(:orders_subscriptions) }
    it { expect(subject).to have_many(:complete_orders).conditions(:complete).through(:orders_subscriptions).source(:order) }
    it { expect(subject).to accept_nested_attributes_for(:ship_address) }
    it { expect(subject).to accept_nested_attributes_for(:bill_address) }
  end

  describe "callbacks" do
    it { expect(subject).to callback(:set_last_occurrence_at).before(:validation).if(:can_set_last_occurence_at?) }
    it { expect(subject).to callback(:set_cancelled_at).before(:validation).if(:can_set_cancelled_at?) }
    it { expect(subject).to callback(:notify_cancellation).after(:update).if(:cancellation_notifiable?) }
    it { expect(subject).to callback(:notify_reoccurrence).after(:update).if(:reoccurrence_notifiable?) }
    it { expect(subject).to callback(:not_cancelled?).before(:update) }
    it { expect(subject).to callback(:notify_user).after(:update).if(:user_notifiable?) }
  end

  describe "attr_accessors" do
    it { expect(subject).to respond_to :cancelled }
    it { expect(subject).to respond_to :cancelled= }
  end

  describe "scopes" do
    context ".disabled" do
      it { expect(Spree::Subscription.disabled).to include disabled_subscription }
      it { expect(Spree::Subscription.disabled).to_not include active_subscription }
    end

    context ".active" do
      it { expect(Spree::Subscription.active).to include active_subscription }
      it { expect(Spree::Subscription.active).to_not include disabled_subscription }
    end

    context ".not_cancelled" do
      it { expect(Spree::Subscription.not_cancelled).to include active_subscription }
      it { expect(Spree::Subscription.not_cancelled).to_not include cancelled_subscription }
    end

    context ".eligible_for_subscription" do
      it { expect(Spree::Subscription.eligible_for_subscription).to include active_subscription }
      it { expect(Spree::Subscription.eligible_for_subscription).to_not include disabled_subscription }
      it { expect(Spree::Subscription.eligible_for_subscription).to_not include cancelled_subscription }
    end

    context ".with_parent_orders" do
      it { expect(Spree::Subscription.with_parent_orders(order)).to include active_subscription }
      it { expect(Spree::Subscription.with_parent_orders(order)).to_not include disabled_subscription }
    end
  end

  describe "ransackable" do
    context "whitelisted ransackable associations" do
      it { expect(Spree::Subscription.whitelisted_ransackable_associations).to include "parent_order" }
    end
  end

  describe "methods" do
    context "#cancelled?" do
      it { expect(active_subscription).to_not be_cancelled }
      it { expect(disabled_subscription).to_not be_cancelled }
      it { expect(cancelled_subscription).to be_cancelled }
    end

    context "#set_cancelled_at" do
      before { nil_attributes_subscription.send :set_cancelled_at }
      it { expect(nil_attributes_subscription.cancelled_at).to_not be_nil }
    end

    context "#set_last_occurrence_at" do
      before { nil_attributes_subscription.send :set_last_occurrence_at }
      it { expect(nil_attributes_subscription.last_occurrence_at).to_not be_nil }
    end

    context "#can_set_last_occurence_at?" do
      context "when enabled and last_occurrence_at present" do
        it { expect(active_subscription.send :can_set_last_occurence_at?).to eq false }
        it { expect(subscription_with_recreated_orders.send :can_set_last_occurence_at?).to eq false }
      end

      context "when disbaled and last_occurrence_at absent" do
        it { expect(disabled_subscription.send :can_set_last_occurence_at?).to eq false }
      end

      context "when enabled and last_occurrence_at is nil" do
        before { active_subscription.last_occurrence_at = nil }
        it { expect(active_subscription.send :can_set_last_occurence_at?).to eq true }
      end
    end

    context "#not_cancelled?" do
      it { expect(active_subscription.send :not_cancelled?).to eq true }
      it { expect(disabled_subscription.send :not_cancelled?).to eq true }
      it { expect(cancelled_subscription.send :not_cancelled?).to eq false }
    end

    context "#can_set_cancelled_at?" do
      context "when cancelled present" do
        before { active_subscription.cancelled = true }
        it { expect(active_subscription.send :can_set_cancelled_at?).to eq true }
      end

      context "when cancelled not present" do
        it { expect(active_subscription.send :can_set_cancelled_at?).to eq false }
      end
    end

    context "#cancellation_notifiable?" do
      context "when cancelled at not present neither changed" do
        it { expect(active_subscription.send :cancellation_notifiable?).to eq false }
      end

      context "when cancelled at present and value changed" do
        before { active_subscription.cancelled_at = Time.current }
        it { expect(active_subscription.send :cancellation_notifiable?).to eq true }
      end
    end

    context "#reoccurrence_notifiable?" do
      context "when last_occurrence_at present and not changed" do
        it { expect(subscription_with_recreated_orders.send :reoccurrence_notifiable?).to eq false }
      end

      context "when last_occurrence_at present and got changed" do
        before { subscription_with_recreated_orders.last_occurrence_at = Time.current }
        it { expect(subscription_with_recreated_orders.send :reoccurrence_notifiable?).to eq true }
      end

      context "when last_occurrence_at not present" do
        it { expect(active_subscription.send :reoccurrence_notifiable?).to eq false }
      end
    end

    context "#deliveries_remaining?" do
      it { expect(subscription_with_recreated_orders.send :deliveries_remaining?).to eq true }
      it { expect(active_subscription.send :deliveries_remaining?).to eq true }
    end

    context "#number_of_deliveries_left" do
      let(:completed_order) { create(:completed_order_with_totals) }
      it { expect { active_subscription.complete_orders << completed_order }.to change { active_subscription.number_of_deliveries_left }.by -1 }
    end

    context "#cancellation_notifiable?" do
      context "when cancelled at present and not changed" do
        it { expect(cancelled_subscription.send :cancellation_notifiable?).to eq false }
      end

      context "when cancelled at is not present" do
        it { expect(active_subscription.send :cancellation_notifiable?).to eq false }
      end

      context "when cancelled_at present and changed" do
        before { active_subscription.cancelled_at = Time.current }
        it { expect(active_subscription.send :cancellation_notifiable?).to eq true }
      end
    end

    context "#recurring_orders_size" do
      let(:completed_order) { create(:completed_order_with_totals) }
      it { expect { active_subscription.complete_orders << completed_order }.to change { active_subscription.send :recurring_orders_size }.by 1 }
    end

    context "#user_notifiable?" do
      context "when enabled present but not changed" do
        it { expect(active_subscription.send :user_notifiable?).to eq false }
      end

      context "when enabled is not present" do
        it { expect(disabled_subscription.send :user_notifiable?).to eq false }
      end

      context "when enabled is present and is recently changed" do
        before { disabled_subscription.enabled = true }
        it { expect(disabled_subscription.send :user_notifiable?).to eq true }
      end
    end

    context "#time_for_subscription?" do
      it { expect(active_subscription.send :time_for_subscription?).to eq false }
      it { expect(subscription_with_recreated_orders.send :time_for_subscription?).to eq false }
    end

    context "#cancel_with_reason" do
      before { active_subscription.cancel_with_reason({ cancellation_reasons: "Test" }) }
      it { expect(active_subscription.cancelled_at).to_not be_nil }
      it { expect(active_subscription.cancellation_reasons).to_not be_nil }
      it { expect(active_subscription.cancellation_reasons).to eq "Test" }
    end

    context "#generate_number" do
      before { nil_attributes_subscription.generate_number }
      it { expect(nil_attributes_subscription.number).to_not be_nil }
    end

    context "#order_attributes" do
      it { expect(active_subscription.send :order_attributes).to eq ({
        currency: order.currency,
        guest_token: order.guest_token,
        store: order.store,
        user: order.user,
        created_by: order.user,
        last_ip_address: last_ip_address
        }) }
    end

    context "#order recreation" do
      let(:order_attributes) { {
        currency: order.currency,
        guest_token: order.guest_token,
        store: order.store,
        user: order.user,
        created_by: order.user,
        last_ip_address: last_ip_address,
        line_items: []
        } }
      let(:new_order) { create(:order, order_attributes) }
      let(:created_order) { active_subscription.send :make_new_order }
      let(:created_order_with_variant) { active_subscription.send(:add_variant_to_order, created_order); created_order }
      let(:created_order_with_addresses) { active_subscription.send(:add_shipping_address, created_order_with_variant); created_order_with_variant }
      let(:created_order_with_delivery_method) { active_subscription.send(:add_delivery_method_to_order, created_order_with_addresses); created_order_with_addresses }
      let(:created_order_with_payment_method) { active_subscription.send(:add_payment_method_to_order, created_order_with_delivery_method); created_order_with_delivery_method }
      let(:created_order_with_confirmation) { active_subscription.send(:confirm_order, created_order_with_payment_method); created_order_with_payment_method }

      context "#make_new_order" do
        it { expect(created_order.currency).to eq new_order.currency }
        it { expect(created_order.guest_token).to eq new_order.guest_token }
        it { expect(created_order.store).to eq new_order.store }
        it { expect(created_order.user).to eq new_order.user }
        it { expect(created_order.created_by).to eq new_order.created_by }
        it { expect(created_order.last_ip_address).to eq new_order.last_ip_address }
        it { expect(created_order.state).to eq "cart" }
      end

      context "#add_variant_to_order" do
        it { expect(created_order_with_variant.line_items.count).to eq 1 }
        it { expect(created_order_with_variant.state).to eq "address" }
      end

      context "#add_shipping_address" do
        it { expect(created_order_with_addresses.ship_address).to_not be_nil }
        it { expect(created_order_with_addresses.bill_address).to_not be_nil }
        it { expect(created_order_with_addresses.state).to eq "delivery" }
      end

      context "#add_delivery_method_to_order" do
        it { expect(created_order_with_delivery_method.state).to eq "payment" }
      end

      context "#add_payment_method_to_order" do
        it { expect(created_order_with_payment_method.payments.count).to eq 1 }
        it { expect(created_order_with_payment_method.payments.first.source).to eq active_subscription.source }
        it { expect(created_order_with_payment_method.state).to eq "confirm" }
      end

      context "#confirm_order" do
        it { expect(created_order_with_confirmation.state).to eq "complete" }
      end

      context "#recreate_order" do
        let(:recreated_order) { active_subscription.send :recreate_order }
        it { expect(recreated_order.bill_address).to eq created_order_with_confirmation.bill_address }
        it { expect(recreated_order.ship_address).to eq created_order_with_confirmation.ship_address }
        it { expect(recreated_order.payments.first.source).to eq active_subscription.source }
        it { expect(recreated_order).to be_completed }
      end
    end

    context "#process" do
      let (:last_occurrence_at_time) { Time.current - 1.month }
      context "#no deliveries remaining" do
        before do
          active_subscription.delivery_number = 1
          active_subscription.process
        end
        it { expect(active_subscription.reload.complete_orders.count).to eq 0 }
        it { expect(active_subscription).to_not be_last_occurrence_at_changed }
      end

      context "#deliveries remaining but not appropriate time for subscription" do
        before do
          active_subscription.process
        end
        it { expect(active_subscription.reload.complete_orders.count).to eq 0 }
        it { expect(active_subscription).to_not be_last_occurrence_at_changed }
      end

      context "#deliveries_remaining and appropriate time for subscription" do
        before do
          active_subscription.last_occurrence_at = last_occurrence_at_time
          active_subscription.process
        end
        it { expect(active_subscription.last_occurrence_at_changed?).to_not eq last_occurrence_at_time }
        it { expect(active_subscription.reload.complete_orders.count).to eq 1 }
      end
    end

    context "mail sending methods" do
      context "#notify_reoccurrence" do
        it { expect { active_subscription.send :notify_reoccurrence }.to change { ActionMailer::Base.deliveries.count }.by 1 }
      end

      context "#notify_cancellation" do
        it { expect { active_subscription.send :notify_cancellation }.to change { ActionMailer::Base.deliveries.count }.by 1 }
      end

      context "#notify_user" do
        it { expect { active_subscription.send :notify_user }.to change { ActionMailer::Base.deliveries.count }.by 1 }
      end
    end
  end

end
