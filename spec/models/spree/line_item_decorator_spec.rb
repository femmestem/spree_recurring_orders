require 'spec_helper'

describe Spree::LineItem do

  let(:order) { create(:completed_order_with_totals) }
  let(:active_subscription) { create(:valid_subscription, enabled: true, parent_order: order) }
  let(:line_item_without_subscription_attributes) { create(:line_item, order: order) }
  let(:line_item_with_subscription_attributes) { create(:line_item, order: order, subscription_frequency_id: 1, delivery_number: 6) }

  describe "callbacks" do
    it { expect(subject).to callback(:create_subscription!).after(:create).if(:subscribable?) }
    it { expect(subject).to callback(:update_subscription_quantity).after(:update).if(:can_update_subscription_quantity?) }
    it { expect(subject).to callback(:update_subscription_attributes).after(:update).if(:can_update_subscription_attributes?) }
    it { expect(subject).to callback(:destroy_associated_subscription!).after(:destroy).if(:subscription?) }
  end

  describe "attr_accessors" do
    it { expect(subject).to respond_to :delivery_number }
    it { expect(subject).to respond_to :delivery_number= }
    it { expect(subject).to respond_to :subscribe }
    it { expect(subject).to respond_to :subscribe= }
    it { expect(subject).to respond_to :subscription_frequency_id }
    it { expect(subject).to respond_to :subscription_frequency_id= }
  end

  describe "methods" do
    context "#subscription_attributes_present?" do
      it { expect(line_item_without_subscription_attributes).to be_subscription_attributes_present }
      it { expect(line_item_with_subscription_attributes).to_not be_subscription_attributes_present }
    end
  end

end
