require "spec_helper"

describe Spree::Subscription do

  let(:order) { create(:completed_order_with_totals) }
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
    it { expect(subject).to validate_presence_of(:number) }
    it { expect(subject).to validate_presence_of(:variant) }
    it { expect(subject).to validate_presence_of(:parent_order) }
    it { expect(subject).to validate_presence_of(:frequency) }
    context "if cancelled present" do
      before { subject.cancelled = true }
      it { expect(subject).to validate_presence_of(:cancellation_reasons) }
      it { expect(subject).to validate_presence_of(:cancelled_at) }
    end
    context "if enabled" do
      before { subject.enabled = true }
      it { expect(subject).to validate_presence_of(:ship_address) }
      it { expect(subject).to validate_presence_of(:bill_address) }
      it { expect(subject).to validate_presence_of(:last_occurrence_at) }
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
      it { expect(subscription_with_recreated_orders.number_of_deliveries_left).to eq 4 }
      it { expect(active_subscription.number_of_deliveries_left).to eq 5 }
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
      it { expect(subscription_with_recreated_orders.send :recurring_orders_size).to eq 2 }
      it { expect(active_subscription.send :recurring_orders_size).to eq 1 }
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
  end

end
